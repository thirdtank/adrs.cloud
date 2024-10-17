import BaseCustomElement from "./BaseCustomElement"
import BrutConstraintViolationMessages from "./BrutConstraintViolationMessages"
import BrutConstraintViolationMessage from "./BrutConstraintViolationMessage"

/** Wraps a `<BUTTON>` assumed to be inside a form to indicate that, when clicked, it should submit
 * the form it's a part of via AJAX. It accounts for network failures and timeouts.
 * 
 * The general flow is as follows:
 *
 * 1. When the button is clicked, the form's validity is checked. If it's not valid, nothing happens.
 * 2. If the form is valid, this element will be given the `requesting` attribute.
 * 3. The request will be initiated, set to abort after `request-timeout` ms (see below).
 * 4. If the request returns OK:
 *    - `requesting` will be removed and `submitted` will be added.
 *    - `submitted` will be removed after `submitted-lifetime` ms.
 * 5. If the request returned a 422, error messages are parsed. See below.
 * 6. If the request returns not OK and not 422:
 *    - if it has been `request-timeout` ms or more since the button was first clicked, the operation is aborted (see below).
 *    - if it has been less than `request-timeout` ms and the HTTP status code was 5xx, the operation is retried.
 *    - otherwise, the operation is aborted.
 * 7. If fetch throws an error, the operation is aborted.
 *
 * Aborting the operation will submit the form in the normal way, allowing the browser to deal with whatever the issue is. You can set
 * `log-request-errors` to introspect this process.
 *
 * For a 422 response, this element assumes the response is `text/html` and contains one or more `<brut-constraint-violation-message>`
 * elements.  These elements will be inserted into the proper `<brut-constraint-violation-messages>` element, as follows:
 *
 * 1. The `input-name` is examined.
 * 2. A `<brut-constraint-violation-messages server-side input-name="«input-name»">` is located
 * 3. The containing form is located
 * 4. The input element(s) are located inside that form, based on `input-name`.
 * 5. The `<brut-constraint-violation-messages>` are cleared
 * 6. The messages from the server are inserted
 * 7. The input is set as having a custom validity
 * 8. validity is reported
 * 9. The first input located is scrolled into view
 * 10. If the input is modified, custom validity is cleared
 * 11. If the form has a <brut-constraint-violation-message key='general.cv.fe.general'>, it is shown.
 *
 * @property {number} request-timeout - number of ms that the entire operation is expected to complete within. Default is 5000
 * @property {number} submitted-lifetime - number of ms that "submitted" should remain on the element after the form has completed. Default is 2000
 * @property {boolean} requesting - boolean attribute that indicates the request has been made, but not yet returned. Don't set this yourself outside of development. It will be set and removed by this element.
 * @property {boolean} submitted - boolean attribute that indicates the form has been successfully submitted. Don't set this yourselr outside of develoment. It will be set and removed by this element.
 * @property {boolean} log-request-errors - if set, logging related to request error handling will appear in the console. It will also
 * cause any form submission to be delayed by 2s to allow you to read the console.
 *
 * @fires submitok Fired when the AJAX request initated by this returns OK and all processing has completed
 * @fires submitinvalid Fired when the AJAX request initated by this returns a 422 and all logic around managing the reponse has completed
 *
 * @example
 * <form action="/widgets" method="post">
 *   <input type=text name=name>
 *
 *   <brut-ajax-submit>
 *     <button>Save</button>
*    </brut-ajax-submit>
 * </form>
 */
class BrutAjaxSubmit extends BaseCustomElement {
  static tagName = "brut-ajax-submit"
  static observedAttributes = [
    "show-warnings",
    "requesting",
    "submitted",
    "submitted-lifetime",
    "request-timeout",
    "log-request-errors",
  ]

  #requestErrorLogger = () => {}
  #formSubmitDelay    = 0
  #submittedLifetime  = 2000
  #requestTimeout     = 5000

  submittedLifetimeChangedCallback({newValue}) {
    const newValueAsInt = parseInt(newValue)
    if (isNaN(newValueAsInt)) {
      throw `submitted-lifetime must be a number, not '${newValue}'`
    }
    this.#submittedLifetime = newValueAsInt
  }

  requestTimeoutChangedCallback({newValue}) {
    const newValueAsInt = parseInt(newValue)
    if (isNaN(newValueAsInt)) {
      throw `request-timeout must be a number, not '${newValue}'`
    }
    this.#requestTimeout = newValueAsInt
  }

  submittedChangedCallback({newValueAsBoolean}) {
    // no op
  }

  requestingChangedCallback({newValueAsBoolean}) {
    if (this.#button()) {
      if (newValueAsBoolean) {
        this.#button().setAttribute("disabled",true)
      }
      else {
        this.#button().removeAttribute("disabled",true)
      }
    }
  }

  logRequestErrorsChangedCallback({newValueAsBoolean}) {
    if (newValueAsBoolean) {
      this.#requestErrorLogger = console.warn
      this.#formSubmitDelay = 2000
    }
    else {
      this.#requestErrorLogger = () => {}
      this.#formSubmitDelay = 0
    }
  }

  update() {
    const button = this.#button()
    if (!button)
    {
      this.logger.info("Could not find a <button> to attach behavior to")
      return
    }
    const form = button.form
    if (!form) {
      this.logger.info("%o did not have a form associated with it - cannot attach behavior",button)
      return
    }
    button.form.addEventListener("submit",this.#formSubmitted)
  }


  #formSubmitted = (event) => {
    const submitter = event.submitter
    if (submitter == this.#button()) {
      event.preventDefault()
      const now = Date.now()
      this.#submitForm(event.target, now, 0)
    }
  }

  #submitForm(form, firstSubmittedAt, numAttempts) {

    const headers = new Headers()
    headers.append("X-Requested-With","XMLHttpRequest")
    headers.append("Content-Type","application/x-www-form-urlencoded")

    const formData = new FormData(form)
    const urlSearchParams = new URLSearchParams(formData)

    const timeoutSignal = AbortSignal.timeout(this.#requestTimeout)

    const request = new Request(
      form.action,
      {
        headers: headers,
        method: form.method,
        body: urlSearchParams,
        signal: timeoutSignal,
      }
    )

    if (numAttempts > 25) {
      this.#requestErrorLogger("%d attempts. Giving up",numAttempts)
      this.#submitFormThroughBrowser(form)
      return
    }
    this.setAttribute("requesting", true)
    fetch(request).then( (response) => {
      if (response.ok) {
        this.removeAttribute("requesting")
        this.setAttribute("submitted",true)

        setTimeout( () => this.removeAttribute("submitted"), this.#submittedLifetime )
        this.dispatchEvent(new CustomEvent("brut:submitok"))
      }
      else {

        let retry    = false // if true, we retry the request via ajax
        let resubmit = false // if true, and we aren't retrying, we submit the
                             // form the old fashioned way

        if ( (Date.now() - firstSubmittedAt) > this.#requestTimeout) {
          this.#requestErrorLogger("Since initial button press %d, it's taken more than %d ms to get a response.",firstSubmittedAt,this.#requestTimeout)
          retry = false
        }
        else {
          const status = parseInt(response.status)
          if (isNaN(status)) {
            this.#requestErrorLogger("Got unparseable status: %d",response.status)
            retry = false
          }
          else if (status >= 500) {
            this.#requestErrorLogger("Got a %d, maybe retry will fix", status)
            retry = true
          }
          else {
            retry = false
            if (status == 422) {
              response.text().then( (text) => {
                try {
                  const parser = new DOMParser()
                  const fragment = parser.parseFromString(text,"text/html")
                  const errorMessages = fragment.querySelectorAll(BrutConstraintViolationMessage.tagName)

                  const inputsToMessages = {}

                  Array.from(errorMessages).map( (element) => {
                    return {
                      element: element,
                      inputName: element.getAttribute("input-name"),
                    }
                  }).map( (object) => {
                    if (object.inputName)  {
                      const selector = `${BrutConstraintViolationMessages.tagName}[server-side][input-name='${object.inputName}']`
                      object.messagesElement = document.querySelector(selector)
                    }
                    return object
                  }).map( (object) => {
                    if (object.messagesElement) {
                      object.closestForm = object.messagesElement.closest("form")
                    }
                    return object
                  }).map( (object) => {
                    if (object.inputName && object.closestForm) {
                      object.input = object.closestForm.elements.namedItem(object.inputName)
                    }
                    return object
                  }).forEach( ({element,inputName,messagesElement,closestForm,input}) => {
                    if (input) {
                      if (!inputsToMessages[inputName]) {
                        inputsToMessages[inputName] = {
                          input: input,
                          messagesElement: messagesElement,
                          errorMessages: []
                        }
                      }
                      inputsToMessages[inputName].errorMessages.push(element)
                    }
                    else {
                      let reason
                      if (inputName) {
                        if (messagesElement) {
                          if (closestForm) {
                            reason = `Form did not contain an input named ${inputName}`
                          }
                          else {
                            reason = `Could not find a form that contained the ${BrutConstraintViolationMessages.tagName} element`  
                          }
                        }
                        else {
                          reason = `Could not find a ${BrutConstraintViolationMessages.tagName} element for ${inputName}`
                        }
                      }
                      else {
                        reason = "server message was missing an input-name"
                      }
                      this.#requestErrorLogger("Server message %o could not be shown to the user: %s", element,reason)
                    }
                  })

                  let firstInput
                  for (const [inputName, {input, messagesElement, errorMessages}] of Object.entries(inputsToMessages)) {
                    if (!firstInput) {
                      firstInput = input
                    }
                    messagesElement.clearMessages()
                    errorMessages.forEach( (element) => messagesElement.appendChild(element) )
                    input.setCustomValidity(errorMessages[0].textContent)
                    input.reportValidity()
                    input.addEventListener("change", () => input.setCustomValidity("") )
                  }

                  if (firstInput) {
                    firstInput.scrollIntoView()
                  }
                  resubmit = false
                  this.removeAttribute("requesting")
                  this.dispatchEvent(new CustomEvent("brut:submitinvalid"))
                }
                catch (e) {
                  this.#requestErrorLogger("While parsing %s, got %s", text, e)
                  resubmit = true
                }
                if (resubmit) {
                  this.#submitFormThroughBrowser(form)
                }
              })
            }
          }
        }
        if (retry) {
          this.#requestErrorLogger("Trying again (attempt %d)",numAttempts +1)
          setTimeout( () => this.#submitForm(form, firstSubmittedAt, numAttempts + 1), numAttempts * 10)
        }
        else if (resubmit) {
          this.#requestErrorLogger("'retry' was marked false, but resubmit is 'true', so submitting through browser")
          this.#submitFormThroughBrowser(form)
          this.removeAttribute("requesting")
        }
      }
    }).catch( (error) => {
      this.#requestErrorLogger("Got %o, which cannot be retried",error)
      this.#submitFormThroughBrowser(form)
    })
  }

  #button = () => { return this.querySelector("button") }

  #submitFormThroughBrowser(form) {
    if (this.#formSubmitDelay > 0) {
      console.log("Form submission has been delayed by %d ms in order to allow examining the log",this.#formSubmitDelay)
      setTimeout( () => form.requestSubmit(this.#button()), this.#formSubmitDelay)
    }
    else {
      form.requestSubmit(this.#button())
    }

  }
}
export default BrutAjaxSubmit

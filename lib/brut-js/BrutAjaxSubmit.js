import BaseCustomElement from "./BaseCustomElement"

/** Wraps a `<BUTTON>` assumed to be inside a form to indicate that, when clicked, it should submit
 * the form it's a part of via AJAX. It accounts for network failures and timeouts.
 * 
 * The general flow is as follows:
 *
 * 1. When the button is clicked, this element will be given the `requesting` attribute.
 * 2. The request will be initiated, set to abort after `request-timeout` ms (see below).
 * 3. If the request returns OK:
 *    - `requesting` will be removed and `submitted` will be added.
 *    - `submitted` will be removed after `submitted-lifetime` ms.
 * 4. If the request returns not OK:
 *    - if it has been `request-timeout` ms or more since the button was first clicked, the operation is aborted (see below).
 *    - if it has been less than `request-timeout` ms and the HTTP status code was 5xx, the operation is retried.
 *    - otherwise, the operation is aborted.
 * 5. If fetch throws an error, the operation is aborted.
 *
 * Aborting the operation will submit the form in the normal way, allowing the browser to deal with whatever the issue is. You can set
 * `log-request-errors` to introspect this process.
 *
 * @property {number} request-timeout - number of ms that the entire operation is expected to complete within. Default is 5000
 * @property {number} submitted-lifetime - number of ms that "submitted" should remain on the element after the form has completed. Default is 5000
 * @property {boolean} requesting - boolean attribute that indicates the request has been made, but not yet returned. Don't set this yourself outside of development. It will be set and removed by this element.
 * @property {boolean} submitted - boolean attribute that indicates the form has been successfully submitted. Don't set this yourselr outside of develoment. It will be set and removed by this element.
 * @property {boolean} log-request-errors - if set, logging related to request error handling will appear in the console. It will also
 * cause any form submission to be delayed by 2s to allow you to read the console.
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
  #submittedLifetime  = 5000
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
      throw `submitted-lifetime must be a number, not '${newValue}'`
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

  #buttonClick = (event) => {
    const button = event.target
    const form   = button.form

    event.preventDefault()

    const now = Date.now()
    this.#submitForm(form, now, 0)
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

    if (numAttempts > 100) {
      this.#requestErrorLogger("%d attempts. Giving up",numAttempts)
      return
    }
    this.setAttribute("requesting", true)
    fetch(request).then( (response) => {
      this.removeAttribute("requesting")
      if (response.ok) {
        this.setAttribute("submitted",true)
        setTimeout( () => this.removeAttribute("submitted"), this.#submittedLifetime )
      }
      else {
        let retry = false
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
          }
        }
        if (retry) {
          this.#requestErrorLogger("Trying again (attempt %d)",numAttempts +1)
          this.#submitForm(form, firstSubmittedAt, numAttempts + 1)
        }
        else {
          this.#submitFormThroughBrowser(form)
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
      setTimeout( () => form.submit(), this.#formSubmitDelay)
    }
    else {
      form.submit()
    }

  }

  render() {
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
    button.addEventListener("click", this.#buttonClick)
  }
}
export default BrutAjaxSubmit

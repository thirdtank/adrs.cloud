import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutAjaxSubmit from "./BrutAjaxSubmit"
import BrutConstraintViolationMessages from "./BrutConstraintViolationMessages"

/** A web component that enhances a form it contains to make constraint validations
 * easier to manage and control.
 *
 * This provides two main features:
 *
 * * Using the `:invalid` pseudo selector isn't great, because freshly rendered forms
 *   that have `required` elements will match the `:invalid` selector. You really want
 *   to only show errors if the user has tried to submit the form.  Thus, the `FORM` inside
 *   this custom element will be given the attribute `data-submitted` if a submission
 *   has been attempted.  This allows you to target your CSS at invalid inputs
 *   only when submission has occured.
 * * You may wish to control the messaging of client-side constraint violations
 *   beyond what the browser gives you. Assuming your `INPUT` tags are inside a container
 *   like `LABEL`, a `brut-constraint-violation-messages` tag found in that container
 *   (i.e. a sibling of your `INPUT`) will be modified to contain error messages specific
 *   to the {@link external:ValidityState} of the control.
 *
 * @fires brut:invalid Fired when any element is found to be invalid
 * @fires brut:valid Fired when no element is found to be invalid.  This should be reliable to know
 * when constraint violations have cleared.
 *
 * @example <caption>Basic Structure Required</caption>
 * <brut-form>
 *   <form ...>
 *     <label>
 *       <input type="text" required name="username">
 *       <brut-constraint-violation-messages>
 *       </brut-constraint-violation-messages>
 *     </label>
 *     <div> <!-- container need not be a label -->
 *       <input type="text" required minlength="4" name="alias">
 *       <brut-constraint-violation-messages>
 *       </brut-constraint-violation-messages>
 *     </div>
 *   </form>
 * </brut-form>
 *
 * @see BrutConstraintViolationMessages
 */
class BrutForm extends BaseCustomElement {
  static tagName = "brut-form"
  static observedAttributes = [
    "show-warnings",
  ]

  #markFormSubmitted = (event) => {
    const form = event.target.form
    if (!form) {
      this.logger.warn("%o had no form",event.target)
      return
    }
    form.dataset["submitted"] = true
  }
  #updateValidity = (event) => {
    this.#updateErrorMessages(event)
  }
  #sendValid = () => {
    this.dispatchEvent(new CustomEvent("brut:valid"))
  }
  #sendInvalid = () => {
    this.dispatchEvent(new CustomEvent("brut:invalid"))
  }

  update() {
    const forms = this.querySelectorAll("form")
    if (forms.length == 0) {
      this.logger.warn("Didn't find any forms. Ignoring")
      return
    }
    forms.forEach( (form) => {
      Array.from(form.elements).forEach( (formElement) => {
        formElement.addEventListener("invalid", this.#updateValidity)
        formElement.addEventListener("invalid", this.#markFormSubmitted)
        formElement.addEventListener("input", this.#updateValidity)
      })
      form.querySelectorAll(BrutAjaxSubmit.tagName).forEach( (ajaxSubmits) => {
        ajaxSubmits.addEventListener("brut:submitok", this.#sendValid)
        ajaxSubmits.addEventListener("brut:submitinvalid", this.#sendInvalid)
      })
    })
  }

  #updateErrorMessages(event) {
    const element = event.target
    const selector = `${BrutConstraintViolationMessages.tagName}:not([server-side])`
    const errorLabels = element.parentNode.querySelectorAll(selector)
    if (errorLabels.length == 0) {
      this.logger.warn(`Did not find any elements matching ${selector}, so no error messages will be shown`)
      return
    }
    let anyErrors = false
    errorLabels.forEach( (errorLabel) => {
      if (element.validity.valid) {
        errorLabel.clearMessages()
      }
      else {
        anyErrors = true
        errorLabel.createMessages({
          validityState: element.validity,
          inputName: element.name
        })
      }
    })
    if (anyErrors) {
      this.#sendInvalid()
    }
    else {
      this.#sendValid()
    }
  }
}
export default BrutForm

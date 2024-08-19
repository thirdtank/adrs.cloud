import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
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

  #updateInputValidity
  #markFormSubmitted

  constructor() {
    super()
    this.#updateInputValidity = (event) => this.#updateValidity(event.target)
    this.#markFormSubmitted   = (event) => {
      const form = event.target.form
      if (!form) {
        this.logger.warn("%o had no form",event.target)
        return
      }
      form.dataset["submitted"] = true
    }
  }

  render() {
    const forms = this.querySelectorAll("form")
    if (forms.length == 0) {
      this.logger.warn("Didn't find any forms. Ignoring")
      return
    }
    forms.forEach( (form) => {
      Array.from(form.elements).forEach( (formElement) => {
        formElement.addEventListener("invalid", this.#updateInputValidity)
        formElement.addEventListener("invalid", this.#markFormSubmitted)
        formElement.addEventListener("input", this.#updateInputValidity)
      })
    })
  }

  #updateValidity(element) {
    if (element.validity.valid) {
      return
    }
    const errorLabels = element.parentNode.querySelectorAll(BrutConstraintViolationMessages.tagName)
    if (errorLabels.length == 0) {
      this.logger.warn(`Did not find any '${BrutConstraintViolationMessages.tagName}' elements, so no error messages will be shown`)
      return
    }
    errorLabels.forEach( (errorLabel) => {
      errorLabel.createMessages({
        validityState: element.validity,
        inputName: element.name
      })
    })
  }
}
export default BrutForm

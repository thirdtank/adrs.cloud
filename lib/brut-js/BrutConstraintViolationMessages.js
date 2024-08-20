import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"

/**
 * Custom element to translate keys from {@link external:ValidityState} into 
 * actual messges for a human.  This works by inserting `<brut-constraint-violation-message>` elements
 * as children, where the key represents the particular errors present in the `ValidityState` passed
 * to `createMessages`.
 *
 * @see BrutForm
 * @see BrutConstraintViolationMessage
 */
class BrutConstraintViolationMessages extends BaseCustomElement {
  static tagName = "brut-constraint-violation-messages"

  /** 
   * Creates error messages based on the passed `ValidityState` and input name.
   *
   * This should be called as part of a Form validation event to provide a customized UX for
   * the error messages, beyond what the browser would do by default.  The keys used are the same
   * as the attributes of a `ValidityState`, so for example, a range underflow would mean that `validity.rangeUnderflow` would return
   * true.  Thus, a `<brut-constraint-violation-message>` would be created with `key="cv.fe.rangeUnderflow"`.
   *
   * The `cv.fe` is hard-coded to be consistent with Brut's server-side translation management.
   *
   * @param {ValidityState} validityState - the return from an element's `validity` when it's found to have constraint violations.
   * @param {String} inputName - the element's `name`.
   */
  createMessages({validityState,inputName}) {
    const errors = this.#VALIDITY_STATE_ATTRIBUTES.filter( (attribute) => validityState[attribute] )
    this.textContent = ""
    errors.forEach( (key) => {
      const element = document.createElement("brut-constraint-violation-message")
      element.setAttribute("key",`cv.fe.${key}`)
      element.setAttribute("input-name",inputName)
      element.setAttribute("show-warnings",this.getAttribute("show-warnings"))
      this.appendChild(element)
    })
  }

  #VALIDITY_STATE_ATTRIBUTES = [
    badInput,
    customError,
    patternMismatch,
    rangeOverflow,
    rangeUnderflow,
    stepMismatch,
    tooLong,
    tooShort,
    typeMismatch,
    valueMissing,
  ]
}
export default BrutConstraintViolationMessages

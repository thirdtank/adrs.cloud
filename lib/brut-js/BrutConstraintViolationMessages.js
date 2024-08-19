import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"

/**
 * Custom element to translate keys from {@link external:ValidityState} into 
 * actual messges for a human.
 *
 * @see BrutForm
 */
class BrutConstraintViolationMessages extends BaseCustomElement {
  static tagName = "brut-constraint-violation-messages"

  createMessages({validityState,inputName}) {
    const errors = Object.keys(this.#VALIDITY_STATE_ATTRIBUTES).filter( (attribute) => validityState[attribute] )
    this.textContent = ""
    errors.forEach( (key) => {
      const element = document.createElement("brut-constraint-violation-message")
      element.setAttribute("key",`cv.fe.${key}`)
      element.setAttribute("inputName",inputName)
      element.setAttribute("show-warnings",this.getAttribute("show-warnings"))
      this.appendChild(element)
    })
  }

  #VALIDITY_STATE_ATTRIBUTES = {
    badInput: "Wrong type of data",
    customError: "custom error",
    patternMismatch: "Isn't in the right format",
    rangeOverflow: "Is too big",
    rangeUnderflow: "Is too small",
    stepMismatch: "Is not a valid value in the range",
    tooLong: "Is too long",
    tooShort: "Is too short",
    typeMismatch: "Is of the wrong type",
    valueMissing: "Is required",
  }
}
export default BrutConstraintViolationMessages

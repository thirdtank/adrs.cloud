import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"

export default class BrutConstraintViolationMessages extends BaseCustomElement {
  static tagName = "brut-constraint-violation-messages"

  set validity(validityState) {
    const errors = Object.keys(this.#VALIDITY_STATE_ATTRIBUTES).filter( (attribute) => validityState[attribute] )
    this.textContent = errors.map( (key) => this.#VALIDITY_STATE_ATTRIBUTES[key] ).join(", ")
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


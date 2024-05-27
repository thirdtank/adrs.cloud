import { BaseCustomElement } from "brut-js"

class BrutConstraintViolationMessages extends BaseCustomElement {
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

class BrutForm extends BaseCustomElement {
  static tagName = "brut-form"
  static observedAttributes = [
    "show-warnings",
  ]
  connectedCallback() {
    const forms = this.querySelectorAll("form")
    if (forms.length == 0) {
      this.logger.warn("Didn't find any forms. Ignoring")
      return
    }
    forms.forEach( (form) => {
      Array.from(form.elements).forEach( (formElement) => {
        formElement.addEventListener("invalid", (event) =>{
          form.dataset["submitted"] = true
          this.#updateValidity(event.target)
        })
        formElement.addEventListener("input", (event) => this.#updateValidity(event.target) )
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
      errorLabel.validity = element.validity
    })
  }
}
BrutForm.define()
BrutConstraintViolationMessages.define()

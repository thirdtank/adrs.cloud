import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutConstraintViolationMessages from "./BrutConstraintViolationMessages"

export default class BrutForm extends BaseCustomElement {
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

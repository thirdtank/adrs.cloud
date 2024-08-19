import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutI18nTranslation from "./BrutI18nTranslation"

class BrutConstraintViolationMessage extends BaseCustomElement {
  static tagName = "brut-constraint-violation-message"

  static observedAttributes = [
    "show-warnings",
    "key",
    "inputName",
  ]

  #key = null
  #inputNameKey = null
  #thisFieldKey = "cv.this_field"

  keyChangedCallback({newValue}) {
    this.#key = newValue
  }

  inputNameChangedCallback({newValue}) {
    this.#inputNameKey = `cv.fe.fieldNames.${newValue}`
  }

  render() {
    if (!this.#key) {
      this.logger.info("No key attribute, so can't do anything")
      return
    }

    const selector = `${BrutI18nTranslation.tagName}[key='${this.#key}']`
    const translation = document.querySelector(selector)
    if (!translation) {
      this.logger.info("Could not find translation based on selector '%s'",selector)
      return
    }

    const fieldNameSelector = `${BrutI18nTranslation.tagName}[key='${this.#inputNameKey}']`
    const thisFieldSelector = `${BrutI18nTranslation.tagName}[key='${this.#thisFieldKey}']`

    let fieldNameTranslation = document.querySelector(fieldNameSelector)
    if (!fieldNameTranslation) {
      this.logger.info("Could not find translation for input/field name based on selector '%s'. Will try 'this field' fallback",fieldNameSelector)
      fieldNameTranslation = document.querySelector(thisFieldSelector)
      if (!fieldNameTranslation) {
        this.logger.info("Could not find translation for 'this field' fallback key, based on selector '%s'",thisFieldSelector)
      }
    }
    
    const fieldName = fieldNameTranslation.translate()
    this.textContent = RichString.fromString(translation.translate({ field: fieldName })).capitalize().toString()
  }

}
export default BrutConstraintViolationMessage

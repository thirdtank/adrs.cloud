import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutI18nTranslation from "./BrutI18nTranslation"

/** Renders a translated message for a given key, handling all the needed interpolation based
 * on the existence of `<brut-i18n-translation>` elements on the page.
 *
 * When the `key` attribute has a value, this element will locate the `<brut-i18-translation>` element and call `translate`.  It will
 * attempt to pass in the input's name as the key `field`.  It will determine the input's name as follows:
 *
 * 1. It will look for a `<brut-i18n-translation>` element with the `key` `general.cv.fe.fieldNames.«input-name»`.
 * 1. If that's not found, it will attempt to use "this field" by locating a `<brut-i18n-translation>` element with the `key`
 *    `general.cv.this_field` (the underscore being what is used on Brut's server side).
 * 1. If that is not found, it will "humanize" the name, e.g. `first_name` becomes "First Name". This is hard-coded to English,
 *    so be sure to provide the necessary translations.
 *
 * @property {string} key - the i18n translation key to use.  It must map to the `key` of a `<brut-i18n-translation>` on the page or
 * the element will not render any text.
 * @property {string} input-name - the name of the input, used to insert into the message, e.g. "Title is required".
 *
 * @see BrutI18nTranslation
 * @see BrutConstraintViolationMessages
 */
class BrutConstraintViolationMessage extends BaseCustomElement {
  static tagName = "brut-constraint-violation-message"

  static observedAttributes = [
    "show-warnings",
    "key",
    "input-name",
  ]

  #key = null
  #inputNameKey = null
  #thisFieldKey = "general.cv.this_field"

  keyChangedCallback({newValue}) {
    this.#key = newValue
  }

  inputNameChangedCallback({newValue}) {
    this.#inputNameKey = `general.cv.fe.fieldNames.${newValue}`
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

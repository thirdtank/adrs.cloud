import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutI18nTranslation from "./BrutI18nTranslation"

/** Like {@link BrutMessage} but specific to constraint violations of input fields.  This accepts the name
 * of an input field via `input-name`, which can be used to locate the field's localized name.
 *
 * Here is how the field's name is determined:
 *
 * 1. It will look for a `<brut-i18n-translation>` element with the `key` `general.cv.fe.fieldNames.«input-name»`.
 * 2. If that's not found, it will attempt to use "this field" by locating a `<brut-i18n-translation>` element with the `key`
 *    `general.cv.this_field` (the underscore being what is used on Brut's server side).
 * 3. If that is not found, it will use the literaly string "this field" and emit a console warning.
 *
 * @property {string} key - the i18n translation key to use.  It must map to the `key` of a `<brut-i18n-translation>` on the page or
 * the element will not render any text.
 * @property {string} input-name - the name of the input, used to insert into the message, e.g. "Title is required".
 *
 * @see BrutI18nTranslation
 * @see BrutConstraintViolationMessages
 * @see BrutMessage
 */
class BrutConstraintViolationMessage extends BaseCustomElement {
  static tagName = "brut-constraint-violation-message"

  static observedAttributes = [
    "show-warnings",
    "key",
    "input-name",
  ]

  static createElement(document,attributes) {
    const element = document.createElement(BrutConstraintViolationMessage.tagName)
    element.setAttribute("key",this.i18nKey("fe", attributes.key))
    element.setAttribute("input-name",attributes["input-name"])
    element.setAttribute("show-warnings",attributes["show-warnings"])
    return element
  }

  /** Returns the I18N key used for front-end constraint violations. This is useful
   * if you need to construct a key and want to follow Brut's conventions on how they
   * are managed.
   *
   * @param {...String} keyPath - parts of the path of the key after the namespace that Brut manages.
   */
  static i18nKey(...keyPath) {
    const path = [ "general", "cv" ]
    return path.concat(keyPath).join(".")
  }

  #key          = null
  #inputNameKey = null
  #thisFieldKey = this.#i18nKey("this_field")

  keyChangedCallback({newValue}) {
    this.#key = newValue
  }

  inputNameChangedCallback({newValue}) {
    this.#inputNameKey = this.#i18nKey("fe", "fieldNames", newValue)
  }

  update() {
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
        console.warn("Could not find translation for 'this field' fallback key, based on selector '%s'",thisFieldSelector)
      }
    }
    
    const fieldName = fieldNameTranslation ? fieldNameTranslation.translation() : "this field"
    this.textContent = RichString.fromString(translation.translation({ field: fieldName })).capitalize().toString()
  }

  /** Helper that calls the static version */
  #i18nKey(...keyPath) {
    return this.constructor.i18nKey(...keyPath)
  }


}
export default BrutConstraintViolationMessage

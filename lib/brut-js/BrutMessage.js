import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutI18nTranslation from "./BrutI18nTranslation"

/** Renders a translated message for a given key, handling all the needed interpolation based
 * on the existence of `<brut-i18n-translation>` elements on the page.
 *
 * When the `key` attribute has a value, this element will locate the `<brut-i18-translation>` element and call `translate`.
 *
 * @property {string} key - the i18n translation key to use.  It must map to the `key` of a `<brut-i18n-translation>` on the page or
 * the element will not render any text.
 *
 * @see BrutI18nTranslation
 * @see BrutConstraintViolationMessage
 */
class BrutMessage extends BaseCustomElement {
  static tagName = "brut-message"

  static observedAttributes = [
    "show-warnings",
    "key",
  ]

  static createElement(document,attributes) {
    const element = document.createElement(BrutMessage.tagName)
    element.setAttribute("key",attributes.key)
    element.setAttribute("show-warnings",attributes["show-warnings"])
    return element
  }

  #key = null

  keyChangedCallback({newValue}) {
    this.#key = newValue
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

    this.textContent = RichString.fromString(translation.translation()).capitalize().toString()
  }

}
export default BrutMessage

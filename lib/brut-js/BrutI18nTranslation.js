import BaseCustomElement from "./BaseCustomElement"

class BrutI18nTranslation extends BaseCustomElement {
  static tagName = "brut-i18n-translation"

  static observedAttributes = [
    "show-warnings",
    "key",
    "value",
  ]

  #key = null
  #value = ""

  keyChangedCallback({newValue}) {
    this.#key = newValue
  }

  valueChangedCallback({newValue}) {
    this.#value = newValue ? String(newValue) : ""
  }

  translate(interpolatedValues) {
    return this.#value.replaceAll(/%\{([^}%]+)\}/g, (match,key) => {
      if (interpolatedValues[key]) {
        return interpolatedValues[key]
      }
      return match
    })
  }

}
export default BrutI18nTranslation

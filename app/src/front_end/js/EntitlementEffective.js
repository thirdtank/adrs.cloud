import { BaseCustomElement } from "brut-js"

class EntitlementEffective extends BaseCustomElement {
  static tagName = "adr-entitlement-effective"

  static observedAttributes = [
    "entitlement",
    "show-warnings",
  ]

  #entitlement = null
  #overrideChanged = (event) => {
    if (!this.#entitlement) {
      return
    }
    const $default = document.querySelector(`adr-entitlement-default[entitlement='${this.#entitlement}']`)

    if (!$default) {
      this.logger.info("Could not find find default element for entitlement %s",this.#entitlement)
      return
    }
    if (event.target.value) {
      if (event.target.checkValidity()) {
        this.textContent = event.target.value
      }
      else {
        this.textContent = ""
      }
    }
    else {
      this.textContent = $default.textContent
    }
  }

  entitlementChangedCallback({newValue}) {
    this.#entitlement = newValue
  }

  render() {
    if (!this.#entitlement) {
      return
    }
    const $override = document.querySelector(`adr-entitlement-override[entitlement='${this.#entitlement}']`)
    if (!$override) {
      this.logger.info("Could not find find override element for entitlement %s",this.#entitlement)
    }

    const input = $override.querySelector("input")
    if (!input) {
      this.logger.info("Inside %o, did not find an input",$override)
      return
    }
    input.addEventListener("input",this.#overrideChanged)
  }
}

export default EntitlementEffective

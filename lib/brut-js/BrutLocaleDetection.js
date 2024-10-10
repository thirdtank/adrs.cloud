import BaseCustomElement from "./BaseCustomElement"

class BrutLocaleDetection extends BaseCustomElement {
  static tagName = "brut-locale-detection"

  static observedAttributes = [
    "locale-from-server",
    "timezone-from-server",
    "show-warnings",
  ]

  #localeFromServer   = null
  #timezoneFromServer = null

  localeFromServerChangedCallback({newValue}) {
    this.#localeFromServer = newValue
  }

  timezoneFromServerChangedCallback({newValue}) {
    this.#timezoneFromServer = newValue
  }

  update() {
    setTimeout(this.#pingServerWithLocaleInfo.bind(this), 1000)
  }

  #pingServerWithLocaleInfo() {
    if (this.#localeFromServer && this.#timezoneFromServer) {
      this.logger.info("locale and timezone both set, not contacting server")
      return
    }
    const formatOptions = Intl.DateTimeFormat().resolvedOptions()
    window.fetch("/__brut/locale",{
      body: JSON.stringify({
        locale: formatOptions.locale,
        timeZone: formatOptions.timeZone,
      }),
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    }).then( (response) => {
      if (response.ok) {
        this.logger.info("Server gave us the OK") 
      }
      else {
        console.warn(response)
      }
    }).catch( (e) => {
      console.warn(e)
    })
  }


}
export default BrutLocaleDetection

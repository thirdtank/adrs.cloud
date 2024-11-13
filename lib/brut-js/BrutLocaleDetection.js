import BaseCustomElement from "./BaseCustomElement"

class BrutLocaleDetection extends BaseCustomElement {
  static tagName = "brut-locale-detection"

  static observedAttributes = [
    "locale-from-server",
    "timezone-from-server",
    "url",
    "show-warnings",
  ]

  #localeFromServer   = null
  #timezoneFromServer = null
  #reportingURL       = null

  localeFromServerChangedCallback({newValue}) {
    this.#localeFromServer = newValue
  }

  timezoneFromServerChangedCallback({newValue}) {
    this.#timezoneFromServer = newValue
  }

  urlChangedCallback({newValue}) {
    this.#reportingURL = newValue
  }

  update() {
    setTimeout(this.#pingServerWithLocaleInfo.bind(this), 1000)
  }

  #pingServerWithLocaleInfo() {
    if (!this.#reportingURL) {
      this.logger.info("no url= set, so nowhere to report to")
      return
    }
    if (this.#localeFromServer && this.#timezoneFromServer) {
      this.logger.info("locale and timezone both set, not contacting server")
      return
    }
    const formatOptions = Intl.DateTimeFormat().resolvedOptions()
    window.fetch(this.#reportingURL,{
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

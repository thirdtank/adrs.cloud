import { BaseCustomElement } from "brut-js"

class CheckDownload extends BaseCustomElement {
  static tagName = "adr-check-download"

  static observedAttributes = [
    "ready",
    "download-url",
    "request-timeout",
    "log-request-errors",
    "show-warnings",
  ]

  #downloadURL        = null
  #isReady            = false
  #timeoutId          = null
  #requestTimeout     = 5000
  #requestErrorLogger = () => {}
  #reloadDelay        = 0

  downloadUrlChangedCallback({newValue}) {
    try {
      this.#downloadURL = new URL(newValue,window.location)
    }
    catch (e) {
      this.#downloadURL = null
      this.logger.warn("download-url '%s' could not be parsed as a URL: %s",newValue,e)
    }
  }

  requestTimeoutChangedCallback({newValue}) {
    const newValueAsInt = parseInt(newValue)
    if (isNaN(newValueAsInt)) {
      throw `request-timeout must be a number, not '${newValue}'`
    }
    this.#requestTimeout = newValueAsInt
  }

  readyChangedCallback({newValueAsBoolean}) {
    this.#isReady = newValueAsBoolean
  }

  logRequestErrorsChangedCallback({newValueAsBoolean}) {
    if (newValueAsBoolean) {
      this.#requestErrorLogger = console.warn
      this.#reloadDelay = 10000
    }
    else {
      this.#requestErrorLogger = () => {}
      this.#reloadDelay = 0
    }
  }

  #checkDownload(numAttempts=0,delay=500) {
    if (!this.#downloadURL) {
      this.logger.warn("download-url has been removed - checking will stop")
      return
    }
    if (numAttempts > 25) {
      this.#requestErrorLogger("Too many attempts. Stopping")
      return
    }

    const headers = new Headers()
    const timeoutSignal = AbortSignal.timeout(this.#requestTimeout)

    const request = new Request(
      this.#downloadURL,
      {
        headers: headers,
        method: "get",
        signal: timeoutSignal,
      }
    )
    fetch(request).then( (response) => {
      if (response.ok) {
        response.text().then( (text) => {
          try {
            const parser = new DOMParser()
            const fragment = parser.parseFromString(text,"text/html")
            Array.from(this.children).forEach( (child) => this.removeChild(child) )
            Array.from(fragment.body.children).forEach( (child) => this.appendChild(child) )
            this.setAttribute("ready",true)
            this.#timeoutId = null
          }
          catch (e) {
            this.#requestErrorLogger("While parsing %o, got %o",text,e)
            this.#reloadPage()
          }
        })
      }
      else {
        const status = parseInt(response.status)
        if (status == 404) {
          this.#timeoutId = setTimeout( () => {
            this.#checkDownload(numAttempts+1,delay * 1.3)
          }, delay)
        }
        else {
          this.#requestErrorLogger("Got status %o which was not expected. Should've gotten 200 or 404",response)
          this.#reloadPage()
        }
      }
    }).catch( (error) => {
      this.#requestErrorLogger("Got %o",error)
      this.#reloadPage()
    })
  }

  #reloadPage() {
    return
    if (this.#reloadDelay > 0) {
      console.log("Delaying the reload to allow you to read these errors")
      setTimeout(() => { window.location.reload() },this.#reloadDelay)
    }
    else {
      window.location.reload()
    }
  }

  update() {
    if (this.#isReady) {
      if (this.#timeoutId) {
        clearTimeout(this.#timeoutId)
        this.#timeoutId = null
      }
    }
    else {
      if (!this.#timeoutId && this.#downloadURL) {
        this.#timeoutId = setTimeout(this.#checkDownload.bind(this),500)
      }
    }
  }

}
export default CheckDownload

import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"

export default class BrutConfirmationDialog extends BaseCustomElement {
  static tagName = "brut-confirmation-dialog"
  static observedAttributes = [
    "message",
    "show-warnings"
  ]

  constructor() {
    super()
    this.onClose = () => {}
    this.okListener = (event) => {
      this.#closeDialog()
      this.onClose(true)
    }
    this.cancelListener = (event) => {
      this.#closeDialog()
      this.onClose(false)
    }
    this.message = new RichString("")
  }

  messageChangedCallback({newValue}) {
    this.message = RichString.fromString(newValue)
  }

  showModal(onClose) {
    const dialog = this.#dialog
    if (dialog) {
      this.onClose = onClose || (() => {})
      dialog.showModal()
    }
    else {
      this.logger.warn("No <dialog> found to show")
    }
  }

  get #dialog() {
    return this.querySelector("dialog")
  }

  #closeDialog() {
    const dialog = this.#dialog
    if (dialog) {
      dialog.close()
    }
  }

  render() {
    const dialog = this.#dialog
    if (!dialog) {
      this.logger.warn("Could not find a <dialog> - this custom element won't do anything")
      return
    }
    const h1 = dialog.querySelector("h1")
    if (h1) {
      if (this.message.isBlank()) {
        h1.textContent = null
      }
      else {
        h1.textContent = this.message.toString()
      }
    }
    else {
      this.logger.warn("Dialog had no <h1>, so nowhere to put the message")
    }
    const okButton = this.querySelector("button[value='ok']")
    const cancelButton = this.querySelector("button[value='cancel']")
    if (okButton && cancelButton) {
      okButton.addEventListener("click", this.okListener)
      cancelButton.addEventListener("click", this.cancelListener)
    }
    else {
      if (!okButton)     { this.logger.warn("no <button value='ok'> which is required for this dialog to work") }
      if (!cancelButton) { this.logger.warn("no <button value='cancel'> which is required for this dialog to work") }
    }
  }
}

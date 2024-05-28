import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutConfirmationDialog from "./BrutConfirmationDialog"

/* Confirms any buttons found inside it. Confirmation can be done
 * with window.confirm or with a brut-confirmation-dialog.
 */
export default class BrutConfirm extends BaseCustomElement {
  static tagName = "brut-confirm"

  static observedAttributes = [
    "message",
    "dialog-id",
    "show-warnings",
  ]

  messageChangedCallback({newValue}) {
    this.message = new RichString(newValue || "")
  }

  dialogIdChangedCallback({newValue}) {
    this.dialogId = newValue
  }

  constructor() {
    super()
    this.message = new RichString("")
    this.confirming = false
    this.onClick = (event) => {
      if (this.confirming) {
        this.logger.warn("Since we are confirming, letting the click go through")
        this.confirming = false
        return
      }
      if (this.message.isBlank()) {
        this.logger.warn("No message provided, so cannot confirm")
        return
      }
      const dialog = this.#findDialog()
      if (dialog) {
        event.preventDefault()
        dialog.setAttribute("message",this.message.toString())
        this.confirming = true
        dialog.showModal((confirm) => {
          if (confirm) {
            event.target.click()
          }
          else {
            this.confirming = false
          }
        })
      }
      else {
        const result = window.confirm(this.message)
        if (!result) {
          event.preventDefault()
        }
      }
    }
  }

  #findDialog() {
    if (this.dialogId) {
      const dialog = document.getElementById(this.dialogId)
      if (dialog) {
        if (dialog.tagName.toLowerCase() != BrutConfirmationDialog.tagName) {
          throw `${this.dialogId} is the id of a '${dialog.tagName}', not '${BrutConfirmationDialog.tagName}'`
        }
        return dialog
      }
      this.logger.warn(`No dialog with id ${this.dialogId} - using window.confirm as a fallback`)
      return null
    }
    const dialogs = document.querySelectorAll(BrutConfirmationDialog.tagName)
    if (dialogs.length == 1) {
      return dialogs[0]
    }
    if (dialogs.length == 0) {
      this.logger.warn(`No '${BrutConfirmationDialog.tagName}' found in document - using window.confirm as a fallback`)
      return null
    }
    throw `Found ${dialogs.length} '${BrutConfirmationDialog.tagName}' elements. Not sure which to use. Remove all but one or specify dialog-id on this element to specify which one to use`
  }

  render() {
    this.querySelectorAll("button").forEach( (button) => button.addEventListener("click", this.onClick) )
    this.querySelectorAll("input[type=button]").forEach( (button) => button.addEventListener("click", this.onClick) )
  }
}

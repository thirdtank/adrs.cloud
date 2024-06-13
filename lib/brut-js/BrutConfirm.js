import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutConfirmationDialog from "./BrutConfirmationDialog"

/** Confirms button presses with the user before allowing the button's
 * action to complete.  This operates on all `BUTTON` and `INPUT[type=button]` elements
 * it finds, but does *not* operate on `A` (links).
 *
 * This can ask for confirmation with {@link external:Window#confirm} or a
 * `brut-confirmation-dialog`. What it will use depends on several factors, all of which
 * are geared toward doing the right thing. Note that setting `show-warnings` will elucidate the reasons
 * this component does what it does.
 *
 * * If `dialog-id` is set:
 *   - If that id is on a `<brut-confirmation-dialog>` that is used.
 *   - If not, `window.confirm` is used.
 * * If `dialog-id` is not set:
 *   - If there is exactly one `<brut-confirmation-dialog>` on the page, this is used.
 *   - If there is more than one, or no `<brut-confirmation-dialog>`s, `window.confirm` is used.
 *
 * @see BrutConfirmationDialog
 *
 * @property {string} message - the message to show that asks for confirmation. It should be written such that
 *                              "OK" is grammatically correct for confirmation and "Cancel" is for aborting.
 * @property {string} dialog-id - optional ID of the `brut-confirmation-dialog` to use instead of `window.confirm`.
 *                                If there is no such dialog or the id references the wrong element type,
 *                                `window.confirm` will be used.  Setting `show-warnings` will generate a warning for this.
 */
class BrutConfirm extends BaseCustomElement {
  static tagName = "brut-confirm"

  static observedAttributes = [
    "message",
    "dialog-id",
    "show-warnings",
  ]

  #message      = new RichString("")
  #confirming   = false
  #dialogId     = null

  messageChangedCallback({newValue}) {
    this.#message = new RichString(newValue || "")
  }

  dialogIdChangedCallback({newValue}) {
    this.#dialogId = RichString.fromString(newValue)
  }

  constructor() {
    super()
    this.onClick = (event) => {
      if (this.#confirming) {
        this.logger.warn("Since we are confirming, letting the click go through")
        this.#confirming = false
        return
      }
      if (this.#message.isBlank()) {
        this.logger.warn("No message provided, so cannot confirm")
        return
      }
      const dialog = this.#findDialog()
      if (dialog) {
        event.preventDefault()
        dialog.setAttribute("message",this.#message.toString())
        const buttonLabel = event.target.getAttribute("aria-label") || event.target.textContent
        dialog.setAttribute("confirm-label",buttonLabel)
        this.#confirming = true
        dialog.showModal((confirm) => {
          if (confirm) {
            event.target.click()
          }
          else {
            this.#confirming = false
          }
        })
      }
      else {
        const result = window.confirm(this.#message)
        if (!result) {
          event.preventDefault()
        }
      }
    }
  }

  #findDialog() {
    if (this.#dialogId) {
      const dialog = document.getElementById(this.#dialogId)
      if (dialog) {
        if (dialog.tagName.toLowerCase() != BrutConfirmationDialog.tagName) {
          throw `${this.#dialogId} is the id of a '${dialog.tagName}', not '${BrutConfirmationDialog.tagName}'`
        }
        return dialog
      }
      this.logger.warn(`No dialog with id ${this.#dialogId} - using window.confirm as a fallback`)
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
export default BrutConfirm

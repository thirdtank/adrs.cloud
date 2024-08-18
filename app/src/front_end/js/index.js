import { BaseCustomElement, RichString } from "brut-js"
import { BrutConfirm, BrutAjaxSubmit, BrutConstraintViolationMessages, BrutConfirmationDialog, BrutForm } from "brut-js"

class TagEditor extends BaseCustomElement {

  static tagName = "adr-tag-editor"

  static observedAttributes = [
    "editable",
    "show-warnings",
  ]

  #editable = false

  #openEditor = (event) => {
    event.preventDefault()
    this.setAttribute("editable",true)
  }

  #dismissEditor = (event) => {
    // For whatever reason, <button type=reset> doesn't work
    event.preventDefault()
    this.removeAttribute("editable")
    if (event.target.form) {
      event.target.form.reset()
    }
  }

  editableChangedCallback({ newValue }) {
    const isFalse = newValue === null || newValue === false
    this.#editable = !isFalse
  }

  render() {
    const view = this.querySelector("adr-tag-editor-view")
    const edit = this.querySelector("adr-tag-editor-edit")

    if (view) { this.logger.info("Found view") }
    else      { this.logger.info("Did not find an adr-tag-editor-view") }

    if (edit) { this.logger.info("Found edit") }
    else      { this.logger.info("Did not find an adr-tag-editor-edit") }

    if (view) {
      view.querySelectorAll("button").forEach( (button) => button.addEventListener("click", this.#openEditor) )
    }
    if (edit) {
      const resetButtons = edit.querySelectorAll("button[type=reset]")
      if (resetButtons.length == 0) {
        this.logger.info("Did not find any reset buttons in %o", edit)
      }
      resetButtons.forEach( (button) => button.addEventListener("click", this.#dismissEditor) )
    }
    
    if (this.#editable) {
      this.logger.info("We are editable")
      if (edit) { edit.style.display = "block" }
      if (view) { view.style.display = "none" }
    }
    else {
      this.logger.info("We are not editable")
      if (edit) { edit.style.display = "none" }
      if (view) { view.style.display = "block" }
    }
  }
}


document.addEventListener("DOMContentLoaded", () => {
  TagEditor.define()
  BrutForm.define()
  BrutConstraintViolationMessages.define()
  BrutConfirm.define()
  BrutConfirmationDialog.define()
  BrutAjaxSubmit.define()
})

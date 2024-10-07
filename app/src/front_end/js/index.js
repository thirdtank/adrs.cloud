import { BaseCustomElement, RichString } from "brut-js"
import {
  BrutConfirm,
  BrutAjaxSubmit,
  BrutConstraintViolationMessages,
  BrutConstraintViolationMessage,
  BrutConfirmationDialog,
  BrutI18nTranslation,
  BrutForm,
  BrutTabs
} from "brut-js"

class IncludeQueryParams extends BaseCustomElement {
  static tagName = "adr-include-query-params"

  static observedAttributes = [
    "show-warnings"
  ]

  #pushStateChanged = () => {
    this.render()
  }


  render() {
    const form = this.querySelector("form")
    if (!form) {
      return
    }
    window.addEventListener("popstate",this.#pushStateChanged)
    document.querySelectorAll(BrutTabs.tagName).forEach( (element) => {
      element.addEventListener("tabselected",this.#pushStateChanged)
    })
    const queryParams = new URLSearchParams(window.location.search)
    queryParams.forEach( (value,key) => {
      let foundElement = false
      Array.from(form.elements).forEach( (element) => {
        if (element.name == key) {
          foundElement = true
          if (element.dataset.adrIncludeQueryParams) {
            element.value = value
          }
          else {
            this.logger.info("Form %o had an element (%o) named %s that was not managed by %s (%s). Ignoring",
              form,element,key,this.constructor.name,
              element.dataset.adrIncludeQueryParams === undefined ? "no data-adr-include-query-params" : "data-adr-include-query-params had a blank string"
            )
          }
        }
      })
      if (!foundElement) {
        const hiddenField = document.createElement("input")
        hiddenField.setAttribute("type","hidden")
        hiddenField.setAttribute("name",key)
        hiddenField.setAttribute("value",value)
        hiddenField.dataset.adrIncludeQueryParams = true
        form.appendChild(hiddenField)
      }
    })
  }
}

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


document.addEventListener("DOMContentLoaded", () => {
  BrutI18nTranslation.define()
  TagEditor.define()
  BrutForm.define()
  BrutConstraintViolationMessages.define()
  BrutConstraintViolationMessage.define()
  BrutConfirm.define()
  BrutConfirmationDialog.define()
  BrutAjaxSubmit.define()
  BrutTabs.define()
  EntitlementEffective.define()
  IncludeQueryParams.define()
})

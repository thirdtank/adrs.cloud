import { BaseCustomElement } from "brut-js"

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
export default IncludeQueryParams

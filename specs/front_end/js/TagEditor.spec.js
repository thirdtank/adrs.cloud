import { withHTML } from "brut-js/testing/index.js"

describe("<adr-tag-editor>", () => {
  withHTML(`
  <adr-tag-editor>
    <adr-tag-editor-view>
      <button>Open Editor</button>
    </adr-tag-editor-view>
    <adr-tag-editor-edit>
      <form>
        <button>Submit Form</button>
        <button type='reset'>Dismiss Form</button>
      </form>
    </adr-tag-editor-edit>
  </adr-tag-editor>
  `).test("editor is hidden by default", ({document,assert}) => {
    const view = document.querySelector("adr-tag-editor-view")
    const edit = document.querySelector("adr-tag-editor-edit")

    assert.equal("block",view.style.display)
    assert.equal("none" ,edit.style.display)

  }).test("editor can be opened and dismissed",
    ({document,window,assert}) => {
      const view = document.querySelector("adr-tag-editor-view")
      const edit = document.querySelector("adr-tag-editor-edit")

      const editButton = view.querySelector("button")
      const form       = edit.querySelector("form")
      const resetButton = form.querySelector("button[type=reset]")

      let formSubmitted = false
      form.addEventListener("submit", (event) => {
        event.preventDefault()
        formSubmitted = true
      })

      editButton.click()

      assert.equal("none" ,view.style.display)
      assert.equal("block",edit.style.display)

      resetButton.click()

      assert.equal("block",view.style.display)
      assert.equal("none" ,edit.style.display)
      assert(!formSubmitted)
  }).test("editor can be opened and submitted",
    ({document,window,assert}) => {
      const view = document.querySelector("adr-tag-editor-view")
      const edit = document.querySelector("adr-tag-editor-edit")

      const editButton   = view.querySelector("button")
      const form         = edit.querySelector("form")
      const submitButton = form.querySelector("button:not([type=reset])")

      let formSubmitted = false
      form.addEventListener("submit", (event) => {
        event.preventDefault()
        formSubmitted = true
      })

      editButton.click()

      assert.equal("none" ,view.style.display)
      assert.equal("block",edit.style.display)

      submitButton.click()

      assert.equal("none" ,view.style.display)
      assert.equal("block",edit.style.display)
      assert(formSubmitted)
    })
})

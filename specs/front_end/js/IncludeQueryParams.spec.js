import { withHTML } from "brut-js/testing/index.js"

describe("<adr-include-query-params>", () => {
  withHTML(`
  <adr-include-query-params>
    <form>
    </form>
  </adr-include-query-params>
  `).andQueryString("foo=bar").test("creates a hidden field", ({document,window,assert}) => {
    const form = document.querySelector("form")
    const field = form.querySelector("input[type=hidden][name=foo]")
    assert.equal("bar",field.value)
  })

  withHTML(`
  <adr-include-query-params>
    <form>
    <input name="foo" type="text">
    </form>
  </adr-include-query-params>
  `).andQueryString("foo=bar").test("does not create a hidden field", ({document,window,assert}) => {
    const form = document.querySelector("form")
    const field = form.querySelector("input[type=hidden][name=foo]")
    assert(!field)
  })
})

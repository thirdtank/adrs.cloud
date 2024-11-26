import { withHTML } from "./SpecHelper.js"

describe("<adr-entitlement-effective>", () => {
  withHTML(
    `<adr-entitlement-default entitlement="max_non_rejected_adrs">
       20
     </adr-entitlement-default>
     <adr-entitlement-override entitlement="max_non_rejected_adrs">
       <input type="text" name="non_rejected">
     </adr-entitlement-override>
     <adr-entitlement-effective show-warnings="max_non_rejected_adrs" entitlement="max_non_rejected_adrs">
     </adr-entitlement-effective>`
  ).test("derives the overridden value",
    ({document,window,assert}) => {
      const input = document.querySelector("input")
      input.value = 55
      input.dispatchEvent(new window.InputEvent("input", {}))
      const effective = document.querySelector("adr-entitlement-effective")
      assert.equal(55,effective.textContent.trim())
    }).test("uses the default value", ({document,window,assert}) => {
      const input = document.querySelector("input")
      input.value = ""
      input.dispatchEvent(new window.InputEvent("input", {}))
      const effective = document.querySelector("adr-entitlement-effective")
      assert.equal(20,effective.textContent.trim())
    })
})

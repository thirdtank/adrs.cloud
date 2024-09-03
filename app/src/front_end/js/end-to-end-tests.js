import { testing } from "brut-js"

class DevLoginTest {
  constructor({arrange,act,assert,expect,fail,passed,window,document}) {
    /*
     * From home page, click the developer login button.
     * If we get to the developer login screen, fill in 'pat@example.com' for email and submit form.
     * We should get to the adrs screen
     */
    act("From home page, click login button", () => {
      const loginButton = expect(document).toHaveElement("form[action='/auth/developer'] button")
      loginButton.click()
    })
    assert("We should be on the dev login screen", () => {
      expect(window.location.pathname).toEq("/auth/developer")
    })
    act("fill in the form and submit it", () => {
      const form = expect(document).toHaveElement("form")
      const emailField = expect(form).toHaveElement("input[type=email]")
      emailField.value = "pat@example.com"
      emailField.dispatchEvent(new Event("input"))
      form.submit()
    })
    assert("we should be on the adrs screen", () => {
      expect(window.location.pathname).toEq("/adrs")
    })
  }
}

class AdrsPageTest {
  constructor({arrange,act,assert,expect,fail,passed,window,document}) {
    arrange("Log in as dev", () => {
      const loginButton = expect(document).toHaveElement("form[action='/auth/developer'] button")
      loginButton.click()
    })
    arrange("Submit login form", () => {
      expect(window.location.pathname).toEq("/auth/developer")
      const form = expect(document).toHaveElement("form")
      const emailField = expect(form).toHaveElement("input[type=email]")
      emailField.value = "pat@example.com"
      emailField.dispatchEvent(new Event("input"))
      form.submit()
    })
    assert("we should be on the adrs screen", () => {
      expect(window.location.pathname).toEq("/adrs")
    })
    assert("There should be accepted adrs", () => {
      const caption = expect(document).toHaveElement("table caption", (element) => {
        return element.textContent == "Accepted ADRs"
      })
      const tbody = expect(caption.parentElement).toHaveElement("tbody")
      expect(tbody).toHaveAtLeastElements("tr",2)
    })
    assert("There should be 4 draft adrs", () => {
      const caption = expect(document).toHaveElement("table caption", (element) => {
        return element.textContent == "Draft ADRs"
      })
      const tbody = expect(caption.parentElement).toHaveElement("tbody")
      expect(tbody).toHaveAtLeastElements("tr[title]",3)
    })
  }
}
class NewAdrTest {
  constructor({arrange,act,assert,expect,fail,wait,passed,window,document,context}) {

    const title = context.fetch("title",`ADR ${Math.random()}`)

    arrange("Log in as dev", () => {
      const loginButton = expect(document).toHaveElement("form[action='/auth/developer'] button")
      loginButton.click()
    })
    arrange("Submit login form", () => {
      expect(window.location.pathname).toEq("/auth/developer")
      const form = expect(document).toHaveElement("form")
      const emailField = expect(form).toHaveElement("input[type=email]")
      emailField.value = "pat@example.com"
      emailField.dispatchEvent(new Event("input"))
      form.submit()
    })
    assert("we should be on the adrs screen", () => {
      expect(window.location.pathname).toEq("/adrs")
    })
    act("Click to make a new one", () => {
      const link = expect(document).toHaveElement("a[href='/new_draft_adr?']")
      link.click()
    })
    assert("we should be on the adrs screen", () => {
      expect(window.location.pathname).toEq("/new_draft_adr")
    })
    assert("clicking submit shows a client-side error", () => {
      const button = expect(document).toHaveElement("button[title='Save Draft']")
      const titleField = expect(document).toHaveElement("input[name='title']")
      let validityState = null

      titleField.addEventListener("invalid", (event) => {
        validityState = event.target.validity
      })
      button.click()
      return wait( () => {
        expect(validityState).toExist()
        expect(validityState.valueMissing).toEq(true)
      })
    })
    act("filling in server-invalid data", () => {
      const button = expect(document).toHaveElement("button[title='Save Draft']")
      const titleField = expect(document).toHaveElement("input[name='title']")
      titleField.value = "foobar"
      titleField.dispatchEvent(new Event("input"))
      button.click()
    })
    assert("shows an error", () => {
      const titleField = expect(document).toHaveElement("input[name='title']")
      expect("invalid" in titleField.dataset).toEq(true, JSON.stringify(titleField.dataset))
    })
    act("filling in server-valid data", () => {
      const button = expect(document).toHaveElement("button[title='Save Draft']")
      const titleField = expect(document).toHaveElement("input[name='title']")
      titleField.value = title
      titleField.dispatchEvent(new Event("input"))
      button.click()
    })
    assert("saves it without showing an error", () => {
      const titleField = expect(document).toHaveElement("input[name='title']")
      expect("invalid" in titleField.dataset).toEq(false, JSON.stringify(titleField.dataset))
    })
    act("Going back to the adrs screen", () => {
      const back = expect(document).toHaveElement("a", (element) => {
        return element.textContent.indexOf("Back") != -1
      })
      back.click()
    })
    act("Shows the new ADR as a draft and can be edited", () => {
      const caption = expect(document).toHaveElement("table caption", (element) => {
        return element.textContent == "Draft ADRs"
      })
      const tbody = expect(caption.parentElement).toHaveElement("tbody")
      const tr = expect(tbody).toHaveElement(`tr[title='${title}']`)
      const editLink = expect(tr).toHaveElement("a", (element) => {
        return element.textContent == "Edit Draft"
      })
      editLink.click()
    })
    act("set an invalid title that the server validates", () => {
      const button = expect(document).toHaveElement("button[title='Update Draft']")
      const titleField = expect(document).toHaveElement("input[name='title']")
      const label = titleField.closest("label")
      expect(label).toExist("Expected title field to be inside a label")
      const constraintViolationMessages = expect(label).toHaveAtLeastElements("brut-constraint-violation-messages",1)

      titleField.value = "notenough"
      titleField.dispatchEvent(new Event("input"))
      let validityState
      titleField.addEventListener("invalid", (event) => {
        validityState = event.target.validity
      })
      button.click()
      return wait( () => {
        expect(validityState).toExist()
        expect(validityState.customError).toEq(true)
        constraintViolationMessages.forEach( (element) => {
          expect(window.getComputedStyle(element).display).toEq("none")
          expect(window.getComputedStyle(element).visibility).notToEq("hidden")
        })
      })
    })
    act("Sets a valid title and edits other fields", () => {
      const button = expect(document).toHaveElement("button[title='Update Draft']")
      const titleField = expect(document).toHaveElement("input[name='title']")
      titleField.value = title + " edited"
      const contextField = expect(document).toHaveElement("textarea[name='context']")
      contextField.value = "this is some context"

      const titleLabel = titleField.closest("label")
      const titleConstraintViolationMessages = expect(titleLabel).toHaveAtLeastElements("brut-constraint-violation-messages",1)
      const contextLabel = contextField.closest("label")
      const contextConstraintViolationMessages = expect(contextLabel).toHaveAtLeastElements("brut-constraint-violation-messages",1)
      button.click()
      return wait( () => {
        titleConstraintViolationMessages.forEach( (element) => {
          expect(window.getComputedStyle(element).display).toEq("none")
          expect(window.getComputedStyle(element).visibility).notToEq("hidden")
        })
        contextConstraintViolationMessages.forEach( (element) => {
          expect(window.getComputedStyle(element).display).toEq("none")
          expect(window.getComputedStyle(element).visibility).notToEq("hidden")
        })
      })
    })
    act("Reloading the page", () => {
      window.location.reload()
    })
    assert("Data is still there, indicating it has been saved", () => {
      const titleField = expect(document).toHaveElement("input[name='title']")
      const contextField = expect(document).toHaveElement("textarea[name='context']")
      expect(titleField.value).toEq(title + " edited")
      expect(contextField.value).toEq("this is some context")
    })
  }
}

window.e2eTests = {
  DevLoginTest,
  AdrsPageTest,
  NewAdrTest,
}

window.addEventListener("load", () => {
  testing.runTests()
})

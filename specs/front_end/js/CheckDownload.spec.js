import { withHTML } from "brut-js/testing/index.js"

describe("<adr-check-download>", () => {
  context("Response is good", () => {
    withHTML(`
    <adr-check-download download-url="/check-downloads">
      <div>to be replaced</div>
    </adr-check-download>
    `).onFetch("/check-downloads", {
      then: { ok: { text: "<div>here</div>" } }
    }).test("Replaces itself with whatever comes back", ({document,window,assert}) => {
      const element = document.querySelector("adr-check-download")
      return new Promise( (resolve, reject) => {
        let timeout = null
        let interval = setInterval( () => {
          if (element.getAttribute("ready") !== null) {
            assert.equal(element.innerHTML.trim(),"<div>here</div>")
            clearInterval(interval)
            interval = null
            if (timeout) {
              clearTimeout(timeout)
              timeout = null
            }
            resolve()
          }
        }, 10)
        timeout = setTimeout( () => {
          if (interval != null) {
            clearInterval(interval)
            reject("<adr-check-download> never became ready")
          }
        }, 1000)
      })
    })
  })
  context("Response is 404", () => {
    withHTML(`
    <adr-check-download download-url="/check-downloads">
      <div>to be replaced</div>
    </adr-check-download>
    `).onFetch("/check-downloads", [
        { then: { status: 404 } },
        { then: { ok: { text: "<div>here</div>" } } },
      ]
    ).test("Tries again, then replaces itself with whatever comes back", ({document,window,assert}) => {
      const element = document.querySelector("adr-check-download")
      return new Promise( (resolve, reject) => {
        let timeout = null
        let interval = setInterval( () => {
          if (element.getAttribute("ready") !== null) {
            assert.equal(element.innerHTML.trim(),"<div>here</div>")
            clearInterval(interval)
            interval = null
            if (timeout) {
              clearTimeout(timeout)
              timeout = null
            }
            resolve()
          }
        }, 10)
        timeout = setTimeout( () => {
          if (interval != null) {
            clearInterval(interval)
            reject("<adr-check-download> never became ready")
          }
        }, 2000)
      })
    })
  })
})

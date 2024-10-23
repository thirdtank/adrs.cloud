import { JSDOM, ResourceLoader, VirtualConsole } from "jsdom"
import fs from "node:fs"
import path from "node:path"
import assert from "assert"

const __dirname = import.meta.dirname

const appRoot = path.resolve(__dirname,"..","..","..","app")
const publicRoot = path.resolve(appRoot,"public")

class AssetMetadata {
  constructor(parsedJSON, publicRoot) {
    this.assetMetadata = parsedJSON.asset_metadata
    this.publicRoot    = publicRoot
  }

  scriptURLs() {
    return Object.entries(this.assetMetadata[".js"]).map( (entry) => {
      return entry[0] 
    })
  }

  fileContainingScriptURL(scriptURL) {
    const file = Object.entries(this.assetMetadata[".js"]).find( (entry) => {
      return entry[0] == scriptURL
    })
    if (!file || !file[1]) {
      return null
    }
    let relativePath = file[1]
    if (relativePath[0] == "/") {
      relativePath = relativePath.slice(1)
    }
    return fs.readFileSync(path.resolve(this.publicRoot,relativePath))
  }
}

const assetMetadata = new AssetMetadata(
  JSON.parse(fs.readFileSync(path.resolve(appRoot,"config","asset_metadata.json"))),
  publicRoot,
)

class AssetMetadataLoader extends ResourceLoader {
  constructor(assetMetadata) {
    super()
    this.assetMetadata = assetMetadata
  }

  fetch(url,options) {
    const parsedURL = new URL(url)
    const jsContents = this.assetMetadata.fileContainingScriptURL(parsedURL.pathname)
    if (jsContents) {
      return Promise.resolve(jsContents)
    }
    else {
      return super.fetch(url,options)
    }
  }
}

const resourceLoader = new AssetMetadataLoader(assetMetadata)

const createDOM = (html, queryString) => {

  const url = "http://example.com" + ( queryString ? `?${queryString}` : "" )

  const scripts = assetMetadata.scriptURLs().map( (url) => `<script src="${url}"></script>` )
  const virtualConsole = new VirtualConsole()
  virtualConsole.sendTo(console);
  return new JSDOM(
    `<!DOCTYPE html>
        <html>
        <head>
        ${scripts}
        </head>
        <body>
        ${html}
        </body>
        </html>
        `,{
          resources: "usable",
          runScripts: "dangerously",
          includeNodeLocations: true,
          resources: resourceLoader,
          url: url
        }
  )
}

class CustomElementTest {
  constructor(html, queryString) {
    this.html          = html
    this.queryString   = queryString
    this.fetchBehavior = {}
  }

  andQueryString(queryString) {
    this.queryString = queryString
    return this
  }

  onFetch(url,behavior) {
    if (!this.fetchBehavior[url]) {
      this.fetchBehavior[url] = {
        numCalls: 0,
        responses: [],
      }
    }
    if (behavior instanceof Array) {
      behavior.forEach( (b) =>  {
        this.fetchBehavior[url].responses.push(b)
      })
    }
    else {
      this.fetchBehavior[url].responses.push(behavior)
    }
    return this
  }

  test(description,testCode) {
    it(description, () => {
      const dom = createDOM(this.html,this.queryString)

      dom.window.Request = Request
      dom.window.fetch = (request) => {
        const url = new URL(request.url)
        const path = url.pathname + url.search
        const behaviors = this.fetchBehavior[path]
        if (!behaviors) {
          throw `fetch() called with ${path}, which was not configured`
        }
        if (behaviors.numCalls > behaviors.responses.length) {
          throw `fetch() called ${behaviors.numCalls} times, but we only have ${behaviors.response.length} responses configured`
        }
        const behavior = behaviors.responses[behaviors.numCalls]
        behaviors.numCalls++

        if (behavior.then) {
          if (behavior.then.ok) {
            if (behavior.then.ok.text) {
              const response = {
                ok: true,
                text: () => {
                  return Promise.resolve(behavior.then.ok.text)
                }
              }
              return Promise.resolve(response)
            }
            else {
              throw `unknown fetch behavior: expected then.ok.text: ${JSON.stringify(behavior)}`
            }
          }
          else if (behavior.then.status) {
            const response = {
              ok: false,
              status: behavior.then.status,
            }
            return Promise.resolve(response)
          }
          else {
            throw `unknown fetch behavior: expected then.ok or then.status: ${JSON.stringify(behavior)}`
          }
        }
        else {
          throw `unknown fetch behavior: expected then: ${JSON.stringify(behavior)}`
        }
      }

      const window = dom.window
      const document = window.document
      let returnValue = null
      return new Promise( (resolve, reject) => {
        dom.window.addEventListener("load", () => {
          try {
            returnValue = testCode({window,document,assert})
            if (returnValue) {
              resolve(returnValue)
            }
            else {
              resolve()
            }
          } catch (e) {
            reject(e)
          }
        })
      })
    })
    return this
  }
}
const withHTML = (html) => new CustomElementTest(html)

export {
  withHTML
}

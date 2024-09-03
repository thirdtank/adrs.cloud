class AssertionFailure extends Error {
}

class TestPassed extends Error {
}

class TestExecutionMessage {

  static failed(message,context) { return new TestExecutionMessage( { type: "failed", message: message, context: context }) }
  static passed()                { return new TestExecutionMessage( { type: "passed"}) }
  static log(message)            { return new TestExecutionMessage( { type: "log", message: message}) }

  static error(message_or_error, context) {
    let args = {
      message: message_or_error,
      context: context
    }
    if (message_or_error instanceof AssertionFailure) {
      args.type = "failed"
    }
    else {
      args.type = "error"
    }
    return new TestExecutionMessage(args)
  }

  constructor({type,message,context}) {
    this.type = type
    this.message = message
    this.context = context
    if (message instanceof Error) {
      this.errorClass = message.constructor.name
    }
  }
}

const MAX_WAIT = 1000

const runTests = () => {
  const currentTest      = window.localStorage.getItem("current-test")
  const currentStepIndex = parseInt(window.localStorage.getItem("current-test-step"))

  if (!currentTest) {
    console.log("Not running tests")
    return
  }
  const channel = new BroadcastChannel(`test:${currentTest}`)
  if (currentStepIndex === null) {
    channel.postMessage(TestExecutionMessage.error("current-test-step was not defined"))
    return
  }

  const handleError = (event,error) => {
    if (error instanceof AssertionFailure) {
      event.preventDefault()
      channel.postMessage(TestExecutionMessage.failed(error,error.stack))
    }
    else if (error instanceof TestPassed) {
      event.preventDefault()
      channel.postMessage(TestExecutionMessage.passed())
    }
    else {
      channel.postMessage(TestExecutionMessage.error(error, `${event.filename}:${event.lineno}, ${event.filename}:${event.lineno}`))
    }
  }

  window.addEventListener("unhandledrejection", (event) => handleError(event,event.reason) )
  window.addEventListener("error", (event) => handleError(event,event.error) )

  const testClass = e2eTests[currentTest]
  if (!testClass) {
    alert(`No such test: ${testClass}`)
    return
  }

  let steps = []
  const arrange = (description,code) => {
    steps.push({
      description: description,
      code: () => {
        try { 
          code() 
        }
        catch (error) {
          return Promise.reject(error) 
        }
        return new Promise(function(resolve) {
          setTimeout(resolve, MAX_WAIT);
        })
      }
    })
  }
  const act = (description,code) => {
    steps.push({
      description: description,
      code: () => {
        try { 
          code()
        }
        catch (error) {
          return Promise.reject(error)
        }
        return new Promise(function(resolve) {
          setTimeout(resolve, MAX_WAIT);
        })
      }
    })
  }
  const assert = (description,code) => {
    steps.push({
      description: description,
      code: () => {
        try { 
          const returnValue = code()
          if (returnValue instanceof Promise) {
            return returnValue
          }
        }
        catch (error) {
          return Promise.reject(error)
        }
        return Promise.resolve()
      }
    })
  }
  const wait = (code,attempts=0) => {
    try {
      code()
      return Promise.resolve()
    }
    catch (error) {
      if (attempts > 50) {
        alert("Giving up")
        return Promise.reject(error)
      }
      return new Promise( (resolve,reject) => {
        setTimeout(
          () => {
            wait(code,attempts+1).then( () => resolve )
          },
          (MAX_WAIT / 50) * 2
        )
      })
    }
  }

  const context = new TestContext(window.localStorage)

  const test = new testClass({
    expect: expect,
    fail: fail,
    arrange: arrange,
    act: act,
    wait: wait,
    assert: assert,
    passed: passed,
    context: context,
    window: window,
    document: document,
  })

  if (currentStepIndex == steps.length) {
    channel.postMessage(TestExecutionMessage.passed())
    return
  }

  let currentStep = steps[currentStepIndex]

  window.localStorage.setItem("current-test-step",String(currentStepIndex + 1))
  channel.postMessage(TestExecutionMessage.log(`Running step ${currentStepIndex}, ${currentStep.description}`))
  currentStep.code().then( () => {
    runTests() 
  }).catch( (error) => {
    channel.postMessage(TestExecutionMessage.error(error, `Step ${currentStepIndex} error: ${error}`))
    window.localStorage.removeItem("current-test-step")
    window.localStorage.removeItem("current-test")
  })
}

class TestContext {
  #context
  #localStorage
  constructor(localStorage) {
    this.#localStorage = localStorage
    try {
      this.#context = JSON.parse(this.#localStorage.getItem("current-test-context"))
    }
    catch (error) {
      console.warn(error)
    }
    if (!this.#context) {
      this.#context = {}
    }
  }

  fetch(key,valueIfNull) {
    if (!(key in this.#context)) {
      this.store(key,valueIfNull)
    }
    return this.#context[key]
  }

  store(key,value) {
    this.#context[key] = value
    this.save()
  }

  save() {
    this.#localStorage.setItem("current-test-context",JSON.stringify(this.#context))
  }

}

class Expectation {
  #thing
  constructor(thing) {
    this.#thing = thing
  }

  toEq(otherThing,context="") {
    if (this.#thing != otherThing) {
      throw new AssertionFailure(`Expected '${this.#thing}' to eq '${otherThing}' ${context}`.trim())
    }
  }
  notToEq(otherThing,context="") {
    if (this.#thing == otherThing) {
      throw new AssertionFailure(`Expected '${this.#thing}' not to eq '${otherThing}' ${context}`.trim())
    }
  }
  toExist(description) {
    if (!this.#thing) {
      if (description) {
        throw new AssertionFailure(`Expected ${description} to exist`)
      }
      else {
        throw new AssertionFailure("Expected something to exist")
      }
    }
  }
  toHaveElement(selector,test) {
    return this.toHaveElements(selector,1,test)[0]
  }
  toHaveElements(selector,count,test) {
    if (!test) {
      test = () => true
    }
    let countTest = count
    if (Number.isInteger(count)) {
      countTest = {
        description: `Exactly ${count}`,
        test: (numElements) => count == numElements
      }
    }
    const elements         = Array.from(this.#thing.querySelectorAll(selector))
    const filteredElements = elements.filter( (element) => {
      const result = test(element) 
      if ((result === true) || (result === false)) {
        return result
      }
      throw new AssertionFailure(`filter for elements didn't return true or false, instead returned ${result}`)
    })

    if (countTest.test(filteredElements.length)) {
      return filteredElements
    }
    console.log("[toHaveElements] searched %o",this.#thing)
    throw new AssertionFailure(`Expected ${countTest.description} via selector '${selector}' from ${this.#thing.tagName || this.#thing.constructor.name}, but got ${filteredElements.length} (${elements.length} before filtering)`)
  }
  toHaveAtLeastElements(selector,minCount,test) {
    const countTest = {
      description: `at least ${minCount}`,
      test: (numElements) => numElements >= minCount
    }
    return this.toHaveElements(selector,countTest,test)
  }
}

const expect = (thing)   => new Expectation(thing)
const fail   = (message) => {
  throw new AssertionFailure(message)
}
const passed = () => {
  throw new TestPassed()
}
const testing = {
  runTests: runTests,
}
export default testing

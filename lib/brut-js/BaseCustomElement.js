import Logger from "./Logger"
import RichString from "./RichString"

/** Base class for Custom Elements that provides a few quality-of-life enhancements.
  * Many custom elements need to re-execute their core logic when attributes change, as well as
  * when they are connected to the DOM.  This class provides some light structure to make that easier
  * to implement.
  *
  * ### Using this Class
  *
  * * Extend it via `extends BaseCustomElement`
  * * Create a static property called `tagName` that will be your element's tag name. Remember that all tag names must have a
  *   dash in them.
  * * Create a static property called `observedAttributes` that is an array of attribute names your element supports. This is 
  *   part of the HTML spec and not specific to this base class.
  * * If you include the attribute `show-warnings` in your list of `observedAttributes`, you will have enhanced debugging
  *   abilities.
  * * For each attribute *other* than `show-warnings`, implement a callback to receive notifications on the attribute's
  *   changes. See {@link attributeChangedCallback} for more info.
  * * Implement `render` to execute whatever logic the component needs.  `render` will be called multiple times and
  *   thus should be relatively idempotent.  Specifically, it will be called after any attribute has changed, and it
  *   will be called as part of the standard `connectedCallback`.
  * * To use your component, call the static {@link define} method.
  *
  * ### Debugging
  *
  * Custom Elements have to work under a variety of degenerate cirucmstances.  Further, if you are building 
  * elements that wrap and enhance conventional elements, it can be easy to make a mistake, for example intending
  * to wrap a `FORM`, but wrapping only an `INPUT`.
  *
  * To help debug these situations, you are encouraged to use `this.logger.warn(...)` to emit warnings when
  * potentially incorrect use of your component is detected.  By default, these warnings will not be shown. This
  * provides your users with a drama-free console.  During development, however, you can add the `show-warnings`
  * attribute to your element.  If that is set, warnings *are* shown in the console.
  *
  * `show-warnings` can be given a value, in which case that value if used to prefix all warnings the element emits.
  * This can be useful to know which use of an element is causing problems.  If you don't give any value
  * to `show-warnings`, the element's `id` will be used as the prefix.  If the element has no `id`, you will
  * still see warnings, but without a prefix. This could make it hard to know where the warnings are coming from.
  *
  * @example
  * // Replaces all span elements inside the component with
  * // an upper-cased value of the attribute 'some-attribute'
  * class MyComponent extends BaseCustomElement {
  *   static tagName = "my-component"
  *   static observedAttributes = [
  *     "show-warnings",
  *     "some-attribute",
  *   ]
  *
  *   someAttributeChangedCallback({newValue}) {
  *     this.someAttribute = newValue ? newValue.toUpperCase() : null
  *   }
  *
  *   render() {
  *     const spans = this.querySelectorAll("span")
  *     if (spans.length == 0) {
  *       this.logger.warn("Did not find any <span> elements - element won't do anything")
  *     }
  *     spans.forEach( (element) => {
  *       element.textContent = this.someAttribute
  *     })
  *   }
  * }
  * MyComponent.define()
  *
  * // Then, in your HTML
  * <my-component some-attribute="hello there">
  *   <span></span>
  *   <div></div>
  *   <span></span>
  * </my-component>
  *
  * // The browser will effectively produce this HTML:
  * <my-component some-attribute="hello there">
  *   <span>HELLO THERE</span>
  *   <div></div>
  *   <span>HELLO THERE</span>
  * </my-component>
  *
  * // If JavaScript (or browser dev tools) changed some-attribute
  * // to be "goodbye then", the markup will change to look like so:
  * <my-component some-attribute="goodby then">
  *   <span>GOODBYE THEN</span>
  *   <div></div>
  *   <span>GOODBYE THEN</span>
  * </my-component>
  */
class BaseCustomElement extends HTMLElement {

  /** A {@link Logger} you can use to write warning messages.  By default, these
   * messages are not shown in the console. If you put `show-warnings` as an attribute on your
   * element, warnings sent to this logger *are* shown.
   */
  logger = Logger.forPrefix(null)
  constructor() {
    super()
    this.logger = Logger.forPrefix(null)
  }

  /** You must call this to define the custom element.  This is bascially
   * a wrapper around `customElements.define`.
   * 
   * @see external:CustomElementRegistry
   */
  static define() {
    if (!this.tagName) {
      throw `To use BaseCustomElement, you must define the static member tagName to return your custom tag's name`
    }
    customElements.define(this.tagName, this)
  }

  showWarningsChangedCallback({oldValue,newValue}) {
    let oldLogger
    if (!oldValue && newValue) {
      oldLogger = this.logger
    }
    const prefix = newValue == "" ? this.id : newValue
    this.logger = Logger.forPrefix(prefix)
    if (oldLogger) {
      this.logger.dump(oldLogger)
    }
  }

  /**
   * Overrides the standard callback to allow subclasses to have a slightly easier API when responding
   * to attribute changes. You can override this to use the custom element callback directly. Note that if
   * you do, `show-warnings` will not have any affect and you probably don't need to bother using
   * this class as your base class.
   *
   * This method will locate a per-attribute method and call that.
   * Attribute names are assumed to be in kebab-case and are translated to camelCase to create a method name.
   * That method is `«attributeInCamelCase»ChangedCallback`, so if your attribute is `hex-code`,
   * a method named `hexCodeChangedCallback` in invoked.  If no such method is defined, a
   * warning is logged in the console, regardless of the `show-warnings` attribute.
   *
   * The method is invoked with `{oldValue,newValue}` - i.e. an object and not positional parameters. This 
   * means your implementation can omit any parameters it doesn't care about.
   *
   * The return value of the method is ignored.
   *
   * After your method is called, if there is a method named `render`, it is called with no arguments.
   *
   * What this allows you to do is separate how you manage your element's attributes from how your logic
   * is managed. For complex elements that take a lot of attributes, this can simplify your element's code without straying too far from the spec.
   *
   * @example
   *
   * // If your element accepts the attribute `warning-message` that will be trimmed of whitespace
   * // then placed into all `H1` tags inside the element, you can manage that like so:
   * class MyElement extends BaseCustomElement {
   *   static tagName = "my-element"
   *   static observedAttributes = [
   *     "warning-message",
   *   ]
   *
   *   // called by attributeChangedCallback when warning-message's value changes
   *   warningMessageChangedCallback({newValue}) {
   *     this.warningMessage = (newValue || "").trim()
   *   }
   *
   *   // called after attributeChangedCallback calls warningMessageChangedCallback
   *   render() {
   *     this.querySelectorAll("h1").forEach( (e) => e.textContent = this.warningMessage )
   *   }
   * }
   *
   *
   * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements}
   *
   */
  attributeChangedCallback(name,oldValue,newValue) {
    const callbackName = `${new RichString(name).camelize()}ChangedCallback`
    if (this[callbackName]) {
      this[callbackName]({oldValue,newValue})
    }
    else if (this.constructor.observedAttributes.indexOf(name) != -1) {
      console.warn("Observing %s but no method named %s was found to handle it",name,callbackName)
    }
    this.__render()
  }
  
  /** Overrides the custom element callback to set internal flags allowing you to know if your
   * element has been disconnected. When an element is disconnected, `render` is not called.
   *
   * If you want to add your own logic during disconnection, override {@link onDisconnected}.
   *
   * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements}
   */
  disconnectedCallback() {
    this.__disconnected = true
    this.__connected = false
    this.onDisconnected()
  }

  /** Override this to add logic when `disconnectedCallback` is called by the browser.  This will
   * not be called if you overrode `disconnectedCallback`.
   */
  onDisconnected() {}

  /** Overrides the custom element callback to set internal flags allowing you to know if your
   * element has been connected. `render` is still called for elements that have not yet connected, however
   * in practice your element will be connected before any codepath that calls `render` is called.
   *
   * To add logic when your element is connected, override {@link onConnected}
   *
   * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements}
   * @see BaseCustomElement#isConnected
   */
  connectedCallback() {
    this.__connected = true
    this.__disconnected = false
    this.onConnected()
    this.__render()
  }

  /** Override this to add logic when `connectedCallback` is called by the browser. This will
   * not be called if you overrode `connectedCallback`
   */
  onConnected() {}

  /** Returns true if this element is connected.  It's false before it's been connected as well as after
   * it has been disconnected
   */
  get isConnected() { return !!this.__connected }

  /** Override this to perform whatever logic your element must perform.
   * Because changes to your element's attributes can happen at any time and in any order,
   * you will want to consolidate all logic into one method—this one. You will also
   * want to make sure that this method is idempotent and fault-tolerant.
   *
   * It is called by {@link BaseCustomElement#attributeChangedCallback|attributeChangedCallback} and {@link BaseCustomElement#connectedCallback|connectedCallback}, however
   * it will *not* be called after the elment has been disconnected.
   *
   * That means that any event listeners, rendering, content manipulation, or other behavior should happen hear
   * and it *must* be idempotent.  In particular, any event listeners you attach must be done with care. Using
   * anonymous functions could result in duplicate listeners.
   */
  render() {}


  __render() {
    if (this.__disconnected) {
      return
    }
    this.render()
  }
}
export default BaseCustomElement

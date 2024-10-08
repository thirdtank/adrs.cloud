import BaseCustomElement from "./BaseCustomElement"
import RichString from "./RichString"
import BrutConstraintViolationMessage from "./BrutConstraintViolationMessage"

/**
 * Custom element to translate keys from {@link external:ValidityState} into 
 * actual messges for a human.  This works by inserting `<brut-constraint-violation-message>` elements
 * as children, where the key represents the particular errors present in the `ValidityState` passed
 * to `createMessages`.
 *
 * @property {boolean} server-side if true, this indicates the element contains constraint violation messages
 *                                 from the server.  Currently doesn't affect this element's behavior, however
 *                                 BrutAjaxSubmit will use it to locate where it should insert server-side errors.
 * @property {string} input-name if set, this indicates this element contains constraint violation messages
 *                               for the input with this name inside the form this element is in. Currently doesn't affect
 *                               this element's behavior, however BrutAjaxSubmit will use it to locate where it 
 *                               should insert server-side errors.
 *
 * @see BrutForm
 * @see BrutConstraintViolationMessage
 * @see BrutAjaxSubmit
 */
class BrutConstraintViolationMessages extends BaseCustomElement {
  static tagName = "brut-constraint-violation-messages"

  static observedAttributes = [
    "show-warnings",
    "server-side",
    "input-name",
  ]


  serverSideChangedCallback({newValueAsBoolean}) {
    // attribute listed for documentation purposes only
  }
  inputNameChangedCallback({newValue}) {
    // attribute listed for documentation purposes only
  }

  /** 
   * Creates error messages based on the passed `ValidityState` and input name.
   *
   * This should be called as part of a Form validation event to provide a customized UX for
   * the error messages, beyond what the browser would do by default.  The keys used are the same
   * as the attributes of a `ValidityState`, so for example, a range underflow would mean that `validity.rangeUnderflow` would return
   * true.  Thus, a `<brut-constraint-violation-message>` would be created with `key="general.cv.fe.rangeUnderflow"`.
   *
   * The `cv.fe` is hard-coded to be consistent with Brut's server-side translation management.
   *
   * @param {ValidityState} validityState - the return from an element's `validity` when it's found to have constraint violations.
   * @param {String} inputName - the element's `name`.
   */
  createMessages({validityState,inputName}) {
    const errors = this.#VALIDITY_STATE_ATTRIBUTES.filter( (attribute) => validityState[attribute] )
    this.clearMessages()
    errors.forEach( (key) => {
      const element = BrutConstraintViolationMessage.createElement(document,
        {
          key: key,
          "input-name": inputName,
          "show-warnings": this.getAttribute("show-warnings")
        }
      )
      this.appendChild(element)
    })
  }

  /**
   * Clear all messages. Useful for when an input has become valid during a session.
   */
  clearMessages() {
    this.textContent = ""
  }

  #VALIDITY_STATE_ATTRIBUTES = [
    "badInput",
    "customError",
    "patternMismatch",
    "rangeOverflow",
    "rangeUnderflow",
    "stepMismatch",
    "tooLong",
    "tooShort",
    "typeMismatch",
    "valueMissing",
  ]
}
export default BrutConstraintViolationMessages

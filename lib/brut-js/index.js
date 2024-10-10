import BaseCustomElement               from "./BaseCustomElement"
import RichString                      from "./RichString"
import BrutAjaxSubmit                  from "./BrutAjaxSubmit"
import BrutConfirm                     from "./BrutConfirm"
import BrutConfirmationDialog          from "./BrutConfirmationDialog"
import BrutConstraintViolationMessage  from "./BrutConstraintViolationMessage"
import BrutConstraintViolationMessages from "./BrutConstraintViolationMessages"
import BrutForm                        from "./BrutForm"
import BrutI18nTranslation             from "./BrutI18nTranslation"
import BrutMessage                     from "./BrutMessage"
import BrutTabs                        from "./BrutTabs"
import BrutLocaleDetection             from "./BrutLocaleDetection"
import testing                         from "./testing"

/**
 * @external ValidityState
 * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/ValidityState|ValidityState}
 */

/**
 * The standard `CustomElementRegistry`
 *
 * @external CustomElementRegistry
 * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/CustomElementRegistry|CustomElementRegistry}
 */

/**
 * @external Window
 * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/Window/|Window}
 */

/** 
 * @method confirm
 * @memberof external:Window#
 * @see {@link https://developer.mozilla.org/en-US/docs/Web/API/Window/confirm|confirm}
 */

/**
 * Class that can be used to automatically define all of brut's custom
 * elements.
 */
class BrutCustomElements {
  static elementClasses = []
  static define() {
    console.log("Defining all classes")
    this.elementClasses.forEach( (e) => {
    console.log("Defining %s",e.name)
      e.define() 
    })
  }
  static addElementClasses(...classes) {
    this.elementClasses.push(...classes)
  }
}

BrutCustomElements.addElementClasses(
  BrutConfirm,
  BrutConfirmationDialog,
  BrutConstraintViolationMessages,
  BrutForm,
  BrutAjaxSubmit,
  BrutConstraintViolationMessage,
  BrutI18nTranslation,
  BrutTabs,
  BrutMessage,
  BrutLocaleDetection,
)

export {
  BaseCustomElement,
  BrutConfirm,
  BrutConfirmationDialog,
  BrutConstraintViolationMessages,
  BrutForm,
  BrutAjaxSubmit,
  BrutConstraintViolationMessage,
  BrutI18nTranslation,
  BrutTabs,
  RichString,
  BrutMessage,
  BrutCustomElements,
  BrutLocaleDetection,
  testing
}

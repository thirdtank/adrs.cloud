import { BaseCustomElement, RichString } from "brut-js"
import {
  BrutConfirm,
  BrutAjaxSubmit,
  BrutConstraintViolationMessages,
  BrutConstraintViolationMessage,
  BrutConfirmationDialog,
  BrutI18nTranslation,
  BrutForm,
  BrutTabs
} from "brut-js"

import IncludeQueryParams from "./IncludeQueryParams"
import TagEditor from "./TagEditor"
import EntitlementEffective from "./EntitlementEffective"

document.addEventListener("DOMContentLoaded", () => {
  BrutI18nTranslation.define()
  TagEditor.define()
  BrutForm.define()
  BrutConstraintViolationMessages.define()
  BrutConstraintViolationMessage.define()
  BrutConfirm.define()
  BrutConfirmationDialog.define()
  BrutAjaxSubmit.define()
  BrutTabs.define()
  EntitlementEffective.define()
  IncludeQueryParams.define()
})

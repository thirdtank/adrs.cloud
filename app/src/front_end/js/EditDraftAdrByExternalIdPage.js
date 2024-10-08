import { BaseCustomElement, BrutForm, BrutConstraintViolationMessage } from "brut-js"
import AnnouncementBanner from "./AnnouncementBanner"

class EditDraftAdrByExternalIdPage extends BaseCustomElement {
  static tagName = "adr-edit-draft-by-external-id-page"

  static observedAttributes = [
    "show-warnings",
  ]

  #showConstraintValidationError = (event) => {
    const announcement = this.querySelector(AnnouncementBanner.tagName)
    if (!announcement) {
      this.logger.info("Could not find %s, so not adding any behavior",AnnouncementBanner.tagName)
    }
    announcement.setAttribute("shown-role","alert")
    announcement.setAttribute("shown-message-key","pages.EditDraftAdrByExternalIdPage.adr_not_updated")
  }

  #clearConstraintValidationError = (event) => {
    const announcement = this.querySelector(AnnouncementBanner.tagName)
    if (!announcement) {
      this.logger.info("Could not find %s, so not adding any behavior",AnnouncementBanner.tagName)
    }

    announcement.setAttribute("shown-role","status")
    announcement.setAttribute("shown-message-key","pages.EditDraftAdrByExternalIdPage.adr_updated")

    setTimeout( () => {
      announcement.removeAttribute("shown-role")
      announcement.removeAttribute("shown-message-key")
    }, 3000)
  }

  update() {
    const brutForm = this.querySelector(BrutForm.tagName)
    if (!brutForm) {
      this.logger.info("Could not find a %s, so not adding any behavior",BrutForm.tagName)
    }

    brutForm.addEventListener("brut:invalid", this.#showConstraintValidationError)
    brutForm.addEventListener("brut:valid", this.#clearConstraintValidationError)
  }
}

export default EditDraftAdrByExternalIdPage

import { BaseCustomElement, BrutMessage } from "brut-js"

class AnnouncementBanner extends BaseCustomElement {
  static tagName = "adr-announcement-banner"

  static observedAttributes = [
    "shown-role",
    "default-shown-role",
    "shown-message-key",
    "show-warnings",
  ]

  #shownMessageKey  = null
  #shownRole        = null
  #defaultShownRole = "note"

  static ROLES = [
    "alert",
    "status",
    "note",
  ]

  shownRoleChangedCallback({newValue}) {
    if (AnnouncementBanner.ROLES.indexOf(newValue) != -1) {
      this.#shownRole = newValue
    }
    else {
      this.#shownRole = null
    }
  }
  defaultShownRoleChangedCallback({newValue}) {
    if (AnnouncementBanner.ROLES.indexOf(newValue) != -1) {
      this.#defaultShownRole = newValue
    }
    else {
      this.#defaultShownRole = "note"
    }
  }

  shownMessageKeyChangedCallback({newValue}) {
    this.#shownMessageKey = newValue
  }

  update() {
    const roleToShow = this.#shownRole || this.#defaultShownRole
    this.querySelectorAll("[role]").forEach( (element) => {
      element.querySelectorAll(`p,${BrutMessage.tagName}`).forEach( (child) => {
        if (child.dataset.appendedBy == AnnouncementBanner.tagName) {
          element.removeChild(child)
        }
        else if (child.dataset.hiddenBy == AnnouncementBanner.tagName) {
          child.removeAttribute("hidden")
        }
      })

      if (element.getAttribute("role") == roleToShow) {
        element.removeAttribute("hidden")
        if (this.#shownMessageKey) {
          // Hide all existing <p> elements
          element.querySelectorAll(`p,${BrutMessage.tagName}`).forEach( (child) => {
            child.dataset.hiddenBy = AnnouncementBanner.tagName
            child.setAttribute("hidden",true) 
          })
          const newChild = BrutMessage.createElement(document,{key:this.#shownMessageKey})
          newChild.dataset.appendedBy = AnnouncementBanner.tagName
          element.appendChild(newChild)
        }
      }
      else {
        // Hide the role
        element.setAttribute("hidden",true)
      }
    })
  }


}
export default AnnouncementBanner

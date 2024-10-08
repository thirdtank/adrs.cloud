import { BrutCustomElements } from "brut-js"
import IncludeQueryParams from "./IncludeQueryParams"
import TagEditor from "./TagEditor"
import EntitlementEffective from "./EntitlementEffective"
import EditDraftAdrByExternalIdPage from "./EditDraftAdrByExternalIdPage"
import AnnouncementBanner from "./AnnouncementBanner"

document.addEventListener("DOMContentLoaded", () => {
  BrutCustomElements.define()
  TagEditor.define()
  EntitlementEffective.define()
  IncludeQueryParams.define()
  EditDraftAdrByExternalIdPage.define()
  AnnouncementBanner.define()
})

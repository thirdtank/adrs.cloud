# This is included in AppComponent and AppPage
# and allows you to add global helpers to every component
# or page as needed.
module AppViewHelpers
  def adr_path(adr) = Brut.container.routing.for(AdrsByExternalIdPage, external_id: adr.external_id)
end

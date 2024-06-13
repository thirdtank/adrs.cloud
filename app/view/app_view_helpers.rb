# This is included in AppComponent and AppPage
# and allows you to add global helpers to every component
# or page as needed.
module AppViewHelpers
  def adr_path(adr) = "/adrs/#{adr.external_id}"
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"
end

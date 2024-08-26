# This is included in AppComponent and AppPage
# and allows you to add global helpers to every component
# or page as needed.
module AppViewHelpers
  def adr_path(adr) = "/adrs/#{adr.external_id}"
  def public_adr_path(adr)
    if !adr.public?
      raise Brut::BackEnd::Errors::Bug, "#{adr.external_id} is not public - this should not have been called"
    end
    "/p/adrs/#{adr.public_id}"
  end
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"
end

class SetSiteAnnouncementBeforeHook < Brut::FrontEnd::RouteHook
  def before(request_context:)
    request_context[:site_announcement] = :current_site_announcement
    continue
  end
end

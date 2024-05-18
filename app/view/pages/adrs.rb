class Pages::Adrs < AppPage

  def accepted_adrs = @content.select(&:accepted?).sort_by(&:accepted_at)
  def draft_adrs    = @content.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @content.select(&:rejected?).sort_by(&:rejected_at)

  def adr_path(adr)      = "/adrs/#{adr.external_id}"
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"

end

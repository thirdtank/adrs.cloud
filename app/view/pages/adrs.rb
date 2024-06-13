class Pages::Adrs < AppPage

  def accepted_adrs = @content.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @content.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @content.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @content.select(&:rejected?).sort_by(&:rejected_at)
end

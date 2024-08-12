class Pages::AdrsForTag < AppPage
  attr_reader :tag
  def initialize(adrs:, tag:)
    @adrs = adrs
    @tag = tag
  end
  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
end

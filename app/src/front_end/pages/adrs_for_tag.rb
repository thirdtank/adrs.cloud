class Pages::AdrsForTag < AppPage
  attr_reader :tag
  def initialize(tag:, account:)
    @adrs = Actions::Adrs::Search.new.by_tag(account: account, tag: tag)
    @tag = tag
  end
  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
end

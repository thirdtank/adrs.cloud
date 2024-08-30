class Pages::Adrs < AppPage

  attr_reader :info_message

  def initialize(account:, info_message: nil)
    @adrs         = account.adrs
    @info_message = info_message
  end
  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @adrs.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @adrs.select(&:rejected?).sort_by(&:rejected_at)

end

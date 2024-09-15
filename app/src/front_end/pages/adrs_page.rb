class AdrsPage < AppPage

  attr_reader :info_message, :tag

  def initialize(account:, flash:, tag: nil)
    @info_message = flash.notice
    @tag          = tag
    @adrs         = AccountAdrs.search(account:,tag:).adrs

    num_non_rejected_adrs = @adrs.length - self.rejected_adrs.length

    @can_add_new  = AccountEntitlements.new(account:).can_add_new?
  end
  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @adrs.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @adrs.select(&:rejected?).sort_by(&:rejected_at)

  def tag? = !!@tag

  def can_add_new? = @can_add_new

end

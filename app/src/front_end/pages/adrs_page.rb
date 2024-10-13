class AdrsPage < AppPage

  attr_reader :tag, :tab, :entitlements, :authenticated_account

  def initialize(authenticated_account:, tag: nil, tab: "accepted")
    @authenticated_account = authenticated_account
    @tag                   = tag
    @adrs                  = @authenticated_account.adrs.search(tag:)

    num_non_rejected_adrs = @adrs.length - self.rejected_adrs.length

    @entitlements = @authenticated_account.entitlements
    @tab          = tab.to_sym
  end

  def filtered_by_tag? = !!@tag

  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @adrs.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @adrs.select(&:rejected?).sort_by(&:rejected_at)

  def can_add_new? = @entitlements.can_add_new?

end
require_relative "adrs_page/tab_panel_component"
require_relative "adrs_page/tab_component"
require_relative "adrs_page/adr_title_component"


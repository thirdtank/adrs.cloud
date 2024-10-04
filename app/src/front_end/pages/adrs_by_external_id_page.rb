class AdrsByExternalIdPage < AppPage
  attr_reader :adr

  def initialize(authenticated_account:, external_id:)
    @adr          = authenticated_account.adrs.find!(external_id:)
    @can_add_new  = authenticated_account.entitlements.can_add_new?
  end

  def can_add_new? = @can_add_new
  def can_edit_tags? = self.accepted?

  def markdown(field)
    value = t("fields.#{field}", content: adr.send(field))
    component(MarkdownStringComponent.new(value))
  end

  def refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?)
  end

  def editable? = !adr.accepted? && !adr.rejected?
  def draft? = self.editable?
  def accepted? = adr.accepted?

  def private? = !self.shared?
  def shared?  =  adr.shared?

  def accepted_i18n_key = adr.replaced? ? :originally_accepted : :accepted

  def tags = Tags.from_array(array: adr.tags(phony_shared: false))

  def banner(**args,&block)
    component(self.class::BannerComponent.new(**args),&block)
  end

end

require_relative "adrs_by_external_id_page/banner_component"

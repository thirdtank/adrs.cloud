class AdrsByExternalIdPage < AppPage
  attr_reader :adr, :info_message

  def initialize(authenticated_account:, external_id:, flash:)
    @adr          = authenticated_account.adrs.find!(external_id:)
    @info_message = flash.notice
    @can_add_new  = authenticated_account.entitlements.can_add_new?
  end

  def can_add_new? = @can_add_new

  def markdown(field)
    value = t("fields.#{field}", content: adr.send(field))
    component(MarkdownStringComponent.new(value))
  end

  def refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?)
  end

  def editable? = !adr.accepted? && !adr.rejected?
  def draft? = self.editable?

  def private? = !self.shared?
  def shared?  =  adr.shared?

  def accepted_i18n_key = adr.replaced? ? :originally_accepted : :accepted

  def tags = Tags.from_array(array: adr.tags(phony_shared: false))

end


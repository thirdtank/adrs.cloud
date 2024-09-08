class AdrsByExternalIdPage < AppPage
  attr_reader :adr, :info_message

  def initialize(account:, external_id:, flash:)
    @adr = DataModel::Adr[account_id: account.id, external_id: external_id]
    @info_message = flash.notice
  end

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

end


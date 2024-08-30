class AdrsByExternalIdPage < AppPage
  attr_reader :adr, :info_message

  def initialize(account:, external_id:, flash:)
    @adr = DataModel::Adr[account_id: account.id, external_id: external_id]
    @info_message = flash[:notice]
  end

  def markdown(field)
    value = "**#{field_text(field)}** #{adr.send(field)}"
    component(Components::MarkdownString.new(value))
  end

  def refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?)
  end

  def editable? = !adr.accepted? && !adr.rejected?
  def draft? = self.editable?

  def private? = !self.public?
  def public?  =  adr.public?
  def public_path = Brut.container.routing.for(PublicAdrsByPublicIdPage, public_id: adr.public_id)

private

  def field_text(field)
    case field
    when :context   then "In the context of"
    when :facing    then "Facing"
    when :decision  then "We decided"
    when :neglected then "Neglecting"
    when :achieve   then "To achieve"
    when :accepting then "Accepting"
    when :because   then "Because"
    else raise ArgumentError.new("No such field '#{field}'")
    end
  end
end


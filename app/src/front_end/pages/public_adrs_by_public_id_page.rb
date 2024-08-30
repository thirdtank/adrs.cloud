class PublicAdrsByPublicIdPage < AppPage
  attr_reader :adr, :account

  def initialize(public_id:, account:)
    @adr = DataModel::Adr[public_id: public_id]
    @account = account
  end

  def markdown(field)
    value = "**#{field_text(field)}** #{adr.send(field)}"
    component(Components::MarkdownString.new(value))
  end

  def public_refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?).select(&:public?)
  end

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


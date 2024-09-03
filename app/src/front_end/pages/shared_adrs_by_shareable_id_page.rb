class SharedAdrsByShareableIdPage < AppPage
  attr_reader :adr, :account

  def initialize(shareable_id:, account:)
    if shareable_id.nil?
      raise ArgumentError,"shareable_id may not be nil"
    end
    @adr = DataModel::Adr[shareable_id: shareable_id]
    @account = account
  end

  def markdown(field)
    value = "**#{field_text(field)}** #{adr.send(field)}"
    component(Components::MarkdownString.new(value))
  end

  def shareable_refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?).select(&:shared?)
  end

  def shareable_path(adr)
    if !adr.shared?
      raise Brut::BackEnd::Errors::Bug, "#{adr.external_id} is not share - this should not have been called"
    end
    Brut.container.routing.for(self.class,shareable_id: adr.shareable_id)
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


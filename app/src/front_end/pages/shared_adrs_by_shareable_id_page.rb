class SharedAdrsByShareableIdPage < AppPage
  attr_reader :adr

  def initialize(shareable_id:)
    @adr = DB::Adr.find!(shareable_id:)
  end

  def markdown(field)
    value = t("fields.#{field}", content: adr.send(field))
    component(MarkdownStringComponent.new(value))
  end

  def shareable_refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?).select(&:shared?)
  end

  def shareable_path(adr)
    if !adr.shared?
      raise Brut::BackEnd::Errors::Bug, "#{adr.external_id} is not share - this should not have been called"
    end
    self.class.routing(shareable_id: adr.shareable_id)
  end
end


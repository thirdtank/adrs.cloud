class SharedAdrsByShareableIdPage < AppPage
  attr_reader :adr

  def initialize(shareable_id:)
    @adr = DB::Adr.find!(shareable_id:)
  end

  def field(name, label_additional_clases: "")
    html_tag(:section, "aria-label": name, class: "flex flex-column gap-2 ph-3") {
      html_tag(:h4, class: "ma-0 f-1 ttu fw-6 #{label_additional_clases}") {
        t(page: [ :fields, name ])
      } + html_tag(:div, class: "measure-wide rendered-markdown") {
        component(MarkdownStringComponent.new(adr.send(name)))
      }
    }
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


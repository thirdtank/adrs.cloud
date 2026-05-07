class AcceptedAdrsByProjectExternalIdPage < AppPage
  def initialize(project_external_id:)
    @project = DB::Project.find!(external_id: project_external_id)
    @adrs = DB::Adr.where(project: @project, replaced_by_adr_id: nil).exclude(accepted_at: nil).exclude(shareable_id: nil).order(:accepted_at)
  end

  def page_template
    h1 { "Architectural Decisions for Project '#{@project.name}'" }
    @adrs.each  do |adr|
      section(id: adr.external_id) do
        h2 { adr.title }
        div do
          strong do
            render(MarkdownStringComponent.new(adr.decision))
          end
        end
        field(adr:, name: "context")
        field(adr:, name: "facing")
        field(adr:, name: "neglected")
        field(adr:, name: "achieve")
        field(adr:, name: "accepting")
        field(adr:, name: "because")
        refined = adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?).select(&:shared?).select(&:accepted?)
        if refined.any?
          h4 { "See Also:" }
          ul do
            refined.each do |refined_adr|
              li {
                a(href: "##{refined_adr.external_id}") {
                  refined_adr.title
                }
              }
            end
          end
        end
      end
  end
  end
  def field(adr:, name:)
    section(aria_label: name) do
      h3 { raw(t([ :fields, name ])) }
      div do
        render(MarkdownStringComponent.new(adr.send(name)))
      end
    end
  end
end

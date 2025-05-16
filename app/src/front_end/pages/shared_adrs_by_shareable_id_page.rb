class SharedAdrsByShareableIdPage < AppPage
  attr_reader :adr

  def initialize(shareable_id:)
    @adr = DB::Adr.find!(shareable_id:)
  end

  def field(name, label_additional_classes: "")
    section(
      aria_label: name,
            class: "flex flex-column gap-2 ph-3"
    ) do
      h4(
        class: "ma-0 f-1 ttu fw-6 #{label_additional_classes}"
      ) {
        raw(t([ :fields, name ]))
      }
      div(class: "measure-wide rendered-markdown") do
        render(MarkdownStringComponent.new(adr.send(name)))
      end
    end
  end

  def shareable_refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?).select(&:shared?)
  end

  def shareable_path(adr)
    if !adr.shared?
      bug! "#{adr.external_id} is not share - this should not have been called"
    end
    self.class.routing(shareable_id: adr.shareable_id)
  end

  def page_template
    div(class: "flex-ns items-start gap-3 justify-center") do
      div(role: "none", class:"w-quarter db-ns db")
      article(class: "w-50-ns ph-0 bg-white #{ adr.replaced? ? 'gray-600' : 'black' } ba-ns bc-gray-600 br-2 mv-3 shadow-3-ns pos-relative") do
        h2(class: "tc measure-narrow ph-1 mh-auto lh-title fs-5 mt-3 mb-1 #{ adr.replaced? ? 'tds' : '' }") { adr.title }
        div(class: "tc f-1 mb-3") do
          if adr.replaced?
            h3(class: "lh-title f-3 fw-5 pa-2 mh-3 ba br-2 bc-red-300 red-900 bg-red-300 flex items-center gap-3") do
              div(class: "w-3") do
                inline_svg("change-icon")
              end
              div(class: "tl") do
                div(class: "f-2") do
                  raw(
                    t(:replaced_on) { 
                      TimeTag(timestamp: adr.replaced_by_adr.accepted_at, class: "fw-6", format: :date)
                    }
                  )
                  if adr.replaced_by_adr.shared?
                    whitespace
                    raw(
                      t(:replaced_by) do
                        a(
                          class: "red-900",
                          href: shareable_path(adr.replaced_by_adr)
                        ) {
                          adr.replaced_by_adr.title
                        }
                      end
                    )
                  end
                end
              end
            end
          end
          h3(class: "lh-title fw-5 pa-2 mh-3 ba br-2 #{ adr.replaced? ? 'bc-gray-300 gray-700 bg-gray-400' : 'text-glow bc-green-200 green-800 bg-green-200' }") do
            if adr.replaced?
              raw(t(:originally_accepted) do
                TimeTag(timestamp: adr.accepted_at, class: "fw-6", format: :date)
              end)
            else
              raw(t(:accepted) do
                TimeTag(timestamp: adr.accepted_at, class: "fw-6", format: :date)
              end)
            end
          end
          if !adr.replaced_adr.nil? && adr.replaced_adr.shared?
            h3(class: "lh-title f-1 fw-5 pa-2 mh-3 ba br-2 bc-green-200 green-200 bg-green-900") do
              raw(
                t(:replaced_by) do
                  a(
                    class: "green-300",
                    href: shareable_path(adr.replaced_adr)
                  ) {
                    adr.replaced_adr.title
                  }
                end
              )
            end
          end
          raw(t(:created) do
            TimeTag(timestamp: adr.created_at, class: "fw-5", format: :date)
          end)
        end
        section(class: "pt-3 adr-content") do
          field("context")
          field("facing")
          div(class: "mb-3 pb-1 pt-3 f-3 br-right-2 #{ adr.accepted? ? 'bg-green-800 green-200' : 'bg-yellow-800 yellow-100' }") do
            field("decision", label_additional_classes: "tdu f-2")
          end
          field("neglected")
          field("achieve")
          field("accepting")
          field("because")
        end
        if adr.refines? && adr.refines_adr.shared?
          section(aria_label: "context", class: "bt bc-gray-800") do
            h3(class: "lh-title f-1 fw-5 pa-2 mh-3 ba br-2 bc-blue-800 blue-300 bg-blue-900 flex items-center gap-2") do
              div(class: "w-2") do
                inline_svg("adjust-control-icon")
              end
              div(class: "tl") do
                raw(
                  t(:refines) do
                    a(
                      class: "blue-300",
                      href: shareable_path(adr.refines_adr)
                    ) {
                      adr.refines_adr.title
                    }
                  end
                )
              end
            end
          end
        end
        render(Adrs::GetRefinementsComponent.new(refined_by_adrs: shareable_refined_by_adrs, shareable_paths: true, gradient: false, constrain_width: false))
      end
      div(role:"none", class:"w-quarter db-ns dn")
    end
  end
end


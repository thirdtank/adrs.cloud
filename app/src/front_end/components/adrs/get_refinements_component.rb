class Adrs::GetRefinementsComponent < AppComponent2
  def time_tag(timestamp:nil,**component_options, &contents)
    args = component_options.merge(timestamp:)
    clock= Thread.current.thread_variable_get(:request_context)[:clock]
    raw(safe(Brut::FrontEnd::Components::Time.new(**args,&contents).render(clock:).to_s))
  end
  attr_reader :refined_by_adrs
  def initialize(refined_by_adrs:, shareable_paths: false, gradient: true, constrain_width: true)
    @refined_by_adrs =   refined_by_adrs
    @shareable_paths = !!shareable_paths
    @gradient        =   gradient
    @constrain_width =   constrain_width
  end

  def gradient?        = @gradient
  def constrain_width? = @constrain_width

  def path(adr)
    if @shareable_paths
      SharedAdrsByShareableIdPage.routing(shareable_id: adr.shareable_id)
    else
      AdrsByExternalIdPage.routing(external_id: adr.external_id)
    end
  end

  def view_template
    if !refined_by_adrs.any?
      return nil
    end
    gradient = if gradient?
                 "background: linear-gradient(90deg, rgba(228,241,255,1) 11%, rgba(228,241,255, 0) 100%);"
               else
                 nil
               end

    section(
      class: "pa-3 bg-blue-800 gray-200 #{ constrain_width? ? "measure-wide" : "" }", 
      style: gradient
    ) do
      h4(class: "f-2 fw-6 mt-2 mb-1 flex items-center gap-2") do
        span(class: "w-2") do
          inline_svg("adjust-control-icon")
        end
        plain(t(component: :refinements).to_s)
      end
      table(class: "collapse w-100 mh-auto f-1") do
        thead do
          tr do
            th(class: "tl pv-2 pr-2 fw-bold bb") do
              "Title"
            end
            th(class: "tl pv-2 pr-2 fw-bold bb") do
              "Status"
            end
            th(class: "tl pv-2 pr-2 fw-bold bb") do
              "Date"
            end
          end
        end
        tbody do
          refined_by_adrs.each do |refining_adr|
            tr do
              td(class:"pv-2 pr-2") do
                a(class:"blue-300", href:path(refining_adr).to_s) do
                  refining_adr.title
                end
              end
              td(class:"pv-2 pr-2") do
                if refining_adr.accepted?
                  t(component: :is_accepted).to_s
                elsif refining_adr.rejected?
                  t(component: :is_rejected).to_s
                else
                  t(component: :is_draft).to_s
                end
              end
              td(class:"pv-2 pr-2") do
                if refining_adr.accepted?
                  time_tag(timestamp: refining_adr.accepted_at).to_s
                elsif refining_adr.rejected?
                  time_tag(timestamp: refining_adr.rejected_at).to_s
                else
                  time_tag(timestamp: refining_adr.created_at).to_s
                end
              end
            end
          end
        end
      end
    end
  end
end


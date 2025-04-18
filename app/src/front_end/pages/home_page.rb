class HomePage < AppPage
  def initialize(flash:)
    @phlex_component = PhlexComponent.new(flash:)
  end

  class PhlexComponent < Phlex::HTML

    include Brut::FrontEnd::Component::Helpers
    include Brut::I18n::ForHTML

    def initialize(flash:)
      @error_message = flash.alert
    end

    def form_tag(**args, &block)
      render FormTag.new(**args,&block)
    end

    def view_template
      div(class: "HomePage w-100 flex items-center") do
        main(class: "w-third h-100vh bg-purple-800 purple-100 flex flex-column items-end justify-center br bc-purple-700") do
          header(class: "ph-3 mb-5") do
            h2(class: "f-6 mv-1 tr") { "All Your Decisions, All Together" }
            h1(class: "f-4 mb-0 tr") { "ADrs.Cloud" }
          end
          if !@error_message.nil?
            p(class: "ba br-0 pa-3 bg-red-800 red-300 bc-red-700 mr-3 flex items-center gap-3 shadow-4", role: "alert") do
              span(class: "w-3") do
                svg("exclamation-triangle-icon")
              end
              span do
                t(@error_message)
              end
            end
          end
          form_tag(action: "/auth/github", method: :post, class: "ph-3") do
            button(type: "submit", class: "button button--size--large button--color--blue") do
              raw(safe( "Login with GitHub &rarr;"))
            end
          end
          if !Brut.container.project_env.production?
            form_tag(action: "/auth/developer", method: :post, class: "ph-3 mt-2") do
              button(type: "submit", class: "button button--size--small button--color--orange") do
                "Dev login"
              end
            end
          end
          p(class: "p mh-auto mb-6 f-2 pl-4 measure-narrow pr-3 mt-2 tr") do
            strong { "No credit card required." }
            plain(" Create up to ")
            strong(class: "dib") { "20 free ADRs" }
            plain(". Share them with anyone (or not).")
          end
        end
        div(class: "bg-blue-900 gray-100 h-100vh w-two-thirds flex flex-column items-center justify-between graph-paper") do
          div(class:"flex flex-column items-center gap-3 mt-5") do
            figure(class: "rotate-negative-4") do
              img(src: "/static/images/list.png", class: "w-7 shadow-3 br-3")
              figcaption(class:"tc f-3 mt-2 measure-narrow lh-title pa-1 br-2 bg-50") do
                "Manage all your decisions in one place."
              end
            end
          end
          div(class:"flex items-center justify-center gap-3") do
            figure(class: "rotate-5") do
              img(src: "/static/images/view.png", class: "w-6 shadow-3 br-3")
              figcaption(class:"tc f-3 mt-2 measure-narrow lh-title pa-1 br-2 bg-50") do
                "Refine or replace existing decisions to keep current."
              end
            end
            figure(class: "rotate-negative-2") do
              img(src: "/static/images/edit.png", class: "w-6 shadow-3 br-3")
              figcaption(class:"tc f-3 mt-2 measure-narrow lh-title pa-1 br-2 bg-50") do
                "Clarify decisions with Y-statements so everything's consistent."
              end
            end
          end
        end
      end
    end
  end

  def phlex_component = @phlex_component
end

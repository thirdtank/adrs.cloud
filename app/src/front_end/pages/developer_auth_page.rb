class DeveloperAuthPage < AppPage
  class PhlexComponent < Phlex::HTML
    include Brut::FrontEnd::Component::Helpers
    include Brut::I18n::ForHTML
    def view_template
      section(class: "mh-auto w-50") do
        h1 { "Auth" }
        render FormTag.new(action: "/auth/developer/callback", method: :get) do
          label(class: "db mb-3") do
            input(type: "email", name: "email", class: "db pa-2 br-2 ba bc-black", autofocus: true)
            plain("Email Address")
          end
          button(class: "db ph-4 pv-3 ba bc-gray-200 black bg-white-ish br-3") { "Log In" }
        end
      end
    end
  end

  def phlex_component
    PhlexComponent.new
  end

end

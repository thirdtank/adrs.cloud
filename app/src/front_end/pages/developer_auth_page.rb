class DeveloperAuthPage < AppPage2
  def view_template
    with_layout do
      section(class: "mh-auto w-50") do
        h1 { "Auth" }
        form_tag(action: "/auth/developer/callback", method: :get) do
          label(class: "db mb-3") do
            input(type: "email", name: "email", class: "db pa-2 br-2 ba bc-black", autofocus: true)
            plain("Email Address")
          end
          button(class: "db ph-4 pv-3 ba bc-gray-200 black bg-white-ish br-3") { "Log In" }
        end
      end
    end
  end
end

class HelpPage < AppPage
  def page_template
    header(class: "pa-4 bg-gray-200 gray-800") do
      h1(class: "tc") { "Help & Support" }
    end
    section(class: "w-60-ns ph-3 ph-0-ns mh-auto") do
      a(
        class: "f-5-ns f-3 b ff-mono tc db mt-3 green-300",
        href: "mailto:support@adrs.cloud"
      )do
        "support@adrs.cloud"
      end
      p(class:"p mh-auto") do
        raw(safe(t(page: :support_message).to_s))
      end
      a(
        class: "db mt-4 blue-300 tc",
        href: AdrsPage.routing,
      ) do
        raw(safe("&;larr"))
        whitespace
        t(:back)
      end
    end
  end
end

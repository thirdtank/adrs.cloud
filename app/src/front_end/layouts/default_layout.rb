class DefaultLayout < Brut::FrontEnd::Layout
  include Brut::FrontEnd::Components
  register_element :adr_announcement_banner
  register_element :adr_check_download
  register_element :adr_edit_draft_by_external_id_page
  register_element :adr_entitlement_effective
  register_element :adr_include_query_params
  register_element :adr_tag_editor

  def view_template
    doctype
    html(lang: "en") do
      head do
        meta(charset: "utf-8")
        meta(content: "width=device-width,initial-scale=1", name:"viewport")
        title do
          t(:page_title)
        end
        meta(content: "website", property:"og:type")
        PageIdentifier(page)
        link(rel: "stylesheet", href: asset_path("/css/styles.css"))
        script(defer: true, src: asset_path("/js/app.js"))
        I18nTranslations("cv.cs")
        I18nTranslations("cv.this_field")
        Traceparent()
        render(
          Brut::FrontEnd::RequestContext.inject(
            Brut::FrontEnd::Components::LocaleDetection
          )
        )
      end
      body(class: "bg-gray-900 gray-200 ff-sans") do
        yield
      end
    end
  end
end

class DefaultLayout < Phlex::HTML
  include Brut::Framework::Errors
  include Brut::I18n::ForHTML

  register_element :brut_confirm_submit
  register_element :brut_confirmation_dialog
  register_element :brut_cv
  register_element :brut_ajax_submit
  register_element :brut_autosubmit
  register_element :brut_confirm_submit
  register_element :brut_confirmation_dialog
  register_element :brut_cv
  register_element :brut_cv_messages
  register_element :brut_copy_to_clipboard
  register_element :brut_form
  register_element :brut_i18n_translation
  register_element :brut_locale_detection
  register_element :brut_message
  register_element :brut_tabs
  register_element :brut_tracing

  register_element :adr_announcement_banner
  register_element :adr_check_download
  register_element :adr_edit_draft_by_external_id_page
  register_element :adr_entitlement_effective
  register_element :adr_include_query_params
  register_element :adr_tag_editor

  def initialize(page_name:)
    @page_name = page_name
  end

  def asset_path(path) = Brut.container.asset_path_resolver.resolve(path)

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
        render(Brut::FrontEnd::Components::PageIdentifier.new(@page_name))
        link(rel: "stylesheet", href: asset_path("/css/styles.css"))
        script(defer: true, src: asset_path("/js/app.js"))
        render(Brut::FrontEnd::Components::I18nTranslations.new("general.cv.fe"))
        render(Brut::FrontEnd::Components::I18nTranslations.new("general.cv.this_field"))
        raw(
          safe(
            Brut::FrontEnd::RequestContext.inject(
              Brut::FrontEnd::Components::LocaleDetection
            ).render.to_s
          )
        )
      end
      body(class: "bg-gray-900 gray-200 ff-sans") do
        yield
      end
    end
  end
end

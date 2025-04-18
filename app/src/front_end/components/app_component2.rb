class AppComponent2 < Phlex::HTML
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

  def inline_svg(svg)
    Brut.container.svg_locator.locate(svg).then { |svg_file|
      File.read(svg_file)
    }.then { |svg_content|
      raw(safe(svg_content))
    }
  end
end

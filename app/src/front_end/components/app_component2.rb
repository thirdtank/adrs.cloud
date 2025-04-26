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

  def time_tag(timestamp:nil,**component_options, &contents)
    args = component_options.merge(timestamp:)
    clock= Thread.current.thread_variable_get(:request_context)[:clock]
    raw(
      safe(Brut::FrontEnd::Components::Time.new(**args,&contents).render(clock:).to_s)
    )
  end

  def form_tag(**args, &block)
    render Brut::FrontEnd::Components::FormTag.new(**args,&block)
  end

  def self.component_name = self.name
  def component_name = self.class.component_name

  def page_name
    @page_name ||= begin
                     page = self.class.name.split(/::/).reduce(Module) { |accumulator,class_path_part|
                       if accumulator.ancestors.include?(Brut::FrontEnd::Page)
                         accumulator
                       else
                         accumulator.const_get(class_path_part)
                       end
                     }
                     if page.ancestors.include?(Brut::FrontEnd::Page)
                       page.name
                     elsif page.respond_to?(:page_name)
                       page.page_name
                     else
                       raise "#{self.class} is not nested inside a page, so #page_name should not have been called"
                     end
                   end
  end
end

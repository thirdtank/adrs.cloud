class AppPage2 < Phlex::HTML
  include Brut::FrontEnd::HandlingResults
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
  register_element :adr_entitlement_default
  register_element :adr_entitlement_override
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
    raw(safe(Brut::FrontEnd::Components::Time.new(**args,&contents).render(clock:).to_s))
  end

  def form_tag(**args, &block)
    render FormTag.new(**args,&block)
  end

  def layout = "default"

  # @return [String] name of this page for use in debugging or for whatever reason you may want to dynamically refer to the page's name.  The default value is the class name.
  def self.page_name = self.name

  def with_layout(&block)
    layout_class = Module.const_get(
      layout_class = RichString.new([
        self.layout,
        "layout"
      ].join("_")).camelize
    )
    render layout_class.new(page_name:,&block)
  end

  def before_render = nil

  def handle!
    case before_render
    in URI => uri
      uri
    in Brut::FrontEnd::HttpStatus => http_status
      http_status
    else
      self.call
    end
  end


  def view_template
    with_layout do
      page_template
    end
  end

  # Convienience method for {.page_name}.
  def page_name = self.class.page_name

  # @!visibility private
  def component_name = raise Brut::Framework::Errors::Bug,"#{self.class} is not a component"

  def global_component(component_klass)
    render Brut::FrontEnd::RequestContext.inject(component_klass)
  end
end

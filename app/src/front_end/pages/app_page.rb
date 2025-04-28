class AppPage < Brut::FrontEnd::Page
  include Brut::Framework::Errors
  include Brut::FrontEnd::Components
  register_element :adr_announcement_banner
  register_element :adr_check_download
  register_element :adr_edit_draft_by_external_id_page
  register_element :adr_entitlement_effective
  register_element :adr_entitlement_default
  register_element :adr_entitlement_override
  register_element :adr_include_query_params
  register_element :adr_tag_editor
  register_element :adr_tag_editor_view
  register_element :adr_tag_editor_edit
end

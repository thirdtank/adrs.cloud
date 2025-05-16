class Adrs::FormComponent < AppComponent

  attr_reader :form, :action_label, :form_action, :go_back_label

  def initialize(form, action:, external_id: nil, projects: [])
    @form = form
    @projects = projects
    case action
    when :new
      @action_label  = t("actions.save_draft")
      @form_action   = NewDraftAdrForm.routing
      @go_back_label = t(:nevermind)
      @ajax_submit   = false
    when :edit
      @external_id   = external_id_required!(external_id:,action:)
      @action_label  = t("actions.update_draft")
      @form_action   = EditDraftAdrWithExternalIdForm.routing(external_id: @external_id)
      @go_back_label = t(:back)
      @ajax_submit   = true
    when :replace
      @action_label  = t("actions.save_replacement_draft")
      @form_action   = NewDraftAdrHandler.routing
      @go_back_label = t(:nevermind)
      @ajax_submit   = false
    when :refine
      @action_label  = t("actions.save_refining_draft")
      @form_action   = NewDraftAdrHandler.routing
      @go_back_label = t(:nevermind)
      @ajax_submit   = false
    else
      raise "Action '#{action}' is not known"
    end
  end

  def ajax_submit? = @ajax_submit

  def adr_textarea(name)
    render(
      Adrs::TextareaComponent.new(
        form: @form,
        input_name: name,
        label: t([ :fields, name, :label ]),
        context: t([ :fields, name, :context ])
      )
    )
  end

  def reject_button
    if !@form.new_record?
      render(
        ButtonComponent.new(
          formaction: RejectedAdrsWithExternalIdHandler.routing(external_id: @external_id),
          size: "small",
          color: "red",
          label: t("actions.reject"),
          icon: "recycle-bin-line-icon",
          confirm: "You can't bring this back other than re-creating it by hand"
        )
      )
    end
  end

  def accept_button
    if !@form.new_record?
      render(
        ButtonComponent.new(
          formaction: AcceptedAdrsWithExternalIdForm.routing(external_id: @external_id),
          size: "small",
          color: "green",
          label: t("actions.accept"),
          icon: "quality-badge-checkmark-icon",
          confirm: "You won't be able to change this ADR after you accept it"
        )
      )
    end
  end

  def view_template
    brut_form(show_warnings: true) do
      FormTag(
        action: form_action.to_s,
        method:"post",
        class:"flex flex-column gap-2 shadow-2-ns mh-auto pa-4-ns br-1 bg-white-ish-ns w-60-ns"
      ) do
        label(class: "flex items-center gap-2 mb-3") do
          span { "Project" }
          render select_tag_with_options(
            form: form,
            input_name: :project_external_id,
            html_attributes: { class: "w-100 f-3" },
            options: @projects,
            value_attribute: :external_id,
            option_text_attribute: :name,
          )
        end
        render(
          TextFieldComponent.new(
            label: t(:adr_title),
            form: form,
            input_name: "title",
            placeholder: t(:adr_title_placeholder),
            autofocus: true
          )
        )
        div(class: "flex items-center gap-2 justify-between") do
          div(class: "w-100") do
            adr_textarea("context")
          end
          span(class: "f-7") do
            inline_svg("curved-arrow-right-to-bottom-icon")
          end
        end
        div(class: "flex items-center gap-2 justify-between") do
          span(class: "f-7") do
            inline_svg("curved-arrow-left-to-bottom-icon")
          end
          div(class: "w-100") do
            adr_textarea("facing")
          end
        end
        div(class: "flex items-center gap-2 justify-between") do
          div(class: "w-100") do
            adr_textarea("decision")
          end
          span(class: "f-7") do
            inline_svg("curved-arrow-right-to-bottom-icon")
          end
        end
        div(class: "flex items-center gap-2 justify-between") do
          span(class: "f-7") do
            inline_svg("curved-arrow-left-to-bottom-icon")
          end
          div(class: "w-100") do
            adr_textarea("neglected")
          end
        end
        div(class: "flex items-center gap-2 justify-between") do
          div(class: "w-100") do
            adr_textarea("achieve")
          end
          span(class: "f-7") do
            inline_svg("curved-arrow-right-to-bottom-icon")
          end
        end
        div(class: "flex items-center gap-2 justify-between") do
          span(class: "f-7") do
            inline_svg("curved-arrow-left-to-bottom-icon")
          end
          div(class: "w-100") do
            adr_textarea("accepting")
          end
        end
        div(class: "flex items-center gap-2 justify-between") do
          div(class: "w-100") do
            adr_textarea("because")
          end
          span(class: "f-7") do
            inline_svg("curved-arrow-right-to-bottom-icon")
          end
        end
        div(class:"flex items-center gap-2 justify-between") do
          adr_textarea("tags")
        end
        div(class:"flex flex-column items-center justify-between") do
          span(class:"f-7") do
            inline_svg("arrow-bottom-direction-icon")
          end
        end
        input(type: "hidden", name: "refines_adr_external_id", value: form.refines_adr_external_id)
        input(type: "hidden", name: "replaced_adr_external_id", value: form.replaced_adr_external_id)
        div(class: "mt-2 flex justify-center") do
          if ajax_submit?
            brut_ajax_submit(
              class: "pos-relative",
              show_warnings: "only-one",
              log_request_errors: true,
            ) do
              render(ButtonComponent.new(size: "normal", color: "blue", label: action_label, icon: "edit-list-icon"))
              div(
                data_loading_animation: true,
                class: "w-3 h-3 mh-auto mv-auto top-0 left-0 right-0 bottom-0 pos-absolute"
              ) do
                div(class: "rotating") do
                  inline_svg("loader-icon")
                end
              end
              div(
                data_submitted_icon: true,
                class: "w-3 h-3 mh-auto mv-auto top-0 left-0 right-0 bottom-0 pos-absolute"
              ) do
                inline_svg("check-mark-icon")
              end
            end
          else
            render(ButtonComponent.new(size: "normal", color: "blue", label: action_label, icon: "edit-list-icon"))
          end
        end
        div(class: "mv-3 pb-3 flex gap-3 items-center justify-center bb bc-gray-700 w-100 mh-auto") do
          reject_button
          accept_button
        end
        a(
          href: AdrsPage.routing,
          class: "red-300"
        ) do
          span(role: "none") { raw(safe("&larr;")) }
          raw(go_back_label)
        end
      end
      render ConfirmationDialogComponent.new
    end
  end

private

  def external_id_required!(external_id:,action:)
    if external_id.nil?
      bug! "You may not create a #{self.class} with action #{action} and no external_id."
    end
    external_id
  end

end


class NewDraftAdrForm < AppForm
  input :title, minlength: 4
  input :context, required: false
  input :facing, required: false
  input :decision, required: false
  input :neglected, required: false
  input :achieve, required: false
  input :accepting, required: false
  input :because, required: false
  input :tags, required: false
  input :refines_adr_external_id, required: false
  input :replaced_adr_external_id, required: false

  def params_empty?(params)
    params.nil? || params.except(:refines_adr_external_id,:replaced_adr_external_id).empty?
  end

  def new_record? = true

  def process!(account:, flash:)
    if self.invalid?
      return
    end
    action = Actions::Adrs::SaveDraft.new

    result = action.save_new(form: self, account: account)
    case result
    in Brut::BackEnd::Actions::CheckResult
      if result.constraint_violations?
        result.each_violation do |object,field,key,context|
          if object == self
            context ||= {}
            humanized_field = RichString.new(field).humanized.to_s
            self.server_side_constraint_violation(input_name: field, key: key, context: context.merge(field: humanized_field))
          else
            logger.warn("Ignoring constraint violation on object #{object} (field: #{field}, key: #{key}), because it is not the form")
          end
        end
      end
      flash[:error] = "pages.adrs.new.adr_invalid"
      Brut::FrontEnd::FormProcessingResponse.render_page(NewDraftAdrPage.new(form: self))
    else
      flash[:notice] = "actions.adrs.created"
      Brut::FrontEnd::FormProcessingResponse.redirect_to(Brut.container.routing.for(EditDraftAdrByExternalIdPage, external_id: result.external_id))
    end
  end

end

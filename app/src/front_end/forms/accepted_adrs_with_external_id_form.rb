class AcceptedAdrsWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false
  def new_record? = false

  def process!(account:, flash:)
    if self.constraint_violations?
      return
    end
    action = Actions::Adrs::Accept.new
    result = action.accept(form: self, account: account)
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
      EditDraftAdrByExternalIdPage.new(
        adr: result[:adr],
        form: self,
        error_message: "pages.adrs.edit.adr_cannot_be_accepted",
        flash: flash,
      )
    else
      flash[:notice] = "actions.adrs.accepted"
      redirect_to(AdrsByExternalIdPage, external_id: result.external_id)
    end
  end
end

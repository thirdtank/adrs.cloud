class EditDraftAdrWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false

  def new_record? = false

  def process!(account:, xhr:, flash:)
    if self.constraint_violations?
      return
    end
    action = Actions::Adrs::SaveDraft.new

    result = action.update(form: self, account: account)
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
      if xhr
        [
          Components::Adrs::ErrorMessages.new(form: self),
          http_status(422),
        ]
      else
        EditDraftAdrByExternalIdPage.new(
          adr: result[:adr],
          form: self,
          error_message: "pages.adrs.edit.adr_invalid",
          flash: flash,
        )
      end
    else
      if xhr
        http_status(200)
      else
        flash[:notice] = "actions.adrs.updated"
        redirect_to(AdrsByExternalIdPage, external_id: result[:adr].external_id)
      end
    end
  end

  def self.from_adr(adr)
    tag_serializer = Actions::Adrs::TagSerializer.new
    self.new(
      params: {
        external_id: adr.external_id,
        title: adr.title,
        context: adr.context,
        facing: adr.facing,
        decision: adr.decision,
        neglected: adr.neglected,
        achieve: adr.achieve,
        accepting: adr.accepting,
        because: adr.because,
        tags: tag_serializer.from_array(adr.tags),
        refines_adr_external_id: adr.refines_adr&.external_id,
      }
    )
  end

end

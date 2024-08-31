class EditDraftAdrWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false

  def process!(account:, xhr:)
    if self.invalid?
      return
    end
    action = Actions::Adrs::SaveDraft.new

    result = action.update(form: self, account: account)
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
      if xhr
        Brut::FrontEnd::FormProcessingResponse.render_component(
          Components::Adrs::ErrorMessages.new(form: self),
          http_status: 422
        )
      else
        Brut::FrontEnd::FormProcessingResponse.render_page(EditDraftAdrByExternalIdPage.new(
          adr: result[:adr],
          form: self,
          error_message: "pages.adrs.edit.adr_invalid"
        ))
      end
    else
      if xhr
        Brut::FrontEnd::FormProcessingResponse.send_http_status(200)
      else
        Brut::FrontEnd::FormProcessingResponse.redirect_to(Brut.container.routing.for(AdrsByExternalIdPage, external_id: result.external_id))
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

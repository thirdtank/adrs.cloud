class EditDraftAdrWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false

  def new_record? = false

  def process!(account:, xhr:, flash:)
    action = Actions::Adrs::SaveDraft.new

    adr = action.update(form: self, account: account)
    if self.constraint_violations?
      if xhr
        [
          Components::Adrs::ErrorMessages.new(form: self),
          http_status(422),
        ]
      else
        EditDraftAdrByExternalIdPage.new(
          adr: adr,
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
        redirect_to(AdrsByExternalIdPage, external_id: adr.external_id)
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

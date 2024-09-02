class EditDraftAdrWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false

  def new_record? = false

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

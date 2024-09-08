class EditDraftAdrWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false

  def new_record? = false

  def self.from_adr(adr)
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
        tags: Tags.from_array(array: adr.tags).to_s,
        refines_adr_external_id: adr.refines_adr&.external_id,
      }
    )
  end

end

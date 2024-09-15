class EditDraftAdrWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm

  def new_record? = false
end

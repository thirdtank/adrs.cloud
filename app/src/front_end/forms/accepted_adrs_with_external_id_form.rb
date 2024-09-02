class AcceptedAdrsWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false
  def new_record? = false
end

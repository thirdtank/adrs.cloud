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
  select :project_external_id, required: true

  def params_empty?(params)
    params.nil? || params.except(:refines_adr_external_id,:replaced_adr_external_id,:project_external_id).empty?
  end

  def new_record? = true
end

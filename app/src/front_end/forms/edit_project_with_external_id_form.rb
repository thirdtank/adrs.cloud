class EditProjectWithExternalIdForm < AppForm
  inputs_from NewProjectForm

  def new_record? = false
end

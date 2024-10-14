class NewProjectForm < AppForm
  input :name, minlength: 3
  input :description, required: false
  input :adrs_shared_by_default, type: :checkbox

  def new_record? = true
end

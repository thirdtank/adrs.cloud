class NewProjectPage < AppPage
  attr_reader :form
  def initialize(form:nil)
    @form = form || NewProjectForm.new
  end
end

class ErrorMessagesComponent < AppComponent
  def initialize(form:)
    @form = form
  end

  def view_template
    @form.constraint_violations(server_side_only: true).each do |input_name, (constraints,_index)|
      constraints.each do |constraint|
        brut_cv(input_name: input_name) do
          t("cv.be.#{constraint}", **constraint.context)
        end
      end
    end
  end

end


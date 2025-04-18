class ErrorMessagesComponent < AppComponent
  class PhlexComponent < Phlex::HTML
    include Brut::I18n::ForHTML
    register_element :brut_cv
    def initialize(form:)
      @form = form
    end

    def view_template
      @form.constraint_violations(server_side_only: true).each do |input_name, (constraints,_index)|
        constraints.each do |constraint|
          brut_cv(input_name: input_name) do
            t("cv.be.#{constraint}", **constraint.context).capitalize.to_s
          end
        end
      end
    end

  end

  attr_reader :form
  def initialize(form:)
    @phlex_component = PhlexComponent.new(form: form)
  end

  def render
    @phlex_component.call
  end
end


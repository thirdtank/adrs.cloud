class FormTag < Phlex::HTML
  include Brut::FrontEnd::Component::Helpers
  def initialize(route_params: {}, **html_attributes)
    form_class = html_attributes.delete(:for) # Cannot be a keyword arg, since for is a reserved word
    if !form_class.nil?
      if form_class.kind_of?(Brut::FrontEnd::Form)
        form_class = form_class.class
      end
      if html_attributes[:action]
        raise ArgumentError, "You cannot specify both for: (#{form_class}) and and action: (#{html_attributes[:action]}) to a form_tag"
      end
      if html_attributes[:method]
        raise ArgumentError, "You cannot specify both for: (#{form_class}) and and method: (#{html_attributes[:method]}) to a form_tag"
      end
      begin
        route = Brut.container.routing.route(form_class)
        html_attributes[:method] = route.http_method.to_s
        html_attributes[:action] = route.path(**route_params).to_s
      rescue Brut::Framework::Errors::MissingParameter
        raise ArgumentError, "You specified #{form_class} (or an instance of it), but it requires more url parameters than were found in route_params: (or route_params: was omitted). Please add all required parameters to route_params: or use `action: #{form_class}.routing(..params..), method: [:get|:post]` instead"
      end
    end

    @csrf_token_omit_reasoning = nil

    http_method = Brut::FrontEnd::HttpMethod.new(html_attributes[:method])

    @include_csrf_token = http_method.post?
    @csrf_token_omit_reasoning = http_method.get? ? "because this form's action is a GET" : nil
    @attributes = html_attributes
  end

  class CsrfToken < Phlex::HTML
    def initialize(csrf_token:)
      @csrf_token = csrf_token
    end
    def view_template
      input type: "hidden", name: "authenticity_token", value: @csrf_token
    end
  end

  def view_template
    form(**@attributes) do
      if @include_csrf_token
        render Brut::FrontEnd::RequestContext.inject(CsrfToken)
      elsif Brut.container.project_env.development?
        comment do
          "CSRF Token omitted #{@csrf_token_omit_reasoning} (this message only appears in development)"
        end
      end
      yield
    end
  end
end

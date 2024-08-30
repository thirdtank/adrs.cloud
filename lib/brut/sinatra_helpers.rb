module Brut::SinatraHelpers
  def self.included(sinatra_app)
    sinatra_app.extend(ClassMethods)
    sinatra_app.set :logging, true
    sinatra_app.before do
      Thread.current[:rendering_context] = {
        csrf_token: Rack::Protection::AuthenticityToken.token(env["rack.session"])
      }
      session[:_flash] ||= {
        age: 0,
        messages: {}
      }
    end
    sinatra_app.after do
      Thread.current[:rendering_context] = nil
      session[:_flash][:age] += 1
      if session[:_flash][:age] > 2
        session[:_flash] = {
          age: 0,
          messages: {}

        }
      end
    end
  end

  def flash
    session[:_flash][:messages]
  end

  def page(page_instance)
    call_render = CallRenderInjectingInfo.new(page_instance)
    call_render.call_render(**Thread.current[:rendering_context])
  end
  def component(component_instance)
    self.page(component_instance)
  end

  def process_form(form:, action:, action_method: :call, **rest)
    SemanticLogger["SinatraHelpers"].info("Processing form",
                                        form: form.class,
                                        action: action.class,
                                        action_method: action_method,
                                        params: form.to_h)
    form_submission = Brut::BackEnd::Actions::FormSubmission.new
    form_submission.process_form(form: form,
                                 action: action,
                                 action_method: action_method,
                                 **rest)
  end

  module ClassMethods

    # Declare a web page at a given route.  A web page is backed by an instance of a class that provides that page its dynamic 
    # behavior.  That class must be a subclass of `Brut::FrontEnd::Page`.  Its constructor must accept
    # only keyword arguments, and these must be sufficient for the page to work. An instance is used per request.
    #
    # route:: a URL, starting with a slash, that represents the route to this page
    # page_class:: if present, this is the class for the page. If omitted, the class name is guessed, based
    #              on the route.  See "class name derivation" below.
    #
    # When the route is requested via an HTTP GET, the page is instantiated.  The page class' constructor should accept keyword
    # arguments, and these arguments will be injected as follows:
    #
    # * Any named value inside the request data.  For example, if you have set the `current_user` into the request data,
    #   a kwarg `current_user:` will be given that value.
    # * Any named value from the route. For example if your route is `/widgets/:id`, then a kwarg `id:` will have the value
    #   from the route.
    # * `flash:` for the flash
    #
    # Class name derivation
    #
    # TBD
    def page(route, page_class: :derive, **rest)
      page_class = if page_class == :derive
                     classes_parts = route.split(/\//)
                     if classes_parts[0] != ""
                       raise ArgumentError, "You may not derive a page class unless your route starts with /"
                     end
                     classes_parts[0] = "Pages"
                     classes_parts.reduce(self) do |mod,class_part|
                       mod.const_get(
                         RichString.new(class_part).camelize.to_s
                       )
                     end
                   else
                     page_class
                   end
      get route do
        args = {}
        page_class.instance_method(:initialize).parameters.each do |(type,name)|
          if ![ :key,:keyreq ].include?(type)
            raise ArgumentError,"Page constructors must accept only keyword arguments"
          end
          if args[name].nil?
            current_value = if name == :flash
                              flash
                            elsif params[name]
                              params[name]
                            else
                              @request_data.key?(name) ? @request_data[name] : @request_data[name.to_s]
                            end
            if current_value
              args[name] = current_value
            elsif rest[name]
              args[name] = rest[name]
            elsif rest["#{name}_class".to_sym]
              object = rest["#{name}_class".to_sym].new
              args[name] = object
            elsif type == :keyreq
              raise ArgumentError,"Initializer for #{page_class} wants to be injected with #{name} but there isn't anything with that value. Default it to `nil` if you want `nil` injected"
            end
          end
        end
        page page_class.new(**args)
      end
    end
  end
end

module Brut
  # Holds free-form, non-serializable data
  # that is context for this request.
  # This information can be plucked out
  # by pages or components.
  class RequestContext
    def initialize(env:,session:)
      @hash = {
        env: env,
        session: session,
      }
    end

    def []=(key,value)
      key = key.to_sym
      @hash[key] = value
    end

    def [](key)
      @hash[key.to_sym]
    end

    def key?(key)
      @hash.key?(key.to_sym)
    end

    # Returns a hash suitable to passing into this class' constructor.
    def as_constructor_args(klass, request_params: {}, flash:, additional_args: {})
      args_for_method(method: klass.instance_method(:initialize),
                      request_params: request_params,
                      flash: flash,
                      additional_args: additional_args)
    end

    def as_method_args(object, method_name, request_params: {}, flash:, additional_args: {})
      args_for_method(method: object.method(method_name),
                      request_params: request_params,
                      flash: flash,
                      additional_args: additional_args)
    end

  private

    def args_for_method(method:, request_params:, flash:, additional_args:)
      args = {}
      method.parameters.each do |(type,name)|
        if ![ :key,:keyreq ].include?(type)
          raise ArgumentError,"#{name} is not a keyword arg, but is a #{type}"
        end
        if self.key?(name)
          args[name] = self[name]
        elsif name == :params
          args[name] = request_params
        elsif name == :flash
          args[name] = flash
        elsif request_params[name.to_s] || request_params[name.to_sym]
          args[name] = request_params[name.to_s] || request_params[name.to_sym]
        elsif additional_args[name]
          args[name] = additional_args[name]
        elsif additional_args["#{name}_class".to_sym]
          args[name] = additional_args["#{name}_class".to_sym].new
        elsif type == :keyreq
          raise ArgumentError,"#{method} argument '#{name}' is required, but there is no value in the current request context (keys: #{@hash.keys.map(&:to_s).join(", ")}). Either set this value in the request context or set a default value in the initializer"
        else
          # this keyword arg has a default value which will be used
        end
      end
      args
    end
  end
end

module Brut::SinatraHelpers

  class Flash
    def self.from_h(hash)
      hash ||= {}
      self.new(
        age: hash[:age] || 0,
        messages: hash[:messages] || {}
      )
    end
    def initialize(age: 0, messages: {})
      @age = age.to_i
      if !messages.kind_of?(Hash)
        raise ArgumentError,"messages must be a Hash, not a #{messages.class}"
      end
      @messages = messages
    end

    def age!
      @age += 1
      if @age > 1
        @age = 0
        @messages = {}
      end
    end

    def [](key)
      @messages[key]
    end

    def []=(key,message)
      @messages[key] = message
      @age = [0,@age-1].max
    end

    def to_h
      {
        age: @age,
        messages: @messages,
      }
    end
  end


  def self.included(sinatra_app)
    sinatra_app.extend(ClassMethods)
    sinatra_app.set :logging, true
    sinatra_app.before do
      Thread.current[:rendering_context] = {
        csrf_token: Rack::Protection::AuthenticityToken.token(env["rack.session"])
      }
      session[:_flash] ||= Flash.new.to_h
      Thread.current.thread_variable_set(:request_context, Brut::RequestContext.new(env:env,session:session))
    end
    sinatra_app.after do
      Thread.current[:rendering_context] = nil
      flash = Flash.from_h(session[:_flash])
      flash.age!
      session[:_flash] = flash.to_h
    end
  end

  def flash
    Flash.from_h(session[:_flash])
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

    # Regsiters a page in your app. A page is what it sounds like - a web page that's rendered from a URL.  It will be provided
    # via an HTTP get to the path provided.
    #
    # The page is rendered dynamically by using an instance of a page class as binding to HTML via ERB.  The name of the class and the name of the
    # ERB file are based on the path, according to the conventions described below.
    #
    # A few examples:
    #
    # * `page("/widgets")` will use `WidgetsPage`, and expect the HTML in `app/src/pages/widgets_page.html.erb`
    # * `page("/widgets/:id")` will use `WidgetsByIdPage`, and expect the HTML in `app/src/pages/widgets_by_id_page.html.erb`
    # * `page("/admin/widgets/:internal_id") will use `Admin::WidgetsByInternalIdPage`, and expect HTML in
    # `app/src/pages/admin/widgets_by_internal_id_page.html.erb`
    #
    # The general conventions are:
    #
    # * Each part of the path that is not a placeholder will be camelized
    # * Any part of the path that *is* a placholder has its leading colon removed, then is camelized, but appended to
    #   the previous part with `By`, thus `WidgetsById` is created from `Widgets`, `By`, and `Id`.
    # * The final part of the path is further appended with `Page`.
    # * These parts now make up a path to a class, so the entire thing is joined by `::` to form the fully-qualified class name.
    #
    # When a  GET is issued to the path, the page is instantiated.  The page's constructor may accept keyword arguments (however it must not accept
    # any other type of argument).
    #
    # Each keyword argument found will be provided when the class is created, as follows:
    #
    # * Any placeholders, so when a path `/widgets/1234` is requested, `WidgetsPage.new(id: "1234")` will be used to create the page object.
    # * Anything in the request context, such as the current user
    # * Any query string parameters 
    # * Anything passed as keyword args to this method, with the following adjustment:
    #   - Any key ending in `_class` whose value is a Class will be instantiated and
    #     passed in as the key withoutr `_class`, e.g. form_class: SomeForm will
    #     pass `form: SomeForm.new` to the constructor
    # * The flash
    #
    # Once this page object exists, `render` will be called to produce HTML to send back to the browser.
    def page(path, **custom_constructor_args)
      route = Brut.container.routing.register_page(path)
      page_class = route.handler_class

      get route.to_s do
        request_context = Thread.current.thread_variable_get(:request_context)
        constructor_args = request_context.as_constructor_args(
          page_class,
          request_params: params,
          flash: flash,
          additional_args: custom_constructor_args
        )
        page page_class.new(**constructor_args)
      end
    end

    # Declares a form that will be submitted to the app.  When the given path receives a POST, a form class is instantiated
    # with the parameters submitted.  The name of the class is based on a convention similar to `page`:
    #
    # * Each part of the path that is not a placeholder will be camelized
    # * Any part of the path that *is* a placholder has its leading colon removed, then is camelized, but appended to
    #   the previous part with `With`, thus `WidgetsWithId` is created from `Widgets`, `With`, and `Id`.
    # * The final part of the path is further appended with `Form`.
    # * These parts now make up a path to a class, so the entire thing is joined by `::` to form the fully-qualified class name.
    #
    # Examples:
    #
    # * `form("/widgets")` will use `WidgetsForm`
    # * `form("/widgets/:id")` will use `WidgetsWithIdForm`
    # * `form("/admin/widgets/:internal_id") will use `Admin::WidgetsWithInternalIdForm`
    #
    def form(path)
      route = Brut.container.routing.register_form(path)
      form_class = route.handler_class

      post route.to_s do
        request_context = Thread.current.thread_variable_get(:request_context)
        constructor_args = request_context.as_constructor_args(
          form_class,
          request_params: params,
          flash: flash,
        )
        form = form_class.new(**constructor_args)

        process_args = request_context.as_method_args(form,:process!, flash: flash, additional_args: { xhr: request.xhr? })

        result = form.process!(**process_args)

        case result
        in redirect:
          redirect to(redirect)
        in page_instance:
          page(page_instance).to_s
        in component_instance:, http_status:
          [
            http_status,
            component(component_instance).to_s,
          ]
        in http_status:
          http_status
        end
      end
    end

    def path(path, method:)
      route = Brut.container.routing.register_path(path, method:)
      handler_class = route.handler_class

      route method.to_s.upcase, path do
        request_context = Thread.current.thread_variable_get(:request_context)
        constructor_args = request_context.as_constructor_args(
          handler_class,
          request_params: params,
          flash: flash,
        )
        handler = handler_class.new(**constructor_args)

        handle_args = request_context.as_method_args(handler,:handle!,
                                                     request_params: params,
                                                     flash: flash,
                                                     additional_args: { xhr: request.xhr? })

        result = handler.handle!(**handle_args)

        case result
        in redirect:
          redirect to(redirect)
        in page_instance:
          page(page_instance).to_s
        in component_instance:, http_status:
          [
            http_status,
            component(component_instance).to_s,
          ]
        in http_status:
          http_status
        end
      end
    end

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
    def pagex(route, page_class: :derive, **rest)
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
                              Thread.current.thread_variable_get(:request_context)[name]
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

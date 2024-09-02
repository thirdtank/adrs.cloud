require "uri"

# Holds the registered routes for this app.
class Brut::FrontEnd::Routing

  include SemanticLogger::Loggable

  def initialize
    @routes = Set.new
  end

  def register_page(path)
    route = PageRoute.new(path)
    @routes << route
    route
  end

  def register_form(path)
    route = FormRoute.new(path)
    @routes << route
    route
  end

  def register_path(path, method:)
    route = Route.new(method, path)
    @routes << route
    route
  end

  def for(handler_class, with_method: :any, **rest)
    route = @routes.detect { |route|
      handler_class_match = route.handler_class == handler_class
      form_class_match = if route.respond_to?(:form_class)
                           route.form_class == handler_class
                         else
                           false
                         end
      handler_class_match || form_class_match
    }
    if !route
      raise ArgumentError,"There is no configured route for #{handler_class}"
    end
    route_allowed_for_method = if with_method == :any
                                 true
                               elsif Brut::FrontEnd::HttpMethod.new(with_method) == route.method
                                 true
                               else
                                 false
                               end
    if !route_allowed_for_method
      raise ArgumentError,"The route for '#{handler_class}' (#{route.path}) is not supported by HTTP method '#{with_method}'"
    end
    route.path(**rest)
  end

  def inspect
    @routes.map { |route|
      "#{route.method}:#{route.path} - #{route.handler_class.name}"
    }.join("\n")
  end

  class Route

    include SemanticLogger::Loggable

    attr_reader :handler_class, :path_template, :method

    def initialize(method,path_template)
      method = Brut::FrontEnd::HttpMethod.new(method)
      if ![:get, :post].include?(method.to_sym)
        raise ArgumentError,"Only GET and POST are supported. '#{method}' is not"
      end
      if path_template !~ /^\//
        raise ArgumentError,"Routes must start with a slash: '#{path_template}'"
      end
      @method        = method
      @path_template = path_template
      @handler_class = self.locate_handler_class(self.suffix,self.preposition)
    end

    def path(**query_string_params)
      path = @path_template.split(/\//).map { |path_part|
        if path_part =~ /^:(.+)$/
          param_name = $1.to_sym
          if !query_string_params.key?(param_name)
            raise ArgumentError,"path for #{@handler_class} requires '#{param_name}' as a path parameter, but it was not specified to #path. Got: #{query_string_params.keys.map(&:to_s).join(", ")}"
          end
          query_string_params.delete(param_name)
        else
          path_part
        end
      }
      uri = URI(path.join("/"))
      uri.query = URI.encode_www_form(query_string_params)
      uri
    end

    def ==(other)
      self.method == other.method && self.path == other.path
    end

  private
    def locate_handler_class(suffix,preposition, allow_missing: false)
      if @path_template == "/"
        return Module.const_get("HomePage")
      end
      path_parts = @path_template.split(/\//)[1..-1]

      part_names = path_parts.reduce([]) { |array,path_part|
        if path_part =~ /^:(.+)$/
          if array.empty?
            raise ArgumentError,"Your path may not start with a placeholder: '#{@path_template}'"
          end
          placeholder_camelized = RichString.new($1).camelize
          array[-1] << preposition
          array[-1] << placeholder_camelized.to_s
        else
          array << RichString.new(path_part).camelize.to_s
        end
        array
      }
      part_names[-1] += suffix
      part_names.inject(Module) { |mod,path_element|
        mod.const_get(path_element)
      }
    rescue NameError => ex
      module_message = if ex.receiver == Module
                         "Could not find"
                       else
                         "Module '#{ex.receiver}' did not have"
                       end
      message = "Cannot find page class for route '#{@path_template}', which should be #{part_names.join("::")}. #{module_message} the class or module '#{ex.name}'"
      if allow_missing
        logger.debug(message)
        return nil
      else
        raise message
      end
    end

    def suffix = "Handler"
    def preposition = "With"

  end

  class PageRoute < Route
    def initialize(path)
      super(Brut::FrontEnd::HttpMethod.new(:get),path)
    end
    def suffix = "Page"
    def preposition = "By"
  end


  class FormRoute < Route
    attr_reader :form_class
    def initialize(path)
      super(Brut::FrontEnd::HttpMethod.new(:post),path)
      @form_class = self.locate_handler_class("Form","With", allow_missing: true)
    end
  end
end


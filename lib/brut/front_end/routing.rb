require "uri"

# Holds the registered routes for this app.
class Brut::FrontEnd::Routing
  def initialize
    @routes = Set.new
  end

  def register_page(path)
    route = PageRoute.new(:get, path)
    @routes << route
    route
  end

  def register_form(path)
    route = FormRoute.new(:post, path)
    @routes << route
    route
  end

  def register_path(path, method:)
    route = Route.new(method, path)
    @routes << route
    route
  end

  def for(handler_class, **rest)
    route = @routes.detect { |route|
      route.handler_class == handler_class
    }
    if !route
      raise ArgumentError,"There is no configured route for #{handler_class}"
    end
    route.path(**rest)
  end

  def inspect
    @routes.map { |route|
      "#{route.method}:#{route.path} - #{route.handler_class.name}"
    }.join("\n")
  end

  class Route

    attr_reader :handler_class, :path, :method

    def initialize(method,path)
      method = method.to_s.downcase.to_sym
      if ![:get, :post].include?(method)
        raise ArgumentError,"Only GET and POST are supported. '#{method}' is not"
      end
      if path !~ /^\//
        raise ArgumentError,"Routes must start with a slash: '#{path}'"
      end
      @method        = method
      @path          = path
      @handler_class = self.locate_handler_class
    end

    def to_s = @path

    def path(**query_string_params)
      path = @path.split(/\//).map { |path_part|
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
      uri.to_s
    end

    def ==(other)
      self.method == other.method && self.path == other.path
    end

  private
    def locate_handler_class
      if @path == "/"
        return Module.const_get("HomePage")
      end
      path_parts = @path.split(/\//)[1..-1]

      part_names = path_parts.reduce([]) { |array,path_part|
        if path_part =~ /^:(.+)$/
          if array.empty?
            raise ArgumentError,"Your path may not start with a placeholder: '#{@path}'"
          end
          placeholder_camelized = RichString.new($1).camelize
          array[-1] << self.preposition
          array[-1] << placeholder_camelized.to_s
        else
          array << RichString.new(path_part).camelize.to_s
        end
        array
      }
      part_names[-1] += self.suffix
      part_names.inject(Module) { |mod,path_element|
        mod.const_get(path_element)
      }
    rescue NameError => ex
      module_message = if ex.receiver == Module
                         "Could not find"
                       else
                         "Module '#{ex.receiver}' did not have"
                       end
      raise "Cannot find page class for route '#{@path}', which should be #{part_names.join("::")}. #{module_message} the class or module '#{ex.name}'"
    end

    def suffix = "Handler"
    def preposition = "With"

  end

  class PageRoute < Route
    def suffix = "Page"
    def preposition = "By"
  end

  class FormRoute < Route
    def suffix = "Form"
    def preposition = "With"
  end
end


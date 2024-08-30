require "uri"

# Holds the registered routes for this app.
class Brut::FrontEnd::Routing
  def initialize
    @routes = {}
  end

  def regsiter(path)
    route = Route.new(path)
    @routes[path] = route
    route
  end

  def for(page_class, **rest)
    route = @routes.values.detect { |route|
      route.page_class == page_class
    }
    route.path(**rest)
  end

  class Route

    attr_reader :page_class

    def initialize(path)
      if path !~ /^\//
        raise ArgumentError,"Routes must start with a slash: '#{path}'"
      end
      @path = path
      @page_class = self.locate_page_class
    end

    def to_s = @path

    def path(**query_string_params)
      path = @path.split(/\//).map { |path_part|
        if path_part =~ /^:(.+)$/
          query_string_params.delete($1.to_sym)
        else
          path_part
        end
      }
      uri = URI(path.join("/"))
      uri.query = URI.encode_www_form(query_string_params)
      uri.to_s
    end

  private
    def locate_page_class
      path_parts = @path.split(/\//)[1..-1]

      part_names = path_parts.reduce([]) { |array,path_part|
        if path_part =~ /^:(.+)$/
          if array.empty?
            raise ArgumentError,"Your path may not start with a placeholder: '#{@path}'"
          end
          placeholder_camelized = RichString.new($1).camelize
          array[-1] << "By"
          array[-1] << placeholder_camelized.to_s
        else
          array << RichString.new(path_part).camelize.to_s
        end
        array
      }
      part_names[-1] += "Page"
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
  end
end

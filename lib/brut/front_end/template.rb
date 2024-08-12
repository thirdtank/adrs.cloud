require "erubi"
Tilt.prefer Tilt::ErubiTemplate

# Handles rendering HTML templates
class Brut::FrontEnd::Template
  # Wraps a string that is deemed safe to insert into
  # HTML without escaping it.  This allows stuff like
  # <%= component(SomeComponent) %> to work without
  # having to remember to <%== all the time.
  class SafeString
    attr_reader :string

    # use ::from_string instead
    def initialize(string)
      @string = string
    end

    # Create a SafeString string either a string or
    # a SafeString
    def self.from_string(string_or_safe_string)
      if string_or_safe_string.kind_of?(self)
        string_or_safe_string
      else
        self.new(string_or_safe_string)
      end
    end
  end

  def initialize(template_file_path)
    @tilt_template = Tilt.new(template_file_path,
                              escape_html: true,
                              escapefunc: "::Brut::FrontEnd::Template::escape_html")
  end

  def render(...)
    @tilt_template.render(...)
  end

  # Replaces Erubi's escape function by checking if the value
  # to render is a SafeString. If so, it's value is rendered as-is
  # without escape. Otherwise, using Erubi's `h` to escape the string.
  def self.escape_html(x)
    if x.kind_of?(SafeString)
      x.string
    else
      Erubi.h(x)
    end
  end
end

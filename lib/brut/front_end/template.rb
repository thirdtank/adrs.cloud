require "erubi"
Tilt.prefer Tilt::ErubiTemplate

class Brut::FrontEnd::Template
  # Wraps a string that is deemed safe to insert into
  # HTML without escaping it.
  class SafeString
    attr_reader :string
    def initialize(string)
      @string = string
    end

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

  def self.escape_html(x)
    if x.kind_of?(SafeString)
      x.string
    else
      Erubi.h(x)
    end
  end
end

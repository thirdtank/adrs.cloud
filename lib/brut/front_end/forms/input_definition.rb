class Brut::FrontEnd::Forms::InputDefinition

  class Email
    REGEXP = /^[^@]+@[^@]+\.[^@]+$/

    def self.pattern = REGEXP.source
    def self.input_type = "email"

    def initialize(string)
      string = string.to_s.strip
      if string =~ REGEXP
        @email = string
      else
        raise ArgumentError.new("'#{string}' is not an email address")
      end
    end

    def to_s = @email
    def eql?(other)
      other.to_s == self.to_s
    end
    def hash = self.to_s.hash
  end

  SPECIAL_TYPES = {
    email: Email
  }

  attr_reader :name, :type, :minlength
  def initialize(name, type, options)
    @name = name.to_s
    @type = SPECIAL_TYPES[type] || type
    @required = options.key?(:required) ? options[:required] : true
    @minlength = options.key?(:minlength) ? options[:minlength].to_i : false
  end

  def required? = !!@required

  def pattern
    if type == Email
      type.pattern
    else
      nil
    end
  end

  def html_input_type
    if type == Email
      "email"
    elsif type == String
      "text"
    else
      raise "Cannot support '#{type}' at this time"
    end
  end

end

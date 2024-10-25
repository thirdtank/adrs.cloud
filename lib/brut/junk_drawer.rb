class SubclassMustImplement < StandardError
  def initialize(additional_message=nil)
    message = if additional_message
                "Subclass must implement: #{additional_message}"
              else
                "Subclass must implement"
              end
    super(message)
  end
end

class Clock
  def initialize(tzinfo_timezone)
    if tzinfo_timezone
      @timezone = tzinfo_timezone
    elsif ENV["TZ"]
      @timezone = begin
                    TZInfo::Timezone.get(ENV["TZ"])
                  rescue TZInfo::InvalidTimezoneIdentifier => ex
                    SemanticLogger[self.class.name].warn("#{ex} from ENV['TZ'] value '#{ENV['TZ']}'")
                    nil
                  end
    end
    if @timezone.nil?
      @timezone = TZInfo::Timezone.get("UTC")
    end
  end

  def now
    Time.now(in: @timezone)
  end

  def in_time_zone(time)
    @timezone.to_local(time)
  end
end

class RichString
  def initialize(string)
    @string = string.to_s
  end

  def underscorized
    return self unless /[A-Z-]|::/.match?(@string)
    word = @string.gsub("::", "/")
    word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
    word.tr!("-", "_")
    word.downcase!
    RichString.new(word)
  end

  def camelize
    @string.to_s.split(/[_-]/).map { |part|
      part.capitalize
    }.join("")
  end

  def humanized
    RichString.new(@string.tr("_-"," "))
  end

  def to_s = @string
  def to_str = self.to_s

  def to_s_or_nil = @string.empty? ? nil : self.to_s

  def ==(other)
    if other.kind_of?(RichString)
      self.to_s == other.to_s
    elsif other.kind_of?(String)
      self.to_s == other
    else
      false
    end
  end

  def <=>(other)
    if other.kind_of?(RichString)
      self.to_s <=> other.to_s
    elsif other.kind_of?(String)
      self.to_s <=> other
    else
      super
    end
  end

  def +(other)
    if other.kind_of?(RichString)
      RichString.new(self.to_s + other.to_s)
    elsif other.kind_of?(String)
      self.to_s + other
    else
      super(other)
    end
  end

end

module Brut::FussyTypeEnforcment
  def type!(value,type_descriptor,variable_name_for_error_message, required = false)

    if !required && value.nil?
      return value
    end

    if required &&
       (
         value.nil? ||
         (
           value.kind_of?(String) &&
           value.strip == ""
         )
       )
      raise ArgumentError.new("'#{variable_name_for_error_message}' must have a value")
    end

    if type_descriptor.kind_of?(Class)
      if !value.kind_of?(type_descriptor)
        raise ArgumentError.new("'#{variable_name_for_error_message}' must be a #{type_descriptor}, but was a #{value.class} (value as a string is #{value})")
      end
    elsif type_descriptor.kind_of?(Array)
      if !type_descriptor.include?(value)
        description_of_values = type_descriptor.map { |value|
          "#{value} (a #{value.class})"
        }.join(", ")
        raise ArgumentError.new("'#{variable_name_for_error_message}' must be one of #{description_of_values}, but was a #{value.class} (value as a string is #{value})")
      end
    else
      raise ArgumentError.new("Use of type! with a #{type_descriptor.class} (#{type_descriptor}) is not supported")
    end
    value
  end
end

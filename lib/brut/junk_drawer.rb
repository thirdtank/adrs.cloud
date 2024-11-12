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
  # Perform basic type checking, ideally inside a constructor when assigning ivars
  #
  # value:: the value that was given
  # type_descriptor:: a class or an array of allowed values. If a class, value must be kind_of? that class. If an array,
  #                   value must be one of the values in the array.
  # variable_name_for_error_message:: the name of the variable so that error messages make sense
  # required:: if true, the value may not be nil. If false, nil values are allowed and no real type checking is done. Note that a
  #            string that is blank counts as nil, so a require string must not be blank.
  # coerce:: if given, this is the symbol that will be used to coerce the value before type checking
  def type!(value,type_descriptor,variable_name_for_error_message, required: false, coerce: false)

    value_blank = value.nil? || ( value.kind_of?(String) && value.strip == "" )

    if !required && value_blank
      return value
    end

    if required && value_blank
      raise ArgumentError.new("'#{variable_name_for_error_message}' must have a value")
    end

    if type_descriptor.kind_of?(Class)
      coerced_value = coerce ? value.send(coerce) : value
      if !coerced_value.kind_of?(type_descriptor)
        class_description = if coerce
                              "but was a #{value.class}, coerced to a #{coerced_value.class} via #{coerce}"
                            else
                              "but was a #{value.class}"
                            end
        raise ArgumentError.new("'#{variable_name_for_error_message}' must be a #{type_descriptor}, #{class_description} (value as a string is #{value})")
      end
      value = coerced_value
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

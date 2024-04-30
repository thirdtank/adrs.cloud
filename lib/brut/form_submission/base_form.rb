class Brut::FormSubmission::BaseForm
  class ConformingValue
    attr_reader :value
    def initialize(value)
      @value = value
    end
    def conforming? = true
  end

  class MissingValue
    def value = nil
    def conforming? = false
    def error = "missing"
  end

  class NonconfirmingValue
    attr_reader :value, :exception
    def initialize(value,exception)
      @value = value
      @exception = exception
    end
    def conforming? = false
    def error = exception.message
  end

  class Input
    attr_reader :name, :type, :minlength
    def initialize(name, type, options)
      @name = name
      @type = type
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

  def [](name)
    self.class.inputs.fetch(name.to_s)
  end

  def self.input(name,type=String,options={})
    if (options.nil? || options.empty?) && type.kind_of?(Hash)
      options = type
      type = String
    end

    @inputs ||= {}
    @inputs[name.to_s] = Input.new(name.to_s,type,options)

    define_method name do
      self.send("_wrapped_#{name}").value
    end

    define_method "_wrapped_#{name}" do
      instance_variable_get("@#{name}")
    end

    define_method "#{name}=" do |raw_val|
      wrapper = if raw_val.nil?
                  self.class.inputs[name.to_s].required? ? MissingValue.new : ConformingValue.new(nil)
                else
                  if raw_val == "" || (raw_val.to_s.strip == "" && type == String)
                    self.class.inputs[name.to_s].required? ? MissingValue.new : ConformingValue.new(nil)
                  else
                    begin
                      ConformingValue.new(type.new(raw_val))
                    rescue => ex
                      NonconfirmingValue.new(raw_val,ex)
                    end
                  end
                end
      instance_variable_set("@#{name}",wrapper)
    end
  end

  def self.inputs
    @inputs || {}
  end

  def initialize(inputs={})
    @new = inputs.keys.empty?
    self.class.inputs.each do |(attr,metadata)|
      val = inputs[attr.to_s] || inputs[attr.to_sym]
      self.send("#{attr}=",val)
    end
  end

  def validation_errors
    self.class.inputs.map { |(attr)|
      [ attr, self.send("_wrapped_#{attr}") ]
    }.reject { |(_,wrapped_value)|
      wrapped_value.conforming?
    }.map { |(attr,wrapped_value)|
      [ attr, "#{attr} is #{wrapped_value.error}" ]
    }.to_h
  end

  def valid? = validation_errors.keys.none?

  def validate!
    errors = self.validation_errors
    if errors.any?
      raise errors.values.join(",")
    end
  end

  def new? = @new

end


require "fileutils"

module Brut
  def self.container(&block)
    @container ||= Brut::Container.new
    if !block.nil?
      block.(@container)
    end
    @container
  end
end

# This is a basic container for shared context, configuration,
# and objects. This allows easily sharing cross-cutting information
# such as project root, environment, and other objects.
#
# This can be used to store configuration values, re-usable objects,
# or anything else that is needed in the app.  Values are fetched lazily
# and can depend on other values in this container.
#
# There is no namespacing/hierarchy.
class Brut::Container
  def initialize
    @container = {}
  end

  # Store a named value for later.
  #
  # name:: The name of the value. This should be a string that is a valid Ruby identifier.
  # type:: String of the name of the class taht represents the type of this value.
  # description:: Documentation as to what this value is for.
  # value:: if given, this is the value to use.
  # block:: If value is omitted, block will be evaluated the first time the value is
  #         fetched and is expected to return the value to use for all subsequent
  #         requests.
  #
  #         The block can receive parameters and those parameters names must
  #         match other values stored in this container.  Those values are passed in.
  #
  #         For example, if you have the value `project_root`, you can then set another
  #         value called `tmp_dir` that uses `project_root` like so:
  #
  #         ```
  #         container.store("tmp_dir") { |project_root| project_root / "tmp" }
  #         ```
  def store(name,type,description,value=:use_block,allow_app_override: false,allow_nil: false,&block)
    # TODO: Check that value / block is used properly
    name = name.to_s
    if type.to_s == "boolean"
      name = "#{name}?".gsub(/\?\?$/,"?")
    end
    self.validate_name!(name,type)
    if value == :use_block
      if type == "boolean"
        derive_with = ->() { !!block.() }
      else
        derive_with = block
      end
      @container[name] = { value: nil, derive_with: derive_with }
    else
      if type == "boolean"
        value = !!value
      end
      @container[name] = { value: value }
    end
    @container[name][:description]        = description
    @container[name][:type]               = type
    @container[name][:allow_app_override] = allow_app_override
    @container[name][:allow_nil]          = allow_nil
    self
  end

  def override(name,value=:use_block,&block)
    name = name.to_s
    if !@container[name]
      raise ArgumentError,"#{name} has not been specified so you cannot override it"
    end
    if !@container[name][:allow_app_override]
      raise ArgumentError,"#{name} does not allow the app to override it"
    end
    if value == :use_block
      @container[name] = { value: nil, derive_with: block }
    else
      @container[name] = { value: value }
    end
  end

  # Store a value that represents a path that must exist. The value will
  # be assumed to be of type Pathname
  def store_required_path(name,description,value=:use_block,&block)
    self.store(name,Pathname,description,value,&block)
    @container[name][:required_path] = true
    self
  end

  # Store a value that represents a path that can be created if
  # it does not exist. The path won't be created until the value is 
  # accessed the first time. The value will
  # be assumed to be of type Pathname
  def store_ensured_path(name,description,value=:use_block,&block)
    self.store(name,Pathname,description,value,&block)
    @container[name][:ensured_path] = true
    self
  end

  # Fetch a value by using its name as a method to instances of this class.
  def method_missing(sym,*args,&block)
    if args.length == 0 && block.nil? && self.respond_to_missing?(sym)
      fetch_value(sym.to_s)
    else
      super.method_missing(sym,*args,&block)
    end
  end

  # Implemented to go along with method_missing
  def respond_to_missing?(name,include_private=false)
    @container.key?(name.to_s)
  end


  # Fetch a value given a name.
  def fetch(name)
    fetch_value(name.to_s)
  end

  # `extend` this module in a class to declare that your class requires
  # values from this container.  This is more expedient than accessing
  # the container inside your constructor.
  module Uses
    # Called at the class level, this declares that instanes of your class need
    # access to the named value. This method will create an instance method for your class
    # named for the variable.
    def uses(name)
      # TODO: Check if the method is defined
      define_method(name) do
        Brut.container.fetch(name)
      end
      private name
    end
  end

private

  def fetch_value(name)
    # TODO: Provide a cleanr impl and better error checking if things go wrong
    x = @container.fetch(name)

    value = x[:value]

    if !value.nil?
      handle_path_values(name,x)
      return value
    end

    deriver = x[:derive_with]

    parameters = deriver.parameters(lambda: true)
    args = parameters.map { |param_description| param_description[1] }.map { |name_of_dependent_object| self.send(name_of_dependent_object) }
    x[:value] = deriver.(*args)
    if x[:value].nil?
      if !x[:allow_nil]
        raise "Something is wrong: #{name} had no value"
      end
    end
    handle_path_values(name,x)
    x[:value]
  end

  def handle_path_values(name,contained_value)
    value = contained_value[:value]
    if contained_value[:required_path] && !Dir.exist?(value)
      raise "For value '#{name}', the directory is represents must exist, but does not: '#{value}'"
    end
    if contained_value[:ensured_path]
      FileUtils.mkdir_p value
    end
  end

  PATHNAME_NAME_REGEXP = /_(dir|file)$/

  def validate_name!(name,type)
    if @container.key?(name)
      raise ArgumentError.new("Name '#{name}' has already been specified - you cannot override it")
    end
    if type.to_s == "Pathname"
      if name != "project_root"
        if !name.match(PATHNAME_NAME_REGEXP)
          raise ArgumentError.new("Name '#{name}' is a Pathname, and must end in '_dir' or '_file'")
        end
      end
    end
  end
end

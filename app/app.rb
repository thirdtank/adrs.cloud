require "sinatra/base"

module MyHelpers
  def button(size: :normal, color: :gray, label:)
    %{
      <button class="button button--size--#{size} button--color--#{color}">
      #{label}
      </button>
    }.strip
  end

  def input_email(name:,autofocus: false, value: nil, required: false)
    text_field(type: :email, name: name, autofocus: autofocus, label: name, value: value, required: required)
  end

  def input_password(name:, value: nil, required: false)
    text_field(type: :password, name: name, autofocus: false, label: name, value: value, required: required)
  end

  def text_field(type:, name:, autofocus:, label:, value:, required:)
    %{
<label class="flex flex-column gap-1 w-100">
<input type="#{ type }" name="#{ name }" value="#{ value }" class="text-field" #{ autofocus ? "autofocus" : "" } #{required ? "required" : "" }>
  <div class="text-field-label">
  #{ label }
  </div>
</label>
    }
  end
end
module FormSubmission
end


module Views
  class BaseView
    include MyHelpers

    attr_reader :content, :errors

    def initialize(content: {}, errors: [])
      @content = content
      @errors  = errors
    end
    def errors? = !@errors.empty?
  end
end

module Content
end

class Views::Login < Views::BaseView
end
class Views::SignUp < Views::BaseView
end

class FormSubmission::BaseFormSubmission
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

  def self.attribute(name,required,type,default: nil)
    @attributes ||= {}
    @attributes[name.to_s] = {
      required: required == :required,
      type: type,
      default: default
    }

    define_method name do
      self.send("_wrapped_#{name}").value
    end

    define_method "_wrapped_#{name}" do
      instance_variable_get("@#{name}")
    end

    define_method "#{name}=" do |raw_val|
      wrapper = if raw_val.nil?
                  MissingValue.new
                else
                  raw_val = raw_val.strip
                  if raw_val == ""
                    MissingValue.new
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

  def self.attributes
    @attributes || {}
  end

  def initialize(attributes={})
    @new = attributes.keys.empty?
    self.class.attributes.each do |(attr,metadata)|
      val = attributes[attr.to_s] || attributes[attr.to_sym]
      self.send("#{attr}=",val)
    end
  end

  def must_conform!
    errors = self.class.attributes.map { |(attr)|
      [ attr, self.send("_wrapped_#{attr}") ]
    }.reject { |(_,wrapped_value)|
      wrapped_value.conforming?
    }.map { |(attr,wrapped_value)|
      "#{attr} is #{wrapped_value.error}"
    }
    if errors.any?
      raise errors.join(",")
    end
  end

  def new? = @new

end

class Email
  def initialize(string)
    string = string.to_s.strip
    if string =~ /^[^@]+@[^@]+\.[^@]+$/
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

class FormSubmission::SignUp < FormSubmission::BaseFormSubmission
  attribute :email, :required, Email
  attribute :password, :required, String
  attribute :password_confirmation, :required, String
end

class FormSubmission::Login < FormSubmission::BaseFormSubmission
  attribute :email, :required, Email
  attribute :password, :required, String
end

module Action
end

module ValidationResult
  class Valid
    def self.invalid? = false
    def self.valid?   = true
  end
  class Invalid
    def invalid? = true
    def valid?   = false

    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end
  end
end

class Action::SignUp

  def validate(form_submission)
    if form_submission.password != form_submission.password_confirmation
      ValidationResult::Invalid.new({ password: "must match confirmatoin" })
    elsif form_submission.password.length < 8
      ValidationResult::Invalid.new({ password: "must be at least 8 characters" })
    else
      ValidationResult::Valid
    end
  end

  def call(form_submission)
    validation_result = validate(form_submission)
    if validation_result.invalid?
      return validation_result
    end

    true
  end
end

class Action::Login

  DATABAS = {
    Email.new("pat@example.com") => "qwertyuiop",
    Email.new("chris@example.com") => "1qaz2wsx",
  }


  def validate(form_submission)
    password = DATABAS[form_submission.email]
    if password
      if password == form_submission.password
        ValidationResult::Valid
      else
        ValidationResult::Invalid.new({ email: "No account with this email and password" })
      end
    else
      ValidationResult::Invalid.new({ email: "No account with this email and password" })
    end
  end

  def call(form_submission)
    validation_result = validate(form_submission)
    if validation_result.invalid?
      return validation_result
    end

    true
  end
end


#
# A form submission is strings, and it must conform to a protocol based on the form
#
# That form submission is then coerced into types so it can be passed to the business logic.
#
#
class AdrApp < Sinatra::Base
  enable :sessions

  get "/" do
    redirect to("/static/index.html")
  end

  get "/login" do
    erb :login, scope: Views::Login.new(content: FormSubmission::Login.new)
  end

  post "/login" do
    login = FormSubmission::Login.new(params)
    login.must_conform!
    action = Action::Login.new
    result = action.call(login)
    case result
    when ValidationResult::Invalid
      erb :login, scope: Views::Login.new(content: login, errors: result.errors)
    else
      session["user"] = login.email
      redirect to("/adrs")
    end
  end

  get "/sign-up" do
    erb :'sign-up', scope: Views::SignUp.new(content: FormSubmission::SignUp.new)
  end

  post "/sign-up" do
    sign_up = FormSubmission::SignUp.new(params)
    sign_up.must_conform!
    action = Action::SignUp.new
    result = action.call(sign_up)
    case result
    when ValidationResult::Invalid
      erb :'sign-up', scope: Views::SignUp.new(content: sign_up, errors: result.errors)
    else
      session["user"] = sign_up.email
      redirect to("/adrs")
    end
  end

  get "/logout" do
    session["user"] = nil
    redirect to("/login")
  end

  get "/adrs" do
    if session["user"].nil?
      redirect to("/login")
    else
      erb :adrs
    end
  end
end

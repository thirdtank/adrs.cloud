require_relative "unix_environment_bootstrap"
require "sinatra/base"
require "sinatra/namespace"

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
Sequel::Model.db = DB

at_exit do
  DB.disconnect
end

require_relative "data_models/account"
require_relative "data_models/adr"

module MyHelpers

  def button(size: :normal, color: :gray, label:)
    %{
      <button class="button button--size--#{size} button--color--#{color}">
      #{label}
      </button>
    }.strip
  end

  def input_text(name:,autofocus: false, value: nil, required: false)
    text_field(type: :text, name: name, autofocus: autofocus, label: name, value: value, required: required)
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

  def form_field(form:, input:, autofocus: false, label: :derive, value: nil, default_type: "text", inner_label: false)
    input = input.to_s
    type = case form.class.inputs[input].type.name
           when Email.name
             "email"
           else
             default_type
           end
    name = input
    required = form.class.inputs[input].required?
    label = if label == :derive
              input.to_s
            else
              label
            end
    pattern = if form.class.inputs[input].type.respond_to?(:pattern)
                "pattern='#{ form.class.inputs[input].type.pattern }'"
              else
                nil
              end
    if type != "textarea"
      if inner_label
        raise "inner_label is only valid for a textarea"
      end
    %{
<label class="flex flex-column gap-1 w-100">
<input type="#{ type }" name="#{ name }" value="#{ value }" class="text-field" #{ autofocus ? "autofocus" : "" } #{required ? "required" : "" } #{pattern}>
  <div class="text-field-label">
  #{ label }
  </div>
</label>
    }
    else
    %{<textarea #{required ? 'required' : '' } rows="3" name="#{name}" class="textarea">#{ value ? value : "" }</textarea>}
    end
  end

  def textarea(name:, label:, value: false, required: false, inner_label: false)
    %{
      <label class="flex flex-column gap-1 w-100">
        <div class="textarea-container">
          #{ inner_label ? "<div class=\"inner-label\">#{inner_label}</div>" : '' }
          <textarea #{required ? 'required' : '' } rows="3" name="#{name}" class="textarea">#{ value ? value : "" }</textarea>
        </div>
        <div class="text-field-label">
          <span class="f-1">#{ label }</span>
        </div>
      </label>
    }
  end
end
module FormSubmission
end

module Component
  class BaseComponent
    include MyHelpers
    attr_writer :component_locator

    def initialize
      @component_locator = NullTemplateLocator.new
    end

    def template_name = underscore(self.class.name).gsub(/^component\//,"")
    def binding_scope = binding

    def component(component_instance)
      component_instance.component_locator = @component_locator
      erb_file = @component_locator.locate(component_instance.template_name)
      template = ERB.new(File.read(erb_file))

      scope = component_instance.binding_scope
      template.result(scope)
    end

  private
    def underscore(string)
      return string.to_s.dup unless /[A-Z-]|::/.match?(string)
      word = string.to_s.gsub("::", "/")
      word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end

module Component
  module Adrs
  end
end
class Component::Adrs::Form < Component::BaseComponent
  def initialize(adr, action_label)
    @adr = adr
    @action_label = action_label
  end
  def adr = @adr
  def action_label = @action_label
  def adr_textarea(name:, prefix:, label:)
    component(Component::Adrs::Textarea.new(adr, name, prefix, label))
  end
end

class Component::Adrs::Textarea < Component::BaseComponent
  attr_reader :adr, :name, :prefix, :label
  def initialize(adr, name, prefix, label)
    @adr = adr
    @name = name
    @prefix = prefix
    @label = label
  end
end

class Component::TextField < Component::BaseComponent
  def blah
  %{
<label class="flex flex-column gap-1 w-100">
<input type="#{ type }" name="#{ name }" value="#{ value }" class="text-field" #{ autofocus ? "autofocus" : "" } #{required ? "required" : "" } #{pattern}>
  <div class="text-field-label">
  #{ label }
  </div>
</label>
  }
  end
end

class TemplateLocator
  def initialize(path:, extension:)
    @path = Pathname(path)
    @extension = extension
  end

  def locate(base_name)
    @path / "#{base_name}.#{@extension}"
  end
end

class NullTemplateLocator
  def locate(base_name) = "SOMETHING IS WRONG NO LOCATOR WAS SET UP"
end

module Page
  class BasePage
    include MyHelpers

    attr_reader :content, :errors
    attr_writer :component_locator

    def initialize(content: {}, errors: [], default_scope: nil)
      @content = content
      @errors  = errors
      @_default_scope = default_scope
      @component_locator = NullTemplateLocator.new
    end
    def errors? = !@errors.empty?
    def erb(...)
      @_default_scope.erb(...)
    end

    def binding_scope = binding

    def template_name = underscore(self.class.name).gsub(/^page\//,"")
    def layout = "default"

    def component(component_instance)
      component_instance.component_locator = @component_locator
      erb_file = @component_locator.locate(component_instance.template_name)
      template = ERB.new(File.read(erb_file))

      scope = component_instance.binding_scope
      template.result(scope)
    end

  private
    def underscore(string)
      return string.to_s.dup unless /[A-Z-]|::/.match?(string)
      word = string.to_s.gsub("::", "/")
      word.gsub!(/(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-z\d])(?=[A-Z])/, "_")
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end
end

module Content
end

class Page::Login < Page::BasePage
end
class Page::SignUp < Page::BasePage
end
class Page::Adrs < Page::BasePage
  def adrs = @content
  def adr_path(adr) = "/adrs/#{adr.external_id}"
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"
end
class Page::Adrs::New < Page::BasePage
  def adr = @content
end
class Page::Adrs::Edit < Page::Adrs::New
end
class Page::Adrs::Get < Page::BasePage
  def adr = @content
end

class Email
  REGEXP = /^[^@]+@[^@]+\.[^@]+$/

  def self.pattern
    REGEXP.source
  end

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

class FormSubmission::BaseForm
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
    attr_reader :name, :type
    def initialize(name, type, options)
      @name = name
      @type = type
      @required = options.key?(:required) ? options[:required] : true
    end

    def required? = !!@required
  end

  def self.input(name,type=String,options={})
    if options.nil? && type.kind_of?(Hash)
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
                  if raw_val == ""
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

  def validate!
    errors = self.class.inputs.map { |(attr)|
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

class FormSubmission::Login < FormSubmission::BaseForm
  input :email, Email
  input :password
end

class FormSubmission::SignUp < FormSubmission::BaseForm
  input :email, Email
  input :password
  input :password_confirmation
end

class FormSubmission::DraftAdr < FormSubmission::BaseForm
  input :title
  input :context
  input :facing
  input :decision
  input :neglected
  input :achieve
  input :accepting
  input :because
  input :external_id, String, { required: false }

  def self.from_adr(adr)
    self.new(
      external_id: adr.external_id,
      title: adr.title,
      context: adr.context,
      facing: adr.facing,
      decision: adr.decision,
      neglected: adr.neglected,
      achieve: adr.achieve,
      accepting: adr.accepting,
      because: adr.because
    )
  end
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
    if Account[email: form_submission.email.to_s]
      return ValidationResult::Invalid.new({ email: "is taken" })
    end

    Account.create(email: form_submission.email,
                   created_at: DateTime.now)

  end
end

class Action::Login

  def call(form_submission)
    account = Account[email: form_submission.email.to_s]
    if account
      account
    else
      ValidationResult::Invalid.new({ email: "No account with this email and password" })
    end
  end
end

class Action::DraftAdr
  def call(form_submission:, account:)
    if form_submission.title.to_s.strip == ""
      return ValidationResult::Invalid.new({ title: "may not be blank" })
    end
    if form_submission.external_id
      adr = Adr[external_id: form_submission.external_id, account_id: account.id]
      if !adr
        raise "account does not have an ADR with that ID"
      end
    else
      adr = Adr.new
    end
    adr.update(account_id: account.id,
               title: form_submission.title,
               context: form_submission.context,
               facing: form_submission.facing,
               decision: form_submission.decision,
               neglected: form_submission.neglected,
               achieve: form_submission.achieve,
               accepting: form_submission.accepting,
               because: form_submission.because,
              )
  end
end

class AdrApp < Sinatra::Base

  register Sinatra::Namespace

  enable :sessions
  set :session_secret, ENV.fetch("SESSION_SECRET")
  set :components, Proc.new { root + "/components" }
  set :pages,      Proc.new { root + "/pages" }
  set :layouts,    Proc.new { root + "/layouts" }

  before do
    if request.path_info !~ /^\/auth\//
      @account = Account[external_id: session["user_id"]]
      if !@account
        redirect to("/auth/login")
        return
      end
    end
  end

  def page(page_instance)
    layout_locator    = TemplateLocator.new(path: settings.layouts,    extension: "layout.erb")
    page_locator      = TemplateLocator.new(path: settings.pages,      extension: "page.erb")
    component_locator = TemplateLocator.new(path: settings.components, extension: "component.erb")

    page_instance.component_locator = component_locator
    layout_erb_file = layout_locator.locate(page_instance.layout)
    layout_template = ERB.new(File.read(layout_erb_file))

    erb_file = page_locator.locate(page_instance.template_name)
    template = ERB.new(File.read(erb_file))

    template_binding = page_instance.binding_scope do
      scope = page_instance.binding_scope
      template.result(scope)
    end
    layout_template.result(template_binding)
  end

  get "/" do
    redirect to("/static/index.html")
  end

  namespace "/auth" do

    get "/login" do
      page Page::Login.new(content: FormSubmission::Login.new)
    end

    post "/login" do
      login = FormSubmission::Login.new(params)
      login.validate!
      action = Action::Login.new
      result = action.call(login)
      case result
      when ValidationResult::Invalid
        page Page::Login.new(content: login, errors: result.errors)
      else
        session["user_id"] = result.external_id
        redirect to("/adrs")
      end
    end

    get "/sign-up" do
      page Page::SignUp.new(content: FormSubmission::SignUp.new)
    end

    post "/sign-up" do
      sign_up = FormSubmission::SignUp.new(params)
      sign_up.validate!
      action = Action::SignUp.new
      result = action.call(sign_up)
      case result
      when ValidationResult::Invalid
        page Page::SignUp.new(content: sign_up, errors: result.errors)
      else
        puts result.inspect
        session["user_id"] = result.external_id
        redirect to("/adrs")
      end
    end

    get "/logout" do
      session["user_id"] = nil
      redirect to("/auth/login")
    end
  end

  get "/adrs" do
    page Page::Adrs.new(content: @account.adrs)
  end

  get "/adrs/new" do
    page Page::Adrs::New.new(content: FormSubmission::DraftAdr.new)
  end

  get "/adrs/:id" do
    page Page::Adrs::Get.new(content: Adr[account_id: @account.id, external_id: params[:id]])
  end

  get "/adrs/:id/edit" do
    page Page::Adrs::Edit.new(content: FormSubmission::DraftAdr.from_adr(Adr[account_id: @account.id, external_id: params[:id]]))
  end

  #
  # A POST from a browser/web page is going to be form data, which is a hash of keys to strings or hashes of the same.
  #
  # Declare your form as all the values that are allowed:
  #
  # value «name», «type», «options»
  #
  #   - «name» is required
  #   - «type» can be omitted and, if so, will be assumed to be a String.
  #     - String - value is a string
  #     - :boolean - value is a boolean
  #     - Date - value is a Date
  #     - Time - value is a timestamp
  #     - Email - value is an email address
  #     - File - value is a file
  #     - Numeric - value is a number
  #     - Url - value is a URL
  #     - Time - value is a time
  #   - «options» can be omitted, but respects the following values:
  #     - required: true/false (default true)
  #     - min/max: min/max range of allowed values
  #     - allowed_values: array of allowed values
  #     - minlength/maxlength: min/max length
  #     - pattern: Regexp that it must match
  #
  # It is cosidered a programmer error if a form is submitted that does not conform to the constraints
  #
  # This metadata can be used to create <input> fields
  #
  # A GET from a browser/web page is a request for possibly dynamic HTML.  The HTML's dynamic info is considered "content".
  # 
  post "/adrs" do
    puts params["test"]
    puts params[:test]
    draft_adr = FormSubmission::DraftAdr.new(params)
    draft_adr.validate!
    action = Action::DraftAdr.new
    result = action.call(form_submission: draft_adr, account: @account)
    case result
    when ValidationResult::Invalid
      erb :'adrs/new', scope: Page::Adrs::New.new(content: draft_adr, errors: result.errors, default_scope: self)
    else
      redirect to("/adrs")
    end
  end
end

#
# A view is represented by a class that responds to #content  This method provides access
#   to all content the view needs to render itself.
#
# A form submission's data is populated into a FormSubmission instance.  The purpose of this
#   class is to mimic the form's requirements and coerce the strings from the request into
#   typed values.  This process must succeed for eveyr single valid submission the user could make.
#   For example, if a field is required, the browser will require it.  Thus, submission when it's
#   missing is an error, not a validation problem.
#
#   In a sense the form describes what's coming in.
#
#   OK - WHY.  Isn't this confusing?  This means there are two levels of validation happening: one for the
#   conformance of the form and a second for the user-level valditations. Potentially two type coercions
#   are happening as well.
#
#   What if we instead stick to HTML?  Coerce only the types provided?
#
#   How much of a problem is it to get a form submitted without stuff the front end requires?
#
# Let's take this over - what needs to happen when a form is submitted:
#
#   - Validations - did the user make an expected mistake?
#   - If data is good, initiate actions
#     - If further validations reveal problem, go back to the user
#     - If there is an unrecoverable error, go back to the user
#     - Otherwise, send them somehwere to indicate they are done
#
# Thinking about this as HTTP/HTML:
#
# * get - returns content, possibly dynamically rendered
# * post - processes a form submission
#
# What about PATCH, DELETE, and PUT?
#
# These seem largely useless and magnets for debate and confusion - what if we ignore them?
#
# What would this buy us?
#
# * It would simplify possible interactions to just gets and posts, making it much easier to decide where logic
#   would go: fetching data is a get and submitting info is a post.
# * Symmetry with HTML - no need for _method hack
# * No need for JSON parsing by default - always a formdata or whatever
#
# What about APIs?
#
# * These could still use the normal HTTP verbs.
# * These can use content types as usual
# * Would not conflate the API with the web app
#
# How could commonalities be leveraged?
#
# * each get route would be associated with a Page and a Query
# * each post route would be associated with an Action, a Form, and routes for valid/not valid
#
# e.g.
#
# get "/adrs", Page::AdrIndex, Query::Adrs
#
# post "/adrs", Action::NewAdr, Form::Adr

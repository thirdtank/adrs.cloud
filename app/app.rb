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


module Views
  class BaseView
    include MyHelpers

    attr_reader :content, :errors

    def initialize(content: {}, errors: [], default_scope:)
      @content = content
      @errors  = errors
      @_default_scope = default_scope
    end
    def errors? = !@errors.empty?
    def erb(...)
      @_default_scope.erb(...)
    end
  end
end

module Content
end

class Views::Login < Views::BaseView
end
class Views::SignUp < Views::BaseView
end
class Views::Adrs < Views::BaseView
  def adrs = @content
  def adr_path(adr) = "/adrs/#{adr.external_id}"
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"
end
class Views::Adrs::New < Views::BaseView
  def adr = @content
  def adr_textarea(name:, prefix:, label:)
    textarea(name: name, label: label, inner_label: prefix, value: adr.send(name))
  end
  def title = "Draft New ADR"
  def action_label = "Draft ADR"
end
class Views::Adrs::Edit < Views::Adrs::New
  def title = "Edit ADR"
  def action_label = "Update Draft"
end
class Views::Adrs::Get < Views::BaseView
  def adr = @content
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
                  self.class.attributes[name.to_s][:required] ? MissingValue.new : ConformingValue.new(nil)
                else
                  if raw_val == ""
                    self.class.attributes[name.to_s][:required] ? MissingValue.new : ConformingValue.new(nil)
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

class FormSubmission::DraftAdr < FormSubmission::BaseFormSubmission
  attribute :title, :required, String
  attribute :context, :required, String
  attribute :facing , :required, String
  attribute :decision , :required, String
  attribute :neglected , :required, String
  attribute :achieve , :required, String
  attribute :accepting , :required, String
  attribute :because , :required, String
  attribute :external_id, :optional, String

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

  before do
    if request.path_info !~ /^\/auth\//
      @account = Account[external_id: session["user_id"]]
      if !@account
        redirect to("/auth/login")
        return
      end
    end
  end

  get "/" do
    redirect to("/static/index.html")
  end

  namespace "/auth" do

    get "/login" do
      erb :login, scope: Views::Login.new(content: FormSubmission::Login.new, default_scope: self)
    end

    post "/login" do
      login = FormSubmission::Login.new(params)
      login.must_conform!
      action = Action::Login.new
      result = action.call(login)
      case result
      when ValidationResult::Invalid
        erb :login, scope: Views::Login.new(content: login, errors: result.errors, default_scope: self)
      else
        session["user_id"] = result.external_id
        redirect to("/adrs")
      end
    end

    get "/sign-up" do
      erb :'sign-up', scope: Views::SignUp.new(content: FormSubmission::SignUp.new, default_scope: self)
    end

    post "/sign-up" do
      sign_up = FormSubmission::SignUp.new(params)
      sign_up.must_conform!
      action = Action::SignUp.new
      result = action.call(sign_up)
      case result
      when ValidationResult::Invalid
        erb :'sign-up', scope: Views::SignUp.new(content: sign_up, errors: result.errors, default_scope: self)
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
    adrs = Views::Adrs.new(content: @account.adrs, default_scope: self)
    erb :adrs, scope: adrs
  end

  get "/adrs/new" do
    erb :'adrs/new', scope: Views::Adrs::New.new(content: FormSubmission::DraftAdr.new, default_scope: self)
  end

  get "/adrs/:id" do
    erb :'adrs/get', scope: Views::Adrs::Get.new(content: Adr[account_id: @account.id, external_id: params[:id]], default_scope: self)
  end

  get "/adrs/:id/edit" do
    erb :'adrs/new', scope: Views::Adrs::Edit.new(content: FormSubmission::DraftAdr.from_adr(Adr[account_id: @account.id, external_id: params[:id]]), default_scope: self)
  end

  post "/adrs" do
    draft_adr = FormSubmission::DraftAdr.new(params)
    draft_adr.must_conform!
    action = Action::DraftAdr.new
    result = action.call(form_submission: draft_adr, account: @account)
    case result
    when ValidationResult::Invalid
      erb :'adrs/new', scope: Views::Adrs::New.new(content: draft_adr, errors: result.errors, default_scope: self)
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
# * each get route would be associated with a View and a Query
# * each post route would be associated with an Action, a Form, and routes for valid/not valid
#
# e.g.
#
# get "/adrs", Views::AdrIndex, Query::Adrs
#
# post "/adrs", Action::NewAdr, Form::Adr

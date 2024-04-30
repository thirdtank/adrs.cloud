require "brut"
require "sinatra/base"
require "sinatra/namespace"

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
Sequel::Model.db = DB

at_exit do
  DB.disconnect
end

require_relative "view/components/base_component"
require_relative "view/pages/base_page"
require_relative "data_models/account"
require_relative "data_models/adr"

module FormSubmission
end

module Components
  module Adrs
  end
end

class Components::Adrs::Form < Components::BaseComponent
  def initialize(adr, action_label)
    @adr = adr
    @action_label = action_label
  end
  def adr = @adr
  def action_label = @action_label
  def adr_textarea(name:, prefix:, label:)
    component(Components::Adrs::Textarea.new(adr, name, prefix, label))
  end
end

class Components::Adrs::Textarea < Components::BaseComponent
  attr_reader :adr, :name, :prefix, :label
  def initialize(adr, name, prefix, label)
    @adr = adr
    @name = name
    @prefix = prefix
    @label = label
  end
end

class Pages::Login < Pages::BasePage
end
class Pages::SignUp < Pages::BasePage
end
class Pages::Adrs < Pages::BasePage

  def accepted_adrs = @content.select(&:accepted?).sort_by(&:accepted_at)
  def draft_adrs    = @content.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @content.select(&:rejected?).sort_by(&:rejected_at)

  def adr_path(adr)      = "/adrs/#{adr.external_id}"
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"
end
class Pages::Adrs::New < Pages::BasePage
  def adr = @content
end
class Pages::Adrs::Edit < Pages::Adrs::New
end

class Pages::Adrs::Get < Pages::BasePage
  class Markdown < Redcarpet::Render::HTML
    def header(text,header_level)
      super.header(text,header_level.to_i + 3)
    end
  end
  def edit_adr_path(adr) = "/adrs/#{adr.external_id}/edit"

  def initialize(...)
    super(...)
    @markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true,
        no_images: true,
        no_styles: true,
        safe_links_only: true,
        link_attributes: { class: "blue-400" },
      ),
      fenced_code_blocks: true,
      autolink: true,
      quote: true,
    )
  end

  def adr = @content

  def markdown(field)
    value = "**#{field_text(field)}** #{adr.send(field)}"
    @markdown.render(value)
  end

  def field_text(field)
    case field
    when :context   then "In the context of"
    when :facing    then "Facing"
    when :decision  then "We decided"
    when :neglected then "Neglecting"
    when :achieve   then "To achieve"
    when :accepting then "Accepting"
    when :because   then "Because"
    else raise ArgumentError.new("No such field '#{field}'")
    end
  end
end

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

class FormSubmission::Login < Brut::FormSubmission::BaseForm
  input :email, Email
  input :password
end

class FormSubmission::SignUp < Brut::FormSubmission::BaseForm
  input :email, Email
  input :password, { minlength: 8 }
  input :password_confirmation, { minlength: 8 }
end

class FormSubmission::AcceptedAdr < Brut::FormSubmission::BaseForm
  input :external_id
end

class FormSubmission::RejectedAdr < Brut::FormSubmission::BaseForm
  input :external_id
end

class FormSubmission::DraftAdr < Brut::FormSubmission::BaseForm
  input :title
  input :context, required: false
  input :facing, required: false
  input :decision, required: false
  input :neglected, required: false
  input :achieve, required: false
  input :accepting, required: false
  input :because, required: false
  input :external_id, { required: false }

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

    def self.raise_on_error!
    end
  end

  class Invalid
    def invalid? = true
    def valid?   = false

    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def raise_on_error!
      raise @errors.inspect
    end
  end
end

class Action::SignUp

  class ServerSideValidator
    def validate(form_submission:)
      if form_submission.password != form_submission.password_confirmation
        { password: "must match confirmatoin" }
      else
        if Account[email: form_submission.email.to_s]
          { email: "is taken" }
        else
          {}
        end
      end
    end
  end

  def call(form_submission:)
    Account.create(email: form_submission.email,
                   created_at: DateTime.now)
  end
end

class Action::Login

  def call(form_submission:)
    account = Account[email: form_submission.email.to_s]
    if account
      account
    else
      ValidationResult::Invalid.new({ email: "No account with this email and password" })
    end
  end
end

module Brut::Actions
end

class Brut::Actions::BaseAction
end

class Brut::Actions::NullValidator
  def validate(*)
    {}
  end
end

class Brut::Actions::ClientSideFormSubmissionValidator
  def validate(form_submission:, **rest)
    if form_submission.valid?
      {}
    else
      form_submission.validation_errors
    end
  end
end

#
# A form submission has three steps:
#
# 1 - re-validate the client-side requirements
# 2 - perform any server-side validations
# 3 - perform the action
class Brut::Actions::FormSubmission < Brut::Actions::BaseAction
  def initialize(client_side_validator: :default, server_side_validator: :default, action:)
    if client_side_validator == :default
      client_side_validator = Brut::Actions::ClientSideFormSubmissionValidator.new
    end
    if server_side_validator == :default
      server_side_validator = begin
                                action.class.const_get("ServerSideValidator").new
                              rescue NameError
                                Brut::Actions::NullValidator.new
                              end
    end
    @client_side_validator = client_side_validator
    @server_side_validator = server_side_validator
    @action                = action
  end

  def call(form_submission:, **rest)
    validation_errors = @client_side_validator.validate(form_submission:form_submission,**rest)
    if validation_errors.any?
      return ValidationResult::Invalid.new(validation_errors)
    end
    validation_errors = @server_side_validator.validate(form_submission:form_submission,**rest)
    if validation_errors.any?
      return ValidationResult::Invalid.new(validation_errors)
    end
    @action.call(form_submission: form_submission, **rest)
  end
end

module Brut::Validations
end
class Brut::Validations::BaseValidator
  def self.validate(attribute,options)
    @@validations ||= {}
    @@validations[attribute] = options
  end

  def validate(object)
    @@validations.map { |attribute,options|
      value = object.send(attribute)
      errors = options.map { |option, option_value|
        case option
        when :required
          if option_value == true
            if value.to_s.strip == ""
              "is required"
            else
              nil
            end
          end
        when :minlength
          if value.respond_to?(:length) || value.nil?
            if value.nil? || value.length < option_value
              "must be at least '#{option_value}' long"
            else
              nil
            end
          else
            raise "'#{attribute}''s value (a '#{value.class}') does not respond to 'length' - :minlength cannot be used as a validation"
          end
        else
          raise "'#{option}' is not a recognized validation option"
        end
      }.compact

      if errors.any?
        [ attribute, errors ]
      else
        nil
      end
    }.compact.to_h
  end

end

class Action::AcceptAdr < Brut::Actions::BaseAction
  class ServerSideValidator 
    class AcceptedAdrValidator < Brut::Validations::BaseValidator
      validate :context   , required: true , minlength: 10
      validate :facing    , required: true , minlength: 10
      validate :decision  , required: true , minlength: 10
      validate :neglected , required: true , minlength: 10
      validate :achieve   , required: true , minlength: 10
      validate :accepting , required: true , minlength: 10
      validate :because   , required: true , minlength: 10
    end

    def validate(form_submission:,account:)
      adr = Adr[external_id: form_submission.external_id, account_id: account.id]
      if !adr
        raise "account does not have an ADR with that ID"
      end
      AcceptedAdrValidator.new.validate(adr)
    end
  end

  def call(form_submission:, account:)
    if !adr.accepted?
      adr.update(accepted_at: Time.now)
    end
    ValidationResult::Valid
  end

end

class Action::RejectAdr < Brut::Actions::BaseAction

  def call(form_submission:, account:)
    adr = Adr[external_id: form_submission.external_id, account_id: account.id]
    if adr.accepted?
      raise "Accepted ADR may not be rejected"
    end
    adr.update(rejected_at: Time.now)
  end

end

class Action::DraftAdr < Brut::Actions::BaseAction
  class ServerSideValidator
    def validate(form_submission:,account:)
      if form_submission.title.to_s.strip !~ /\s+/
        return { title: "must be at least two words" }
      end
      {}
    end
  end

  def call(form_submission:, account:)
    if form_submission.external_id
      adr = Adr[external_id: form_submission.external_id, account_id: account.id]
      if !adr
        raise "account does not have an ADR with that ID"
      end
    else
      adr = Adr.new(created_at: Time.now)
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
  include Brut::SinatraHelpers

  before do
    if request.path_info !~ /^\/auth\// && request.path_info != "/"
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
      page Pages::Login.new(content: FormSubmission::Login.new)
    end

    post "/login" do
      login = FormSubmission::Login.new(params)
      result = process_form form_submission: login,
                            action: Action::Login.new
      case result
      in errors:
        page Pages::Login.new(content: login, errors: errors)
      in Account
        session["user_id"] = result.external_id
        redirect to("/adrs")
      end
    end

    get "/sign-up" do
      page Pages::SignUp.new(content: FormSubmission::SignUp.new)
    end

    post "/sign-up" do
      sign_up = FormSubmission::SignUp.new(params)
      result = process_form form_submission: sign_up,
                            action: Action::SignUp.new
      case result
      when ValidationResult::Invalid
        page Pages::SignUp.new(content: sign_up, errors: result.errors)
      else
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
    page Pages::Adrs.new(content: @account.adrs)
  end

  get "/adrs/new" do
    page Pages::Adrs::New.new(content: FormSubmission::DraftAdr.new)
  end

  get "/adrs/:id" do
    page Pages::Adrs::Get.new(content: Adr[account_id: @account.id, external_id: params[:id]])
  end

  get "/adrs/:id/edit" do
    page Pages::Adrs::Edit.new(content: FormSubmission::DraftAdr.from_adr(Adr[account_id: @account.id, external_id: params[:id]]))
  end

  post "/adrs" do
    draft_adr = FormSubmission::DraftAdr.new(params)
    result = process_form form_submission: draft_adr,
                          action: Action::DraftAdr.new,
                          account: @account
    case result
    in errors:
      page Pages::Adrs::New.new(content: draft_adr, errors: errors)
    else
      redirect to("/adrs")
    end
  end

  post "/accepted_adrs" do
    accepted_adr = FormSubmission::AcceptedAdr.new(params)
    result = process_form form_submission: accepted_adr,
                          action: Action::AcceptAdr.new,
                          account: @account
    case result
    when ValidationResult::Invalid
      page Pages::Adrs::Edit.new(
        content: FormSubmission::DraftAdr.from_adr(Adr[account_id: @account.id, external_id: accepted_adr.external_id]),
        errors: result.errors
      )
    else
      redirect to("/adrs/#{accepted_adr.external_id}")
    end
  end
  post "/rejected_adrs" do
    rejected_adr = FormSubmission::RejectedAdr.new(params)
    process_form form_submission: rejected_adr,
                 action: Action::RejectAdr.new,
                 account: @account
    redirect to("/adrs")
  end
end

module Brut::Actions
  autoload(:NullValidator,"brut/actions/null_validator")
  autoload(:FormSubmission,"brut/actions/form_submission")
  autoload(:Validator,"brut/actions/validator")
  autoload(:Validators,"brut/actions/validator")
  autoload(:CheckResult,"brut/actions/check_result")
end

# Actions are the core abstraction for performing logic.  An Action can do or be anything - it's merely a seam
# between infrastructure like responding to HTTP or a job and your app's particular code or logic.
#
# Because an Action can be anything, it's a very minimal abstraction.  An Action implements two methods:
#
# * `check` - this performs any checking or validation to determine if the action can be called and should succeeed.
#             `check` is intended to take all the inputs of the action and, if anything is wrong, return a structure
#             explaining the problem.   This is similar to calling `.valid?` on an Active Record and then looking at
#             its `errors`, however this is less tied to database tables and field validations.
#
#             `check` is expected to return a `Brut::Action::CheckResult` which can hold three types of information:
#
#             - Is `call` expected to succeed?
#             - If not, structured errors to explain why `call` will fail
#             - Any additional context, for example records fetched from the database
# * `call` - This performs the action.  It can return anything meaningful to the caller.  In particular,
#            it could return a `Brut::Action::CheckResult`, thus implying that `call` may call `check`.  This is
#            not required, but usually handy to avoid having to explicitly call `check`
#
# The definition of "success" is important for the Action concept.  An invocation of `call` will have one
# of three possible outcomes:
#
# * a `CheckResult` is returned. This indicates `call` should not have been called and/or will never succeed and that the 
#   caller must provide different inputs.  A common example might be that an email is required, but the stringn provided isn't an
#   email.
# * Any other value is returned. This indicates `call` did whatever it was supposed to do.  Depending on what is needed,
#   this could be `nil` or some sort of object.  It is up to the implementor and the caller to determine what makes sense,
#   but in no way should this eventuality be considered an "error".
# * An exception is thrown.  This indicates an ephemeral or transient error occurred. There was no way to forsee or prevent this
#   and `call` should be tried again - it will not have had its desired affect. Note that this highly depends on how `call`
#   is implemented. It should be idempotent so that a retry is safe.  this is up to the programmer to do, and Brut will
#   necessarily re-try `call`.
#
class Brut::Action

  def call(*)
    throw "Subclass must implement"
  end

  def check(*)
    Brut::Actions::CheckResult.new
  end

private

  def check_result = Brut::Actions::CheckResult.new

end

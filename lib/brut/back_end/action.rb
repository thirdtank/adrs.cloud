module Brut::BackEnd::Actions
  autoload(:FormSubmission,"brut/back_end/actions/form_submission")
  autoload(:Validator,"brut/back_end/actions/validator")
  autoload(:Validators,"brut/back_end/actions/validator")
  autoload(:CheckResult,"brut/back_end/actions/check_result")
end

# Actions are the seam between the front end and the back-end.  You are required to use an Action
# to process a form submission using Brut's form submission subsystem, but your business logic
# and other domain logic can be implemented any way you like.
#
# An Action must implement the method `call`.
#
# `call` performs the action.  It will have one of three possible outcomes:
#
# * A `CheckResult` is returned. This indicates `call` should not have been called and/or will never succeed and that the 
#   caller must provide different inputs.  A common example might be that an email is required, but the 
#   string provided wasn't an email.
# * Any other value is returned. This indicates `call` did whatever it was supposed to do.  The actual value depends on
#   what the action is supposed to accomplish.  It is recommended to return as little as possible, potentially
#   returning `nil`.  Regardless, if a `CheckResult` is not returned, the action is considered to have completed
#   successfully or otherwise should not be re-tried.
# * An exception is raised.  This indicates an ephemeral or transient error occurred. There was no way to forsee 
#   or prevent this and `call` should be tried again - it will not have had its desired affect.
#   Note that `call` must be carefully implemented to allow a retry to be safe, so if you cannot guarantee that
#   do not raise an exception.
class Brut::BackEnd::Action
  include SemanticLogger::Loggable

  def call(*)
    throw "Subclass must implement"
  end

  def check(*)
    Brut::BackEnd::Actions::CheckResult.new
  end

private

  # Helper method to create a `CheckResult`
  def check_result = Brut::BackEnd::Actions::CheckResult.new

end

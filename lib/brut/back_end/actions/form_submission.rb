# Handles common patterns needed when processing a form that may have constraint violations.
#
# ## Context
#
# An HTML `<form>` can have zero or more constraints as defined in the HTML. These
# should be validated client-side and prevent the form from being submitted, however 
# this is not guaranteed. Further, a form may have constraints that can only be validated
# on the server side.
#
# In any case of constraint violation, the form should not be processed and the user
# should be told what the problem is that's preventing the form from being submitted.
#
# In fact, *anything* that prevents the form from being submitted—other than ephemeral
# errors like network connectivity—should be considered a constraint on that form.
#
# ## Relation to `Brut::FrontEnd::Form`
#
# Ideally, you have described your form by creating a subclass of `Brut::FrontEnd::Form`.  This allows
# you to declare all of your client-side constraints.  If you further use this, along with Brut's
# built-in components to generate HTML, your form will be configured to check all constraints
# on the client-side.
#
# ## Where This Class Fits
#
# When a form is submitted, your form object is created with the HTTP parameters and passed to
# this class' `process_form` method.  Because your form's constraints are described in Ruby,
# you can evaluate the submitted data against those constraints on the server-side as well.
#
# This class also accepts an object that will perform whatever action is required to process
# the form's data.  This class is expected to evaluate any server-side constraints before
# it processes the form's data.
#
# If your action identifies server-side constraints, those will be populated into the form
# object and returned.  Your UI can then examine the form's `constraint_violations` to decide
# what to do.
#
# If no constraints are violated, the action is called and is assumed to complete.
class Brut::BackEnd::Actions::FormSubmission < Brut::BackEnd::Action

  # Process a form, checking both client- and server-side constraints.
  #
  # @param form [Brut::FrontEnd::Form] the form to process. It should have been populated with the submitted parameters from the
  # browser.
  # @param action [Object] any object that will perform both server-side validations as well as whatever processing is required when
  # the form satisfies its constraints.  See `action_method` for more.
  # @param action_method [Symbol] the method on `action` that will be invoked.  This method must accept a keyword arg of `form:`, and
  # then zero or more additional keyword args.  `rest` passed to `process_form` will be passed to this method as well.  The method
  # must return a `Brut::BackEnd::Actions::CheckResult` if there were any server-side constraint violations. These are issues that the
  # user must fix before the form may be processed.  This method should raise an error *only* for either ephemeral issues that the user
  # has no hope of addressing (such as network timeouts) or programming errors. 
  # Design your method such that it can be retried in this case.  If there were
  # no server-side constraint violations, the method is assumed to have done whatever it is supposed to do. It can return anything
  # that makes sense.
  #
  # @return [Brut::BackEnd::Actions::CheckResult] in all cases.  If there were no constraint violations, anything returned by
  # `action`'s `action_method` method is available via `action_return_value`.  If there are violations, the result will return
  # true for `constraint_violations?` and the form, populated with errors, will be available via `form`.  Note that if there were
  # constraint violations, the action still may have populated the `CheckResult`'s context.
  #
  # @raise [Error] If the `action` raises an error, that will be bubbled up by this method.  This should only happen on ephemeral
  # impossible-to-prevent situations.
  #
  # @example
  #   form = Forms::NewWidget.new(params)
  #   action = Actions::WidgetCreator.new
  #   result = Brut::BackEnd::Actions::FormSubmission.new.process_form(
  #              form: form,
  #              action: action,
  #              action_method: :create_widget,
  #              account: current_logged_in_account)
  #
  #   if result.valid?
  #     page Pages::Success.new(widget: result.action_return_value)
  #   else
  #     page Pages::NewWidget.new(form: result.form)
  #   end
  #
  def process_form(form:, action:, action_method:, **rest)

    action_method = action_method.to_sym

    logger.debug("call(#{form.class},#{action.class},#{action_method},**rest)")
    if form.invalid?
      return form
    end

    returned_value = action.send(action_method,form: form, **rest)
    result = nil

    case returned_value
    in Brut::BackEnd::Actions::CheckResult
      result = returned_value
      if result.constraint_violations?
        result.each_violation do |object,field,key,context|
          if object == form
            context ||= {}
            humanized_field = RichString.new(field).humanized.to_s
            form.server_side_constraint_violation(input_name: field, key: key, context: context.merge(field: humanized_field))
          else
            logger.warn("Ignoring constraint violation on object #{object} (field: #{field}, key: #{key}), because it is not the form")
          end
        end
      end
    else
      result = Brut::BackEnd::Actions::CheckResult.new
      result.action_return_value = returned_value
    end
    result.form = form
    result
  end
end

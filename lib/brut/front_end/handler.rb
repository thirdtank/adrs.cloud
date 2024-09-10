# Handles HTTP requests. Brut will instantiate your handler and call `handle!`.  Your subclass
# must have a no-arg constructor
class Brut::FrontEnd::Handler
  include Brut::FrontEnd::HandlingResults
  # Handle the request and return a result used to generate the response
  #
  # Your subclass must declare, as keyword arguments, the information needed to handle the request.
  # It may only declare keyword arguments.
  #
  # The values are located by Brut when handle! is invoked.  They are located as follows:
  #
  # * anything in the request context
  # * `form:`, the current form, if this is handling a form submission
  # * the name of any request param
  def handle!(**)
    raise SubclassMustImplement
  end
end

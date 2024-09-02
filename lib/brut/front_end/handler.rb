# Handles HTTP requests. Brut will instantiate your handler and call `handle!`.  Your subclass
# must have a no-arg constructor
class Brut::FrontEnd::Handler
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

private

  # For use inside handle! or process! to indicate the user should be redirected to 
  # the route for the given class and query string parameters. If the route
  # does not support GET, an exception is raised
  def redirect_to(klass, **query_string_params)
    Brut.container.routing.for(klass,with_method: :get,**query_string_params)
  end

  # For use when an HTTP status code must be returned.
  def http_status(number) = Brut::FrontEnd::HttpStatus.new(number)


end

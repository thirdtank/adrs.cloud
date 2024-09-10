module Brut::FrontEnd::HandlingResults
  # For use inside handle! or process! to indicate the user should be redirected to 
  # the route for the given class and query string parameters. If the route
  # does not support GET, an exception is raised
  def redirect_to(klass, **query_string_params)
    Brut.container.routing.for(klass,with_method: :get,**query_string_params)
  end

  # For use when an HTTP status code must be returned.
  def http_status(number) = Brut::FrontEnd::HttpStatus.new(number)
end

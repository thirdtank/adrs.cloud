# Design Issues

## CSRF + Session available to page and components

Example problem is wanting to render the CSRF token without having to know where it is or the values required to fetch it.

Current hack is that it's passed into `Page#render`.

This calls into question what is a page object?  Is it a stateless service?  No. It is intended to be a stateful object
representing the specific request for a specific page to render at a specific time.

This is how it's treated, however the responsiobility of calling `new` is on the controller layer. This makes it hard for the
framework to inject information into it.


* Change: have the framework call `new`:

  ```ruby
  # BEFORE
  get "/widgets"
    page Pages::Widgets.new(params)
  end

  # AFTER
  get "/widgets"
    page Pages::Widgets, params
  end

  # OR EVEN
  page Pages::Widgets
  ```

  This way, the session or other stuff can be injected directly when `new` is called

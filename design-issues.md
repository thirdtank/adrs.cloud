# Design Issues

## CSRF + Session available to page and components

Example problem is wanting to render the CSRF token without having to know where it is or the values required to fetch it.

Current hack is that it's passed into `Page#render`.

This calls into question what is a page object?  Is it a stateless service?  No. It is intended to be a stateful object
representing the specific request for a specific page to render at a specific time.

This is how it's treated, however the responsiobility of calling `new` is on the controller layer. This makes it hard for the
framework to inject information into it.

Inject stuff into `render`?

But who calls render?  That context must include env, etc.


## Flash - temp data that can passed via a redirect

Use case is: you want to redirect, but include a message or other info

Somehow: put it in the session, but make sure it's cleared after the page is done rendering?

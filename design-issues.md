# Design Issues

## Framework stuff missing

X Better route definition
* Build out remaining HTML5 validations etc.
* Set up Rack::Attack
* Something with CSP
* Fix chokidar/foreman

## Playwright versions is a PITA

playwright ruby must matc playwright and playwright must be used to install browsers

## Import maps?

* Need a local HTTP/2 web server

## Notification/Instrumentation

Issue is that wrapping a method inside instrument do..end doesn't work if there are any return values.

Options:

* Let it be known?
* allow instrumentation another way?  wrap it somehow in a lambda that does not have this issue?

## Deployment 

* Building the docker image is very slow, likely due to architecture differences

## Logging

* Seems a mess
* Exceptions are getting swallowed/not logged

## Form Validation Complexity

* Chasing down the parts was hard
* A "there were validation issues" was hard
* How to make `<brut-form>` and friends extensible?
* Perhaps each page could have its own custom element?

## Testing Components and Pages

Need better support for html parsing and whatnot

## Rich Test Failures

* What did we expect
* What did we find
* Why did we expect what we did
* What else did we find that's useful

- Formatted for terminal and/or browser

## Logic useful to front-end and back-end - where does it go?

## Converting rich types in DB to and from strings needed for front-end

## Actions have a lot of "is the person logged in allowed to access this"

* This could be put into the "request context" concept, however the request context should really be scoped to the HTTP request.
* "Action" context?
    - bag of whatever
    - not easy to put stuff into it
    - created for any call into the backend: HTTP, task, job
    - expose the "inject stuff via kwargs" pattern





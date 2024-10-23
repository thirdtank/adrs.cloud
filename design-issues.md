# Design Issues

## handle! vs render vs constructor

There is a dissonance between components/pages that get their args via constructor and handlers which do not.


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

## SQL/Data Layer is nowhere near as ergonomic as Active Record

* having to figure out the associations is annoying
* schema stuff is annoying

Ideally:

- Creating a table automatically:
  - sets up a primary key
  - optionally sets up an external id
  - sets created\_at
  - allows / requires commenting
- A "model" should, automatically:
  - have associations on it, based on schema (explicit, but pre-generated)
  - allow rich type conversion to/from column type
- Scheam ergonomics
  - foreign keys super easy/constraints set up etc.
  - fields not nullable by default

* Sequel's migration API is OK
  - need to default to non-null
  - foreign\_key maybe needs default to non-null and default to an index
  - `key` method to indicate that a set of columsn represent a key (and will make a unique index)
  - somehow default to created\_at that gets set automatically
  - bake in external ID support
  - 

## Actions have a lot of "is the person logged in allowed to access this"

* This could be put into the "request context" concept, however the request context should really be scoped to the HTTP request.
* "Action" context?
    - bag of whatever
    - not easy to put stuff into it
    - created for any call into the backend: HTTP, task, job
    - expose the "inject stuff via kwargs" pattern





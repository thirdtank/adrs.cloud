# brut notes

## Database

* Sequel seems OK
* Create doesn't return the created record
* Need to make sure transactions are understood
* Need to make sure multi-threading is handled
* i18n

## Issues

* Views and partials is kinda janky
  - There should be no partials: Page, which is an entire HTML document, and components, which are fragments.

# Forms & Validation

* Use HTML - all fields use HTML5 validations on them for anything that can be provided by the browser.
* Allow Custom Validations - custom validations can be used
* Use CSS - errors are styled with CSS and pseudo-selectors
* In all cases, render the same markup error or not
* For server-side errors, two-prong approach: 1) include metadata to indicate the error and 2) use JavaScript to set custom
validity
* For errors that are general - a few options: 1) don't handle at the `<form>` level?  or 2) some hack?



# Conceptual stuff

* A POST from a browser submits a form
* A form has inputs
* Inputs have constraints
* The browser will validate those constraints
* The server will validate those constraints
* The server may impose additional constraints and reject a submission

Cycle:

```
      Browser                         Server

                                      Define form inputs and constraints
 +->  Render HTML  <----------------- Send HTML
 |    Manage Input
 |    Validate Constraints
 |    Submit to Server    ----------> Re-validate
 |                                    Perform Server-Only Validations
 +----------------------------------- Send HTML w/ Errors
                                      Perform Action
                                      Render Result

```

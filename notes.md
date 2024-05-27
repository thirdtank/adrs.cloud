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


# View Layer

By default, a route maps to a Page.  A Page has a layout.  A Page is the object that is used to dynamically render HTML.  Any
partial HTML is managed by a *component*. The page's template is derived from its name: `Page::Foo::Bar` would expect
`app/pages/foo/bar.page.erb` to exist.

A *Component* is HTML that has no layout.  It is encapsulated from the page. It's template is derived from its name:
`Component::Foo::Bar` would expect that `app/components/foo/bar.component.erb` exist.

A component can render other components

## Conventions

* Components must extend `Brut::BaseComponent`
* Pages must extend `Brut::BasePage`
* Components and Pages can be injected with info before being used

### Notes

* Everything is ultimately an object/class, that's good
* "helpers" is nebulous - I don't want too many, but some are needed
* Error states are unexplored but need to be sorted
* Routes and route helpers are a bit odd - need to consider URL escaping and what not

### Ergonomics

Ideally, you want a line of code in your app to render:

```html
<div> <!-- <--- start of your app's custom component -->
  <input type="..."> <!-- HTML input rendered by Brut -->
</div> <!-- <--- end of your app's custom component -->
```

And there should be some behavior, namely:

* if the field is for a form submission field, the HTML input should match
  appropriately.
* if the field is in error, it should do *something* to indicate there is an error,
  including setting validations on it via HTML5 constraint API

THUS: there must be some known relationship between form submissions, forms/inputs, errors, and wrapping components

Now, because validation can come from the server-side, there must be a relationship with what is returned from an action and the
form submission.  Perhaps:

- Actions return a form submission with errors -> validation error, use the returned object
- Actions return anythning else -> whatever else

# App Next Steps

X Publish a draft
X Clean up the listing page
X Form needs better graphics for arrows
X Allow drafts to omit some data
X Style form errors
* Replace & Refine
* Tags
* Confirm reject or publish

# Framework Next Steps

* Better dates/timezones
* Asset hashing
* Seed data sucks
* Testing?
* Things are verbose - is there a way to simplify w/out turning it into PHP/Rails?
* Using pattern matching is potentially annoying when there is a match error - the exception has no useful info in it.
* Subclass provided web components?
* i18n/messages for error keys
* concept of "general" error?

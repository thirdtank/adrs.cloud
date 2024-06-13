# Brut TODO

## Basic stuff to make it even usable for me

* i18n
* Autoload of App
* CSRF on forms
* Testing
* Sessions / Secure Cookies
* Asset Pipeline
  - hashing of assets
  - rewrite CSS with hashed values?
* Routing
  - idea is to unify routes and pages
* AJAX?
* Logging / observability
  - ideally no string-based logging, but just use
    otel + a local receiver that dumps the stuff as a log

## Stuff for Polish

* Improved CLI/scaffolding
* Improvement to seeds
* How to deploy/run in prod?

## Anti-TODO

Brut will not have:

* Mailers
* Job API
* Storage
* Websockets
* Caching



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
X Replace & Refine
* Tags
X Confirm reject or publish



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
* CSRF

## Overall Architecture

You are building a web app. That means that a browser is fetching information via GET requests, and sending information via POST
requests from a form.  We'll discuss AJAX later, but the basic concept of what you are building is a browser issueing GET and
POST requests.

## GET

A GET request is almost invaraible to render a page.  This page is HTML.  It may be filled with dynamic content. Thus, dynamic
HTML is managed by an HTML template (in ERB) and an instance of a class that represents that page.  The page's class exists
entirely to support the logic and dynamic needed in the template.  The HTML template is executed with the instance of the page as
its context, thus public methods of that page may be called in the template.

## POST

A POST request is a form submission.  A form submission presumably triggers some server-side action, and it's likely that the
triggering of the action depends on the validity of the data in the form, as well as its validity in context of the rest of the
application's data.

To receive a post, you should:

* Define your form as a subclass of `Brut::Form`.  A `Brut::Form`, like an HTML form, has inputs. Each input has constraints
that must be satisfied for the form to be submitted.  `Brut::Form` allows declaring these constraints, and they match what is
available in a web browser.
* Your form subclass can be used to render the HTML. This HTML will use HTML5 constraint validations on the form, preventing its
submission if the constraints are violated.
* When the form is submitted, a `Brut::Action` is configured to recognize the form submission as a trigger to a domain action.
* Before this action is triggered, the form's constraints are re-validated server-side, to account for the ability to circumvent
client-side validations.
* The action's `call` method then called. If it returns a `Brut::Actions::CheckResult`, that indicates that server-side
constraints have been violated.  Otherwise, it indicates the action completed normally.  The resulting object is
action-dependent.

With this context, Brut provides form definition and validation, and will trigger your logic only when constraints have been met.

## Views

As mentioned, the view layer is  based around a web page. A web page is ERB HTML and a class that serves as the context for the
ERB.

HTML fragments are managed with components.  A component is just like a view—it's HTML and a class.  The only difference is that
a Page has a layout, whereas a component does not.  Further, a component is self-contained and does not have access to the view
it is contained within.

### "Helpers"

In Rails, helpers are methods in a global namespace provided by the framework or by you as part of your app.  That said, it's
handy to have access to such methods.  There are several places where they live and can be brought in:

* `Brut::Page` and `Brut::Renderable` provide a few
* Your app will have `AppPage` and `AppComponent` where you can place methods to be available to every page or component.
* Brut provides some useful methods as modules you can include
* Your invidiaul page and component classes can implement the needed methods, or bring in their own.

This may not feel very easy, but it is much simpler as you will be able to clearly understand where methods are coming from and
have control over them.

Of note, Brut is not trying to create an abstraction layer across HTML, so you will not find complex mehtods to generate HTML
form elements.

## Database

Currently, Brut uses Sequel to manage database access.  You are encouraged to create Sequel Models, but to treat them as simple
repositories.  If you want a ton of logic on them, by our guest, but we are not responsible for your mess.

The schema itself is managed outside Sequel using SQL DDL statements.

## Actions

All web apps have a natural "impedence mismatch" between what a browser sends to the server - essentially a bunch of strings -
and what the domain logic needs in order to do its job (usually richer types).  Brut does not provide a way to convert an HTTP
POST into a set of rich objects. This is somewhat complicated to do generally.

That said, Brut will convert POST field values to their types as specified in the form object. For example, if you  have
specified that a field is a number, you will  be given that value as a Numeric, not a string.

Beyond this, the seam between the web/HTTP part and your logic is an `Action` that has two methods: `check` and `call`.  `check`
will determine if `call` should be expected to succeed.  Essentially, `check` would perform any server-side validations, however
these can be as complex as needed based on your use case.

It is assumed that `call` invokes `check`, however `check` may be invoked any number of times on its own.

`check` must return a `Brut::Actions::CheckResult`, which encompasses all the information needed to explain to the user why
`call` should not be invoked.

`call`, however, can return anything.  Because `call` is expected to call `check`, it can return a `Brut::Actions::CheckResult`, indicating the invocation should not have been called and that the user must take action.  `call` can return anything else depending on what it is doing.  You are encouraged to return the direct object that makes the  most sense.  Callers of your action are encouraged to use pattern matching to detect what was returned.

While such a pattern may feel like it goes against OO principles - shouldn't there be only one type of a return value? - it ends
up preventing you from having to create unneeded abstractions *or* to use exceptions for control flow.

Note that the way you implement your action is up to you. You can use the Action concept for any dependent classes, or you can
use other patterns. You do you.

---

Page v Components

Issue is that they are basically the same thing, just one has a layout

what if - top level is component, and page is a refinement of that?

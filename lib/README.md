# brut - Raw Web Development with Objects

Let's be real - a web app has HTML, CSS, JavaScript, forms, inputs, and all that.  Ruby is object-oriented, meaning you make a
class that has a method and that method does something.  What if that's how we made our web app?

Brut (French for "raw") is an attempt to do just that.  It's goal is to reflect back the parts of the web and HTTP used to build
an app in the structure of the code. It aims to be simple, which is not always easy.


## Concepts

Brut has many concepts, but they are all intended to map to the realities of what is being built.

At the top level of any Brut app are:

* actions - these are actions triggered by something. This is where your business logic lives.
* data\_models - these are classes you use to access the database. Currently, brut uses Sequel to do this, but you are not really
intended to put a ton of business logic on the classes in here.  You can, but you're gonna have a bad time if you do.
* view - Classes and templates for the view layer

### Actions

Actions can be anything, however to work wiht form submissions, you need to make an action that conforms to an interface.  This
won't be all your actions.  You can make actions using whatever paradigm you like, though I'd recommend just making classes with
methods, as that is pretty simple to understand and manage.

### Form Submissions

A form submission follows this general workflow:

1. User submits data
1. If data is invalid in some way that the user can fix, the user is told what the problem is
1. If the data is valid and/or the user cannot make the submission any better, business logic is performed
1. The user is told the result (optional)

Because we are building a web app, validation requires two parts: validations that can be performed client-side, and validations
that must be performed server-side.  Because invalid data can still be submitted to our server, the client-side validations are
described in a `FormSubmission` class.

A `FormSubmission` is a simple record-style class, but you create it using the class method `input`, which is how you declare
that the form has an `<INPUT>`.  `input` accepts a name, a type, and options to describe the validations.  It accepts anything
you can do in the browser and nothing you cannot.

You can then use the instance of a form submission to generate `<INPUT>` tags for your HTML that reflect those validations. Cool.

But, you can also use that instance to execute the validations server-side to prevent issues when a user circumvents the browser
constraint-checking.  Of course, you don't have to do this, brut will do it for you.

After client-side validations are checked, your action is located. If your action has an inner class named `ServerSideValidator`,
that is instantiated and executed with the form submission as an argument.  This is where any server side validations can
go.

You can build this however you like, however there is a DataObjectValidator you can use to get Rails-style validations of a
record.

Once your `ServerSideValidator` says things are good, `call` is called on your action. This can do whatever it needs to do.  It
can still return a validation error if there is something highly complex that your `ServerSideValidator` can't check.

What happens in `call` is your business.  You can call other actions, or integrate with any sort of hexagonal domain-driven set
of highly functional curried lambda functions if that's your jam. It's not mine, but you do you.

## Building Views

When the browser does a `GET`, it's expecting a web page. And a web page it will get.  A web page in Brut is dynamic HTML, along
with a supporting class to hold any server-side logic that is needed.  Each page has a `content` attribute that holds the
dynamic content available to that page.  If you want to expose lots of different attributes, you can, but ideally they are able
to be accessed from whatever `content` is.

Pages can be manages by the use of layouts and components.  Each page has a single layout that works like Rails' layouts do.
Layouts are intended to manage your `<HEAD>` section, so dont' go too wild with stuff in there.  But, it's your layout.

Components are exactly like Pages except they have no layout.  A component is a bit of dynamic HTML, coupled to a class where
logic can sit.  Because components have so many uses cases, they don't have a built-in "content" concept.  By default, they don't
do anything but render HTML via ERB. You can pass into them whatever you like.



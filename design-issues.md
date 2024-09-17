# Design Issues

## Testing Components and Pages

Need better support for html parsing and whatnot

## End-to-End Testing

I have Playwright working, but it super sucks in a lot of ways:

* Failing tests provide no context
* locating stuff and asserting is awkward and sucks, especially if using i18n

What is the general philosophy of end2end testing?

* Do stuff in the language/level of the user
  - Pro: many of these tools want to do this
  - Pro: Done well, this can be resistent to small changes in the UI
  - Con: Overall lack of precision in what is actually happening in the test
  - Con: Impedence mismatch between the actual UI and what you are trying to achieve - no matter what, you need
         to locate an element and do stuff to it or assert its state.  Indirection through accessibility roles doesn't
         see helpful
* Manipulate the UI to prodice behavior of the entire integrated system
  - Pro: Direct and explicit - clear link between the actualy HTML and the test
  - Con: Susceptible to breakages when actual functionlity doesn't break if you over-specify locators or assertions

For me, the second option makes the most sense.  It is real: we have a web app whose UI is HTML and we need to manipulate that HTML to
produce behavior that we then test.

As such:

* locators should be CSS selectors.
* two ways of locating:
  - find content that should be there in order to take an action.  If missing, this is an error
  - assert that content is there after an action was taken. If missing, this is a test failure
* error reporting:
  - what were we looking for
  - what was there
  - what was close
    e.g. found the element, content was X and not Y
    e.g. wanted input[type=foo] which wasn't there, but there were other input[type=\*] there

### Rich Test Failures

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


## Actions have a lot of "is the person logged in allowed to access this"

* check vs call concept can help here
* all actions might have three levels of checks:
  - can the current identity have access to the data?
  - does the current entity have entitlements to allow the action?
  - are business logic pre-requisites met in order to allow the action to proceed?

Policy concept is useful, however pundit—popular policy gem—is dsltastic. It also is somewhat simplistic and reductive.

Perhaps:

* actions can use policies internally
* #check uses these policies

```ruby
class Actions::Adrs::Reject < AppAction

  def check(form:, account:)
    result = self.check_result
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      result.policy_violation(:access, adr_id: form.external_id, account_id: account.id)
      return result
    end
    if adr.accepted?
      result.policy_violation(:not_already_accepted, adr_id: form.external_id)
      return result
    end
    check_result.save_context(adr: adr)

  end

  def call(form:, account:)
    result = self.check(form:form,account:account)
    if result.ok?
      adr = result[:adr]
      adr.update(rejected_at: Time.now)
    end
    result
  end
end

get "adrs/edit" do
  result = action.check(form: form, account: account)
  # use result.policy_violations? to taylor UI?
end

post "/adrs/reject" do
  result = action.call(form: form, account: account)
  # three outcomes:
  # - policy violation, in which case this should not have been called
  # - constraint violation, in which case user must be told
  # - all good
  result.policy_violations_not_allowed!

end

```



### Browser Testing

Capybara, Cypress, whatever, and whatever all suck in some ways.  The main way is that they have horrible DSLs for testing that
obscure the underlying web platform.  So, despite the browser having a full API to write a test of an entire web page, these
tools obscure that. Some of the JS ones are unnecessarily async.

Further, some tools like react-testing-library don't use a browser at all, using a fake DOM inside Node that is allegedly faster, however I debate this.

#### Approach for unit tests

Something like what I did for ghola.  Possibly using mocha?

But, the idea would be that the test would work like in ghola, and the results would populate a known element in the browser that
could be inspected to programmatically understand the results.

#### Approach for End-to-End tests

This would be injected into the page and use the browser's API to perform user actions and to access data to make assertions.
There would need to be some info stored in e.g. localstorage so that a test that crossed several pages could be managed.

#### Automation

In theory, an automation would look like:

* Start browser
* Load a page that will run one or more tests
* When the tests are done, inspect a known element for results

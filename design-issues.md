# Design Issues

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

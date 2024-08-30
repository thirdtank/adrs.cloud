# Design Issues

## Routing - mapping routes to logic

* Rails has routes in one file, mapping to a symbol that is interpretted as a class.  I think this kinda sucks
* there is an 80% pattern for gets: render a page with some data
* there is an 80% pattern for posts: process a form, then render errors or render/redirect OK


## Logic useful to front-end and back-end - where does it go?

## Resourceful vs Wild West routing

* The Rails way is overcomplex and not that useful
* Wild west is maybe too loosey-goosey?

## Form handling impedence mismatch: forms vs models

A form is modeled as to its inputs.  But often the underlying model or models are needed.  How should these be looked up? Can they be
done in a structured way?

## Converting rich types in DB to and from strings needed for front-end

## SQL/Data Layer is nowhere near as ergonomic as Active Record

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


## Testing Needs Infra

* Minitest is incredibly rudimentary.  The following things are difficult to do:
  - tag tests/metadata
  - mocking sucks compred to rspec
  - examine test runs and produce structured output
  - there is no "around" concept
* RSpec has all this, but has the following downsides:
  - there is too much stuff to avoid e.g. shared example, shared contexts, wacky matchers etc.
  - ok, that's really it TBH

--> Switch to RSpec


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

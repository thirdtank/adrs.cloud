# One Week Sprint

       1 - something that uses <select>, radio buttons, and checkbox
           - Checkbox to allow public/private sharing?

CHECKK 2 - update the flash w/ AJAX

       3 - Change to Sequel migrations?

CHECK  4 - Address timezone

CHECK  5 - Address i18n

       6 - Need a real name


# 2024-10-01

CHECK 1 - Real E2E tests
          DONE: Major flows tested via conventional e2e tests

      2 - Visual Review
          DONE: List of all parts of the app that need a visual re-think or change

          D Sanity around page headers/navs
          D Make it not look like shit on mobile
          D Home page

          DONE: At least one new feature that requires <select>, radio buttons and checkboxes

          Account Settings:

          D Delete Account
          D See plan + limits

          ADR search

          * basic keyword
          * exact phrase

          Tag auto-complete

     3 -  Update flash on page errors AJAXily


CHECK 3 - Data Layer Review
          DONE: consolidate and normalize looking up data and knowing when it
                will fail vs. return nil/empty
## 2024-09-02

CHECK 1 - Vim Projectionist setup
          DONE: Can use vim :A and friends to switch back and forth

CHECK 2 - i18n Cleanup
          DONE: all strings are i18n'ed
          DONE: i18n.rb is set up in a meaningful way that makes more sense than what is now

CHECK 3 - Limits on accounts
          DONE: An account can be limited to only 5 ADRs (the limit can be changed per-account)
          DONE: limit is not a set of attributes on accounts

CHECK 4 - Admin UI
          DONE: Admin UI to allow new accounts + adjust limits

CHECK 5 - Tests
          DONE: can audit which classes  have no tests


What is this going to be / criteria for launch?

- a nice free thing that's fun - requires limiting accounts
- someting to charge money for - would need user research to see if it's worth doing/what features are missing
- a demonstration of Brut - perhaps.  It likely needs more interactive JavaScript features,
                                      background jobs, and maybe API integration.

## 2024-08-19

CHECK 1 - Basic i18n setup
          DONE: Can show errors via i18n on both client and server

CHECK 2 - Pass validation errors back from ajax submission
          DONE: server-side validations are sent back exactly
                as they are if submitted conventionally

CHECK 3 - Public sharing of ADRs
          DONE: User can mark an accepted ADR as public
                Refined and Replaced ADRs are public by default, but can be made non-public
                ADR can be made non-public after the fact

CHECK 4 - Unit tests of the backend app
          DONE: All app/src classes are tested that should be in the backend

## 2024-08-12

CHECK 1 - Convert to tile/erubi
          DONE: ERB not being used + HTML escaping confirmed

CHECK 2 - Search by tags
          DONE: clicking a tag in any context shows the ADR list by tags

CHECK 3 - Auto-include CSRF on all forms somehow
          DONE: creating a form by default includes CSRF

CHECK 4 - Save draft ajaxily
          DONE: you can click save draft and the draft is saved w/out a page
                reload, but with plenty of obvious UX


## 2024-08-05

CHECK 1 - Get actual auth going with GitHub - timebox but should be good.
          DONE: - can use locally CHECK
                - can use on Heroku when deployed CHECK
CHECK 2 - Make deploys seamless
          DONE: - inside DX, bin/deploy handles deployment to Heroku

CHECK 3 - Integrate CSRF into forms seamlessly
          DONE: All previous functionality works + deployed works

CHECK 4 - Add tags and deploy
          DONE: You can edit tags on any ADR with a minimal UX

CHECK 5 - Test of a Ruby class
          DONE: Can write a test of an Action and run it easily inside DX



# Parking Structure

* When auth'ing but email is not in the DB, what do?
* Deploy is very tied to Heroku
* db CLI is not as helpful as it could be
* startup state is not great
* testing isn't great:
  - database cleaner type thing or run inside transaction
  - minitest is not sophisticated in terms of test metadata et. al.
  - reporting looks jank

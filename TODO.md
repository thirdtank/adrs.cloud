# One Week Sprint

CHECK 1 - Unit tests of the front-end Ruby app
          DONE: All app/src classes are tested that should be in the backend


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

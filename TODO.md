# One Week Sprint

CHECK 1 - Convert to tile/erubi
          DONE: ERB not being used + HTML escaping confirmed

CHECK 2 - Search by tags
          DONE: clicking a tag in any context shows the ADR list by tags

CHECK 3 - Auto-include CSRF on all forms somehow
          DONE: creating a form by default includes CSRF

CHECK 4 - Save draft ajaxily
          DONE: you can click save draft and the draft is saved w/out a page
                reload, but with plenty of obvious UX

      5 - Pass validation errors back from ajax submission
          DONE: server-side validations are sent back exactly
                as they are if submitted conventionally

      6 - Org/Team concept
          Needs some refinement as to what this is

          * Each account/email is part of a team
          * Team is the level of access to ADRs
          * Team has a billing contact
          * Members can have admin access to the team
          * Admin access allows invites and granting/revocation of admin access
          * This must be very lightly designed/flexible

          Framework juice: codify notion of permissions a bit more

      7 - Functioning Sign Up
          DONE: A team can be created



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

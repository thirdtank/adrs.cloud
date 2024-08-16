# Tests

## Create an ADR

1. Create new
2. Click save
   - Client-side validation should say title is required
3. Add a title with a single character
   - Server-side validation should say title is too short
4. Add a longer title with at least two words, add several tags
   - Should save and take you to the edit page, tags should show up

## Edit an ADR

1. Select a draft
2. Remove title and click save
   - Client-side validation should say title is required
3. Replace title with a single character
   - Server-side validation should say title is too short
4. Add a longer title with at least two words, modify tags
   - Should save and take you to back to the edit page

## Reject Draft

1. Select a draft
1. Click Reject ADR
   - should see confirmation
1. Confirm
   - Should see adrs with message that rejection happened

## Accept ADR

1. Select a draft that is missing data
1. Click Accept
   - Should see confirmation
1. Confirm
   - Should see server-side validations indicating more data is needed.
1. Fill in remaining fields, then click Accept
   - Should see confirmation
1. Confirm
   - Should see show page for adr with message it was accepted

## Replace ADR

1. Select an approved ADR
1. Click "Replace"
1. Should see edit screen with indicator that this is being replaced
1. Behavior has "New ADR"
   - should see that the ADR is proposed to replace the originally chosen ADR

## Refine ADR

1. Select an approved ADR
1. Click "Refine"
1. Should see edit screen with indicator that this is being refined
1. Behavior has "New ADR"
   - should see that the ADR is a refinement of the originally chosen ADR

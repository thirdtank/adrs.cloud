ALTER TABLE
  adrs
ADD COLUMN
  rejected_at timestamp with time zone null;

ALTER TABLE
  adrs
ADD CONSTRAINT
  adrs_cannot_be_accepted_and_rejected
CHECK (
  ( (accepted_at IS NOT NULL) AND (rejected_at IS     NULL) ) OR
  ( (accepted_at IS     NULL) AND (rejected_at IS NOT NULL) ) OR
  ( (accepted_at IS     NULL) AND (rejected_at IS     NULL) )
);

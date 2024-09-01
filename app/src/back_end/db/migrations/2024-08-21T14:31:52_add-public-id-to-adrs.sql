ALTER TABLE
  adrs
ADD COLUMN
  shareable_id TEXT NULL
;

CREATE UNIQUE INDEX
  adrs_shareable_id_must_be_unique
ON
  adrs(shareable_id)
;

COMMENT ON COLUMN adrs.shareable_id IS
  'If non-null, this ADR can be accessed by anyone this identifier';

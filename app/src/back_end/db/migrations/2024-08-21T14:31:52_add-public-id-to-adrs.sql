ALTER TABLE
  adrs
ADD COLUMN
  public_id TEXT NULL
;

CREATE UNIQUE INDEX
  adrs_public_id_must_be_unique
ON
  adrs(public_id)
;

COMMENT ON COLUMN adrs.public_id IS
  'If non-null, this ADR can be accessed publicaly via this identifier';

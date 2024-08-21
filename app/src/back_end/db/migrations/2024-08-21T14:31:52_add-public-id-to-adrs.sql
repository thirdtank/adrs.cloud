ALTER TABLE
  adrs
ADD COLUMN
  public_id TEXT NULL
;

COMMENT ON COLUMN adrs.public_id IS
  'If non-null, this ADR can be accessed publicaly via this identifier';

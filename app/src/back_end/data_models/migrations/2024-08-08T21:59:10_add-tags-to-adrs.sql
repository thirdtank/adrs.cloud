ALTER TABLE
  adrs
ADD COLUMN
  tags TEXT[] NOT NULL DEFAULT '{}'
;

COMMENT ON COLUMN adrs.tags IS
 'Zero or more tags to be used for arbitrary organization of ADRs';


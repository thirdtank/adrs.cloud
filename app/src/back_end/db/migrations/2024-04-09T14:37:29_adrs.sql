CREATE TABLE adrs (
  id BIGSERIAL PRIMARY KEY,
  external_id citext NOT NULL UNIQUE,
  title text NOT NULL,
  context text NULL,
  facing text NULL,
  decision text NULL,
  neglected text NULL,
  achieve text NULL,
  accepting text NULL,
  because text NULL,
  accepted_at timestamp with time zone NULL,
  created_at timestamp with time zone NOT NULL,
  account_id BIGINT NOT NULL REFERENCES accounts(id)
);

COMMENT ON TABLE adrs IS
  'Architecture Decision Records';

CREATE TRIGGER
  adrs_external_id
BEFORE INSERT ON
  adrs
FOR EACH ROW
EXECUTE PROCEDURE generate_external_id('adr');

CREATE INDEX adrs_accounts ON adrs(account_id);

ALTER TABLE adrs ADD CONSTRAINT
  accepted_adr_requires_fields
CHECK (
  (accepted_at IS NULL) OR
  (
    accepted_at IS NOT NULL AND
    context      IS NOT NULL AND
    facing       IS NOT NULL AND
    decision     IS NOT NULL AND
    neglected    IS NOT NULL AND
    achieve      IS NOT NULL AND
    accepting    IS NOT NULL AND
    because      IS NOT NULL
  )
);

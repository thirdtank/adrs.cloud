CREATE TABLE adrs (
  id BIGSERIAL PRIMARY KEY,
  external_id citext NOT NULL UNIQUE,
  title text NOT NULL,
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

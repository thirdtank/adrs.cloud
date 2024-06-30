-- Put your SQL here

CREATE EXTENSION IF NOT EXISTS citext;
CREATE DOMAIN email_address AS citext
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );

CREATE FUNCTION generate_external_id()
RETURNS trigger AS $$
BEGIN
  NEW.external_id := 'ad' || TG_ARGV[0] || '_' || md5(random()::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql
;

COMMENT ON FUNCTION generate_external_id IS
  'Generates an externalizable identifier that is a key, but not part of referential integrity. This key can be shared externally without revealing info AND can be rotated if need be';

CREATE TABLE
  accounts
(
  id BIGSERIAL PRIMARY KEY,
  external_id CITEXT NOT NULL UNIQUE,
  email email_address NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

COMMENT ON TABLE accounts IS
  'Stores individual user accounts, used for authentication';

CREATE TRIGGER
  accounts_external_id
BEFORE INSERT ON
  accounts
FOR EACH ROW
EXECUTE PROCEDURE generate_external_id('ac');

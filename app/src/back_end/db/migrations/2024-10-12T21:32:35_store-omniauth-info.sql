CREATE TABLE
  external_accounts
(
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  provider CITEXT NOT NULL,
  external_account_id TEXT NOT NULL,
  account_id INT REFERENCES accounts(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

COMMENT ON TABLE external_accounts IS
  'data from external accounts used to authenticate the related account'
;

CREATE INDEX external_accounts_account ON external_accounts(account_id);
CREATE UNIQUE INDEX external_accounts_provider ON external_accounts(account_id,provider);

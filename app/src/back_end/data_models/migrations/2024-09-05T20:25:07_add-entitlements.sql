CREATE TABLE entitlement_defaults (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_id citext NOT NULL UNIQUE,
  internal_name text NOT NULL,
  max_non_rejected_adrs integer NOT NULL,
  created_at timestamp with time zone NOT NULL
);

COMMENT ON TABLE entitlement_defaults IS
  'Each row represents a collection of default values of entitles, for example, a "plan" for new users. It serves as default values that can be changed for everyone, e.g. make the plus plan allow 200 ADRs, however account-by-account values can be overridden by the entitlements table';

CREATE UNIQUE INDEX ON entitlement_defaults(internal_name);

CREATE TABLE entitlements (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  entitlement_default_id BIGINT NOT NULL REFERENCES entitlement_defaults(id),
  max_non_rejected_adrs integer NULL,
  account_id BIGINT NOT NULL UNIQUE REFERENCES accounts(id),
  created_at timestamp with time zone NOT NULL
);

COMMENT ON TABLE entitlements IS
  'Per-account entitlements that are intended to override the entitlement default. This allows an account to be on a specific plan, but have some entitlements changed';

CREATE INDEX entitlements_entitlement_default_id ON entitlements(entitlement_default_id);

ALTER TABLE
  accounts
ADD COLUMN
  deactivated_at TIMESTAMP WITH TIME ZONE NULL;

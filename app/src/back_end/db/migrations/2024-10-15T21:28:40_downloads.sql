CREATE TABLE
  downloads
(
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_id            CITEXT                   NOT NULL UNIQUE,
  account_id             INT                      NOT NULL REFERENCES accounts(id),
  all_data               TEXT                         NULL,
  data_ready_at          TIMESTAMP WITH TIME ZONE     NULL,
  delete_at              TIMESTAMP WITH TIME ZONE     NULL,
  created_at             TIMESTAMP WITH TIME ZONE NOT NULL
)
;

COMMENT ON TABLE downloads IS
  'Stores data to download when an account has made such a request';

CREATE UNIQUE INDEX downloads_account ON downloads(account_id);

ALTER TABLE
  downloads
ADD CONSTRAINT
  download_ready
CHECK (
  (all_data IS     NULL AND data_ready_at IS     NULL AND delete_at IS     NULL) OR
  (all_data IS NOT NULL AND data_ready_at IS NOT NULL AND delete_at IS NOT NULL)
);

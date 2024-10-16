CREATE TABLE
  projects
(
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_id            CITEXT                   NOT NULL UNIQUE,
  name                   TEXT                     NOT NULL,
  description            TEXT                         NULL,
  adrs_shared_by_default BOOLEAN                  NOT NULL,
  account_id             INT                      NOT NULL REFERENCES accounts(id),
  created_at             TIMESTAMP WITH TIME ZONE NOT NULL,
  archived_at            TIMESTAMP WITH TIME ZONE     NULL
);

COMMENT ON TABLE projects IS
  'A way to group ADRs to avoid confusion or excessive tagging';

CREATE INDEX projects_account ON projects(account_id);
CREATE UNIQUE INDEX project_names ON projects(account_id,name);

ALTER TABLE
  adrs
ADD COLUMN
  project_id INT REFERENCES projects(id) NULL; -- to be not-null

ALTER TABLE
  entitlement_defaults
ADD COLUMN
  max_projects INTEGER NOT NULL default 10
;

ALTER TABLE
  entitlements
ADD COLUMN
  max_projects INTEGER NULL
;

CREATE TABLE
  projects
(
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_id CITEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT NULL,
  account_id INT REFERENCES accounts(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

COMMENT ON TABLE projects IS
  'A way to group ADRs to avoid confusion or excessive tagging';

CREATE INDEX projects_account ON projects(account_id);
CREATE UNIQUE INDEX project_names ON projects(account_id,name);

ALTER TABLE
  adrs
ADD COLUMN
  project_id INT REFERENCES projects(id) NULL; -- to be not-null

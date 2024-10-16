-- Put your SQL here

CREATE EXTENSION IF NOT EXISTS citext;
CREATE DOMAIN email_address AS citext
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );

CREATE TABLE
  accounts
(
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  external_id CITEXT NOT NULL UNIQUE,
  email email_address NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

COMMENT ON TABLE accounts IS
  'Stores individual user accounts, used for authentication';

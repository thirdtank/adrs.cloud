--
-- ADR Replacement and Refinement
--
-- Replacement:
--   - conceptually this is how you decide an ADR no longer applies.  HOW it no longer applies
--     would be dealt with in the replacing ADR
--   - Since there may be more than one proposal for how to replace an ADR, multiple ADRs can
--     be drafted, although only one can be accepted as the replacement.
--   - During the drafting, proposed_adr_replacements records are created to map new ADRs
--     to the old one.
--   - Once a singel ADR has been accepted as the replacement, the replaced ADR's replaced_by_adr_id is 
--     set.
--
-- Refinment:
--   - conceptually, this is how you can clarify or slightly change one ADR.  This is much more
--     free form than replacment.  Any number of ADRs can refine an existing, accepted ADR.
--
CREATE TABLE proposed_adr_replacements (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  replaced_adr_id bigint NOT NULL references adrs(id),
  replacing_adr_id bigint NOT NULL references adrs(id),
  created_at timestamp with time zone NOT NULL
);

ALTER TABLE
  proposed_adr_replacements
ADD CONSTRAINT
  adr_cannot_replace_itself
CHECK (
  replaced_adr_id <> replacing_adr_id
);

CREATE UNIQUE INDEX ON proposed_adr_replacements(replaced_adr_id,replacing_adr_id);

COMMENT ON TABLE proposed_adr_replacements IS
  'Stores a proposal to replace one ADR with another.  This is needed to remember ths information while the replacing ADR is being drafted';

ALTER TABLE
  adrs
ADD COLUMN
  replaced_by_adr_id bigint NULL references adrs(id);

COMMENT ON COLUMN adrs.replaced_by_adr_id IS
  'ADR that replaces this one. Used when an accepted ADR no longer should be followed';

CREATE UNIQUE INDEX adrs_replaced_by ON adrs(replaced_by_adr_id);

COMMENT ON INDEX adrs_replaced_by IS
  'An ADR cannot replace more than one ADR';

ALTER TABLE
  adrs
ADD COLUMN
  refines_adr_id bigint NULL references adrs(id);
CREATE INDEX adr_refines ON adrs(refines_adr_id);

COMMENT ON COLUMN adrs.refines_adr_id IS
  'This ADR is a refinement of another accepted ADR.  Many ADRs can refine other ADRs';

ALTER TABLE
  adrs
ADD CONSTRAINT
  replaced_requires_accepted
CHECK (
  (
    ( replaced_by_adr_id IS NULL ) OR
    (
      ( replaced_by_adr_id IS NOT NULL ) AND ( accepted_at IS NOT NULL )
    )
  )
);
COMMENT ON CONSTRAINT replaced_requires_accepted ON adrs IS
  'An ADR cannot be replaced if it has not been accepted';

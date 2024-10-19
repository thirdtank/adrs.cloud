# 
#  ADR Replacement and Refinement
# 
#  Replacement:
#    - conceptually this is how you decide an ADR no longer applies.  HOW it no longer applies
#      would be dealt with in the replacing ADR
#    - Since there may be more than one proposal for how to replace an ADR, multiple ADRs can
#      be drafted, although only one can be accepted as the replacement.
#    - During the drafting, proposed_adr_replacements records are created to map new ADRs
#      to the old one.
#    - Once a singel ADR has been accepted as the replacement, the replaced ADR's replaced_by_adr_id is 
#      set.
# 
#  Refinment:
#    - conceptually, this is how you can clarify or slightly change one ADR.  This is much more
#      free form than replacment.  Any number of ADRs can refine an existing, accepted ADR.
# 
Sequel.migration do
  up do
    create_table :proposed_adr_replacements do
      primary_key :id
      foreign_key :replaced_adr_id, :adrs, null: false, index: true
      foreign_key :replacing_adr_id, :adrs, null: false, index: true
      column :created_at, :timestamptz, null: false
      constraint(:adr_cannot_replace_itself, Sequel.lit(
      %{
      replaced_adr_id <> replacing_adr_id
      }))
      index [ :replaced_adr_id, :replaced_adr_id ], unique: true
    end
    run %{
      COMMENT ON TABLE proposed_adr_replacements IS
        'Stores a proposal to replace one ADR with another.  This is needed to remember ths information while the replacing ADR is being drafted'
    }
    alter_table :adrs do
      add_foreign_key :replaced_by_adr_id, :adrs, index: { unique: true }
      add_foreign_key :refines_adr_id, :adrs, index: true
      add_constraint(:replaced_requires_accepted,Sequel.lit(
        %{
            ( replaced_by_adr_id IS NULL ) OR
            (
              ( replaced_by_adr_id IS NOT NULL ) AND ( accepted_at IS NOT NULL )
            )

        }))
    end
  end
end

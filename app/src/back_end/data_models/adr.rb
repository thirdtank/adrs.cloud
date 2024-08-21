class DataModel::Adr < AppDataModel
  many_to_one :account

  # This is the ADR this model is replacing
  one_through_one :proposed_to_replace_adr, class: "DataModel::Adr",
    join_table: :proposed_adr_replacements,
    left_key: :replacing_adr_id,
    right_key: :replaced_adr_id

  # Note, it's really one-to-one based on the DB
  # constraints, but this is how Sequel wants to model this
  many_to_one :replaced_by_adr, class: "DataModel::Adr"
  one_to_one :replaced_adr, class: "DataModel::Adr", key: :replaced_by_adr_id

  one_to_many :refined_by_adrs, class: "DataModel::Adr", key: :refines_adr_id

  def self.create(...)
    super(...)
    id = self.db["select currval('adrs_id_seq')"]
    self[id: id]
  end

  def tags
    tags_value = self[:tags] || []

    if self.public?
      tags_value + [ self.phony_tag_for_public ]
    else
      tags_value
    end
  end

  def tags=(tags)
    self[:tags] = tags.delete_if { |element| element.to_s.downcase == self.phony_tag_for_public }
  end

  def public?   = !self.public_id.nil?
  def accepted? = !self.accepted_at.nil?
  def rejected? = !self.rejected_at.nil?
  def replaced? = !self.replaced_by_adr.nil?

  def refines_adr = self.class[id: self.refines_adr_id]
  def refines? = !self.refines_adr.nil?

private

  def phony_tag_for_public = "public".freeze
end

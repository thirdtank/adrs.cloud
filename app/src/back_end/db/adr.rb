class DB::Adr < AppDataModel
  has_external_id :adr
  many_to_one :account

  # This is the ADR this model is replacing
  one_through_one :proposed_to_replace_adr, class: "DB::Adr",
    join_table: :proposed_adr_replacements,
    left_key: :replacing_adr_id,
    right_key: :replaced_adr_id

  # Note, it's really one-to-one based on the DB
  # constraints, but this is how Sequel wants to model this
  many_to_one :replaced_by_adr, class: "DB::Adr"
  one_to_one :replaced_adr, class: "DB::Adr", key: :replaced_by_adr_id

  one_to_many :refined_by_adrs, class: "DB::Adr", key: :refines_adr_id

  def tags(phony_shared: true)
    tags_value = self[:tags] || []

    if self.shared? && phony_shared
      tags_value + [ self.class.phony_tag_for_shared ]
    else
      tags_value
    end
  end

  def tags=(tags)
    self[:tags] = tags.delete_if { |element| element.to_s.downcase == self.class.phony_tag_for_shared }
  end

  def shared?     = !self.shareable_id.nil?
  def accepted?   = !self.accepted_at.nil?
  def rejected?   = !self.rejected_at.nil?
  def replaced?   = !self.replaced_by_adr.nil?
  def replaced_at =  self.replaced_by_adr&.created_at
  def refines_adr =  self.class[id: self.refines_adr_id]
  def refines?    = !self.refines_adr.nil?

  def self.phony_tag_for_shared = "shared".freeze

end

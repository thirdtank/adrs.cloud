class AccountAdrs
  def self.search(account:, tag: nil)
    adrs = if tag.nil?
             account.adrs
           else
             tag = tag.downcase
             if (tag == DB::Adr.phony_tag_for_shared)
               account.adrs_dataset.where(Sequel.lit("shareable_id IS NOT NULL")).to_a
             else
               account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag]))).to_a
             end
           end
    self.new(adrs:)
  end

  def self.num_non_rejected(account:)
    account.adrs_dataset.where(rejected_at: nil).count
  end

  attr_reader :adrs
  def initialize(adrs:)
    @adrs = adrs
  end
  def size = adrs.size
end

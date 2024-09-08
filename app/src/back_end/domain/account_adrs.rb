class AccountAdrs
  def self.find_all(account:, tag: nil)
    adrs = if tag.nil?
             account.adrs
           else
             tag = tag.downcase
             if (tag == DataModel::Adr.phony_tag_for_shared)
               account.adrs_dataset.where(Sequel.lit("shareable_id IS NOT NULL")).to_a
             else
               account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag]))).to_a
             end
           end
    self.new(adrs:)
  end

  attr_reader :adrs
  def initialize(adrs:)
    @adrs = adrs
  end
end

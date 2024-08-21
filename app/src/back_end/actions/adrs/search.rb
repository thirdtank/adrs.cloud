class Actions::Adrs::Search
  def by_tag(tag:, account:)
    tag = tag.downcase
    if (tag == DataModel::Adr.phony_tag_for_public)
      account.adrs_dataset.where(Sequel.lit("public_id IS NOT NULL")).to_a
    else
      account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag]))).to_a
    end
  end
end

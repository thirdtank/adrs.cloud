class Actions::Adrs::Search < AppAction
  def by_tag(tag:, account:)
    tag = tag.downcase
    if (tag == DataModel::Adr.phony_tag_for_shared)
      account.adrs_dataset.where(Sequel.lit("shareable_id IS NOT NULL")).to_a
    else
      account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag]))).to_a
    end
  end
end

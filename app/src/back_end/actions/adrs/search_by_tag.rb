class Actions::Adrs::SearchByTag < AppAction
  def call(tag:, account:)
    account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag]))).to_a
  end
end

module Admin
  class AccountSearchForm < AppForm
    input :search_string, required: true

    def new_record? = true
  end
end

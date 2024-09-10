module Admin
  class NewAccountForm < AppForm
    input :github_username, required: true

    def new_record? = true
  end
end

module Admin
  class NewAccountForm < AppForm
    input :email, required: true

    def new_record? = true
  end
end

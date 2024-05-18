class Forms::SignUp < AppForm
  input :email
  input :password, minlength: 8
  input :password_confirmation, type: "password"
end


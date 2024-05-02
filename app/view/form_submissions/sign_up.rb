class FormSubmissions::SignUp < AppFormSubmission
  input :email, :email
  input :password, { minlength: 8 }
  input :password_confirmation, { minlength: 8 }
end

class AppSession < Brut::FrontEnd::Session
  def login!(id)
    self[:logged_in_account_id] = id
  end
  def logout!
    self.delete(:logged_in_account_id)
  end

  def logged_in? = !self[:logged_in_account_id].nil?
  def logged_in_account_id = self[:logged_in_account_id]
end

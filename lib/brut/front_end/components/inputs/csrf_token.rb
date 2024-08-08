class Brut::FrontEnd::Components::Inputs::CsrfToken < Brut::FrontEnd::Components::Input
  def render(csrf_token:)
    "<input type='hidden' name='authenticity_token' value='#{csrf_token}'>"
  end
end

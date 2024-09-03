class EndToEndTestsPage < AppPage
  def render
    if Brut.container.project_env.test?
      super
    else
      Brut::FrontEnd::HttpStatus.new(404)
    end
  end
end

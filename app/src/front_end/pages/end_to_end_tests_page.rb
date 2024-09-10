class EndToEndTestsPage < AppPage
  def before_render
    if !Brut.container.project_env.test?
      http_status(404)
    end
  end
end

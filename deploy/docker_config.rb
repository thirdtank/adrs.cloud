class DockerConfig

  def platform = nil
  def additional_images
    {
      "sidekiq" => {
        cmd: "bin/run sidekiq",
      },
    }
  end
end


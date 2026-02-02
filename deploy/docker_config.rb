class DockerConfig

  # Return a Hash oif additional images to run, beyond "web" and "release".
  #
  # The format of this Hash is:
  #
  # {
  #   "«image name» => {
  #     cmd: "«command line for Dockerfile RUN directive»",
  #   }
  # }
  #
  # For example, if you have the Sidekiq segment installed, `bin/run-sidekiq`
  # runs Sidekiq, so you would return this hash:
  #
  # {
  #   "sidekiq" => {
  #     cmd: "bin/run-sidekiq",
  #   }
  # }
  def additional_images
    {
      "sidekiq" => {
        cmd: "bin/run sidekiq",
      },
    }
  end
end


class Brut::TemplateLocator
  def initialize(path:, extension:)
    @path = Pathname(path)
    @extension = extension
  end

  def locate(base_name)
    @path / "#{base_name}.#{@extension}"
  end
end


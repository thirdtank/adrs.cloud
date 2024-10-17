AppDataModel = Class.new(Sequel::Model)
class AppDataModel
  def to_json(...)
    self.as_json.to_json(...)
  end
end

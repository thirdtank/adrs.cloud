class Tags
  def self.from_string(string:)
    tags = string.to_s.split(/\n/).
      map { |line| line.split(/,/) }.
      flatten.
      map(&:strip).
      reject { |tag| tag == "" }.
      map(&:downcase).
      uniq
    self.new(tags:)
  end

  def self.from_array(array:)
    self.new(tags: array)
  end

  def initialize(tags:)
    @tags = tags
  end

  def to_s = @tags.join(", ")
  def to_a = @tags
end

require "digest"

class Components::Adrs::Tag < AppComponent
  COLORS = [
    "red",
    "orange",
    "green",
    "blue",
    "purple",
    # yellow omitted as it doesn't look good
  ]
  attr_reader :tag, :color
  def initialize(tag:)
    @tag = tag
    index = Digest::MD5.hexdigest(@tag)[0..6].to_i(16) % COLORS.length
    @color = COLORS[index]
  end

end


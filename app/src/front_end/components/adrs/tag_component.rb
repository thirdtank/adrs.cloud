require "digest"

class Adrs::TagComponent < AppComponent
  COLORS = [
    "orange",
    "red",
    "green",
    "blue",
    "purple",
    "gray",
    # yellow omitted as it doesn't look good
  ]
  attr_reader :tag, :color, :weight, :icon, :border_weight
  def initialize(tag:)
    @tag = tag
    index = Digest::MD5.hexdigest(@tag)[0..12].to_i(16) % COLORS.length
    @color = COLORS[index]
    if tag.downcase == DataModel::Adr.phony_tag_for_shared
      @weight = "5"
      @icon = "globe-network-icon"
      @border_weight = 600
    else
      @weight = "normal"
      @icon = false
      @border_weight = 700
    end
  end

  def routing = Brut.container.routing

end


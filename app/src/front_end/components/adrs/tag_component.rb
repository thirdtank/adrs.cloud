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
  attr_reader :tag, :color, :weight, :icon, :border_weight, :padding, :background_weight
  def initialize(tag:, link: true, compact: false)
    @tag  =   tag
    @link = !!link

    index = Digest::MD5.hexdigest(@tag)[0..12].to_i(16) % COLORS.length
    @color = COLORS[index]
    @background_weight = 800
    if tag.downcase == DB::Adr.phony_tag_for_shared
      @weight = "5"
      @icon = "globe-network-icon"
      @border_weight = 600
    else
      @weight = "normal"
      @icon = false
      @border_weight = 700
    end
    if compact
      @padding = "pl-1 pr-2 pv-0"
      @border_weight = @border_weight + 100
      @background_weight = 900
    else
      @padding = "ph-2 pv-1"
    end
  end


  def link? = @link
end


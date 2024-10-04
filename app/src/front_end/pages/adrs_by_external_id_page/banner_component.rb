class AdrsByExternalIdPage::BannerComponent < AppComponent
  attr_reader :color, :background_color, :font_weight, :font_size, :padding

  def initialize(background_color:,
                 color:,
                 font_size: "",
                 font_weight: "fw-5",
                 glow: false,
                 i18n_key: :use_block,
                 timestamp: :use_block)

    if (timestamp == :use_block && i18n_key != :use_block) ||
       (timestamp != :use_block && i18n_key == :use_block)
      raise ArgumentError,"timestamp and i18n_key must both be omitted or both be present"
    end
    @background_color =   background_color
    @color            =   color
    @font_size        =   font_size
    @font_weight      =   font_weight
    @glow             = !!glow
    @i18n_key         =   i18n_key
    @timestamp        =   timestamp

    @timestamp_font_weight = if font_weight =~ /^fw-(\d)$/
                               lower_weight = [$1.to_i + 1,9].min
                               "fw-#{lower_weight}"
                             else
                               "fw-6"
                             end
    @padding = if font_size == "f-1"
                 "ph-3 pv-2"
               else
                 "pa-3"
               end
  end
  def glow? = @glow

  def contents
    if @timestamp == :use_block
      render_yielded_block
    else
      t_html(@i18n_key) do
        timestamp(@timestamp,class: @timestamp_font_weight, format: :date)
      end
    end
  end
end

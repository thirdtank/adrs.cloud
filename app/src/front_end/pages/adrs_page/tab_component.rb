class AdrsPage::TabComponent < AppComponent
  attr_reader :css_class
  def initialize(tabs:,selected_tab:, css_class: "")
    @tabs         = tabs
    @selected_tab = selected_tab.to_sym
    @css_class    = css_class
  end

  def each_tab(&block)
    @tabs.each do |tab,svg|
      tab = tab.to_sym
      block.(tab,tab == @selected_tab,svg)
    end
  end
end

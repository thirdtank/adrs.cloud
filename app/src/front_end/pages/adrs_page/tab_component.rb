class AdrsPage::TabComponent < AppComponent2
  attr_reader :css_class
  def initialize(tabs:,selected_tab:, css_class: "")
    @tabs         = tabs
    @selected_tab = selected_tab.to_sym
    @css_class    = css_class
  end

  def page_name = "AdrsPage"

  def each_tab(&block)
    @tabs.each do |tab,svg|
      tab = tab.to_sym
      block.(tab,tab == @selected_tab,svg)
    end
  end

  def view_template
    brut_tabs(
      role:"tablist",
      aria_orientation:"vertical",
      class: css_class,
      show_warnings:true,
      tab_selection_pushes_and_restores_state: true
    ) do
      each_tab do |tab_name,selected,svg_name|
        a(
          href: "?tab=#{ tab_name }",
          role: "tab",
          aria_selected: selected.to_s,
          tabindex: selected ? 0 : -1,
          aria_controls: "#{ tab_name }-panel",
          id: "#{ tab_name}-tab"
        ) do
          span(class: "flex items-center justify-end gap-2") do
            span { t(page: [ "tabs", tab_name ]).to_s }
            if svg_name
              span(class:"w-2") { inline_svg(svg_name) }
            end
          end
        end
      end
    end
  end
end

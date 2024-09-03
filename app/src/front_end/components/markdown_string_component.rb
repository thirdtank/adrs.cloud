class MarkdownStringComponent < AppComponent
  class Markdown < Redcarpet::Render::HTML
    def header(text,header_level)
      super.header(text,header_level.to_i + 3)
    end
  end
  def initialize(string)
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html: true,
        no_images: true,
        no_styles: true,
        safe_links_only: true,
        link_attributes: { class: "blue-400" },
      ),
      fenced_code_blocks: true,
      autolink: true,
      quote: true,
    )
    @html = Brut::FrontEnd::Templates::HTMLSafeString.from_string(markdown.render(string))
  end

  def render
    @html
  end
end

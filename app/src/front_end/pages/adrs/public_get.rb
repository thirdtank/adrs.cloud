class Pages::Adrs::PublicGet < AppPage
  class Markdown < Redcarpet::Render::HTML
    def header(text,header_level)
      super.header(text,header_level.to_i + 3)
    end
  end

  attr_reader :adr, :account

  def initialize(adr:, account:)
    @adr = adr
    @account = account
    @markdown = Redcarpet::Markdown.new(
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
  end

  def markdown(field)
    value = "**#{field_text(field)}** #{adr.send(field)}"
    Brut::FrontEnd::Templates::HTMLSafeString.from_string(@markdown.render(value))
  end

  def public_refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?).select(&:public?)
  end

private

  def field_text(field)
    case field
    when :context   then "In the context of"
    when :facing    then "Facing"
    when :decision  then "We decided"
    when :neglected then "Neglecting"
    when :achieve   then "To achieve"
    when :accepting then "Accepting"
    when :because   then "Because"
    else raise ArgumentError.new("No such field '#{field}'")
    end
  end
end


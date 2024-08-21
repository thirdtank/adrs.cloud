class Pages::Adrs::Get < AppPage
  class Markdown < Redcarpet::Render::HTML
    def header(text,header_level)
      super.header(text,header_level.to_i + 3)
    end
  end

  attr_reader :adr, :info_message

  def initialize(adr:, info_message: nil)
    @adr = adr
    @info_message = info_message
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

  def refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?)
  end

  def editable? = !adr.accepted? && !adr.rejected?
  def draft? = self.editable?

  def accepted_and_in_effect? = adr.accepted? && !adr.replaced?

  def private? = !self.public?
  def public?  =  adr.public?
  def public_path
    if !public?
      raise "This method should not have been called as the ADR is not public"
    end
    "/public_adrs/#{adr.public_id}"
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


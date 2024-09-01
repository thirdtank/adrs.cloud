class AdrsPage < AppPage

  attr_reader :info_message, :tag

  def initialize(account:, flash:, tag: nil)
    puts "page constructor: #{flash.inspect}"
    @info_message = flash[:notice]
    @tag          = tag
    @adrs         = if @tag.nil?
                      account.adrs
                    else
                      Actions::Adrs::Search.new.by_tag(account: account, tag: @tag)
                    end
  end
  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @adrs.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @adrs.select(&:rejected?).sort_by(&:rejected_at)

  def tag? = !!@tag

  def routing = Brut.container.routing

end

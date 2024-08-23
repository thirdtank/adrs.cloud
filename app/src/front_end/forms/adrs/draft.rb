class Forms::Adrs::Draft < AppForm
  input :title, minlength: 4
  input :context, required: false
  input :facing, required: false
  input :decision, required: false
  input :neglected, required: false
  input :achieve, required: false
  input :accepting, required: false
  input :because, required: false
  input :tags, required: false
  input :external_id, required: false
  input :refines_adr_external_id, required: false
  input :replaced_adr_external_id, required: false

  def params_empty?(params)
    params.nil? || params.except(:refines_adr_external_id,:replaced_adr_external_id).empty?
  end

  def self.from_adr(adr)
    tag_serializer = Actions::Adrs::TagSerializer.new
    self.new(
      external_id: adr.external_id,
      title: adr.title,
      context: adr.context,
      facing: adr.facing,
      decision: adr.decision,
      neglected: adr.neglected,
      achieve: adr.achieve,
      accepting: adr.accepting,
      because: adr.because,
      tags: tag_serializer.from_array(adr.tags),
      refines_adr_external_id: adr.refines_adr&.external_id,
    )
  end
end


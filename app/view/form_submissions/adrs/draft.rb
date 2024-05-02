class FormSubmissions::Adrs::Draft < AppFormSubmission
  input :title
  input :context, required: false
  input :facing, required: false
  input :decision, required: false
  input :neglected, required: false
  input :achieve, required: false
  input :accepting, required: false
  input :because, required: false
  input :external_id, { required: false }

  def self.from_adr(adr)
    self.new(
      external_id: adr.external_id,
      title: adr.title,
      context: adr.context,
      facing: adr.facing,
      decision: adr.decision,
      neglected: adr.neglected,
      achieve: adr.achieve,
      accepting: adr.accepting,
      because: adr.because
    )
  end
end


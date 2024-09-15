class AdrTagsWithExternalIdForm < AppForm
  # XXX remove
  input :external_id, required: true
  input :tags, required: false
end


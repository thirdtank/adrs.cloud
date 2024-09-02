class AdrTagsWithExternalIdForm < AppForm
  input :external_id, required: true
  input :tags, required: false
end


# This is for app-specific stuff. It can override anything in 1_defaults if needed
{
  # en: must be the first entry, thus indicating this is the EN translations
  en: {
    cv: { # short for "constraint violations" to avoid having to type that out
      be: { # short for "back-end", again not to have to type it out
        # These are snake case, which is idiomatic for Ruby.  The values
        # here are all based on DataObjectValidator's behavior
        not_enough_words: "%{field} must have at least %{minwords} words",
      },
    },
  },
}

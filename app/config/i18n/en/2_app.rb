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
    actions: {
      auth: {
        logged_out: "You have been logged out",
        no_account: "There is no account with the credentials you provided",
      },
      adrs: {
        created: "ADR Created",
        updated: "ADR Updated",
        rejected: "ADR Rejected",
        accepted: "ADR Accepted",
        tags_updated: "Tags Updated",
        shared: "ADR Shared",
        sharing_stopped: "ADR No Longer Shared",
      }
    },
    pages: {
      adrs: {
        no_drafts: "None Drafted",
        no_accepted: "None Accepted",
        no_replaced: "None Replaced",
        no_rejected: "None Rejected",
        new: {
          adr_invalid: "ADR is invalid. See below",
        },
        edit: {
          adr_cannot_be_accepted: "ADR cannot be accepted. See below",
          adr_invalid: "ADR is invalid. See below",
          refines: "Refines",
          proposed_replacement: "Proposed Replacement for",
        }
      },
      adrs_for_tag: {
        no_drafts: "None Drafted with tag '%{tag}'",
        no_accepted: "None Accepted with tag '%{tag}'",
      },
    },
  },
}

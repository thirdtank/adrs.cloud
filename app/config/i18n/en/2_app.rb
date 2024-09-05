# This is for app-specific stuff. It can override anything in 1_defaults if needed
{
  # en: must be the first entry, thus indicating this is the EN translations
  en: {
    general: {
      nevermind: "Nevermind",
      cv: { # short for "constraint violations" to avoid having to type that out
        be: { # short for "back-end", again not to have to type it out
          # These are snake case, which is idiomatic for Ruby.  The values
          # here are all based on DataObjectValidator's behavior
          not_enough_words: "%{field} must have at least %{minwords} words",
        },
      },
    },
    layouts: {
      default: {
        title: "Welcome to ADRpg!",
        logout: "Logout",
      },
    },
    pages: {
      general: {
        view_all: "View All",
        draft: "DRAFT",
        back: "Back",
        edit: "Edit",
        view: "View",
        share: "Share",
        none: "None",
        aria: {
          external_link_icon: "external link icon",
        },
        adr_accepted: "ADR Accepted",
        adr_created: "ADR Created",
        adr_rejected: "ADR Rejected",
        adr_shared: "ADR Shared",
        adr_invalid: "ADR cannot be created. See below.",
        tags_updated: "Tags Updated",
        sharing_stopped: "Sharing Stopped",
        auth: {
          no_account: "No account with that email",
          logged_out: "You have been logged out",
        }
      },
      AdrsPage: {
        adrs: "ADRs",
        adrs_tagged: "ADRs tagged %{block}",
        name: "Name",
        accepted_on: "Accepted On",
        created_on: "Created On",
        rejected_on: "Rejected On",
        replaced_by: "Replaced By",
        actions: "Actions",
        no_drafts: "None Drafted",
        no_accepted: "None Accepted",
        no_replaced: "None Replaced",
        no_rejected: "None Rejected",
        drafts: "Drafts",
        accepted: "Accepted",
        replaced: "Replaced",
        rejected: "Rejected",
        edit_draft: "Edit Draft",
        add_new: "Add a new one!",
        view_replaced_and_rejected: "View Replaced and Rejected ADRs",
        view_original: "View Original",
        view_replacement: "View Replacement",
        view_draft: "View Draft",
        captions: {
          accepted: "Accepted ADRs",
          drafts: "Draft ADRs",
          replaced: "Replaced ADRs",
          rejected: "Rejected ADRs",
        },
        refines: "refines “%{block}”",
        replaces: "proposed to replace “%{block}”",
      },
      AdrsByExternalIdPage: {
        accepted: "Accepted %{block}",
        originally_accepted: "Originally Accepted %{block}",
        replaces: "Replaces “%{block}”",
        rejected: "Rejected on %{block}",
        created: "Created %{block}",
        refines: "Refines “%{block}”",
        already_shared: "This ADR is already shared",
        not_shared: "This ADR is not shared",
        stop_sharing: "Stop Sharing",
        share_confirm: "This will create a publicly accessible URL to allow anyone with that URL to view this ADR",
        stop_share_confirm: "Anyone with this ADR's shareable URL will not longer be able to access it",
        view_share_page: "View Shareable Page",
        replace: "Replace",
        refine: "Refine",
        add: "Add Tags",
        save_tags: "Save Tags",
        fields: {
          context: "**In the context of** %{content}",
          facing: "**Facing** %{content}",
          decision: "**We decided** %{content}",
          neglected: "**Neglecting** %{content}",
          achieve: "**To achieve** %{content}",
          accepting: "**Accepting** %{content}",
          because: "**Because** %{content}",
        },
      },
      EditDraftAdrByExternalIdPage: {
        proposed_replacement: "Proposed Replacement for “%{block}”",
        refines: "Refines “%{block}”",
        adr_cannot_be_accepted: "ADR cannot be accepted. See below.",
        adr_invalid: "ADR cannot be saved. See below.",
      },
      NewDraftAdrPage: {
        draft_new: "Draft New ADR",
        refines: "Refines “%{title}”",
        replaces: "Proposed to Replace “%{title}”",
        adr_invalid: "ADR cannot be created. See below."
      },
      SharedAdrsByShareableIdPage: {
        replaced_on: "Replaced on %{block}",
        replaced_by: "reaplaced by “%{block}”",
        accepted: "Accepted %{block}",
        originally_accepted: "Originally Accepted %{block}",
        replaces: "Replaces “%{block}”",
        refines: "Refines “%{block}”",
        fields: {
          context: "**In the context of** %{content}",
          facing: "**Facing** %{content}",
          decision: "**We decided** %{content}",
          neglected: "**Neglecting** %{content}",
          achieve: "**To achieve** %{content}",
          accepting: "**Accepting** %{content}",
          because: "**Because** %{content}",
        },
      },
      adrs: {
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
    components: {
      "Adrs::FormComponent": {
        adr_title: "Title",
        adr_title_placeholder: "e.g. We Should Write Tests",
      },
      "Adrs::GetRefinementsComponent": {
        refinements: "Refinements",
        is_accepted: "Accepted",
        is_rejected: "Rejected",
        is_draft: "Draft",
      },
    }
  },
}

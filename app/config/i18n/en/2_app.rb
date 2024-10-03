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
          account_exists: "That account already exists",
        },
      },
    },
    layouts: {
      default: {
        title: "Welcome to ADRpg!",
      },
    },
    pages: {
      general: {
        logout: "Logout",
        help: "Help and Support",
        adrpg: "ADRPG",

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
        adr_updated: "ADR Updated",
        adr_rejected: "ADR Rejected",
        adr_shared: "ADR Shared",
        adr_invalid: "ADR cannot be created. See below.",
        tags_updated: "Tags Updated",
        sharing_stopped: "Sharing Stopped",
        add_new_limit_exceeded: "You've reached your plan limit",
        auth: {
          no_account: "No account with that email",
          logged_out: "You have been logged out",
        }
      },
      AdrsPage: {
        add_new: "Add New Draft",
        filter_by_tag: "Filter by Tag",
        remove_filter: "Remove Tag Filter",
      },
      AdrsByExternalIdPage: {
        accepted: "Accepted %{block}",
        originally_accepted: "Originally Accepted %{block}",
        replaces: "Replaces “%{block}”",
        replaced_by: "Replaced by “%{block}”",
        replaced_on: "on %{block}",
        rejected: "Rejected on %{block}",
        created: "Created %{block}",
        refines: "Refines “%{block}”",
        already_shared: "This ADR is already shared",
        not_shared: "This ADR is not shared",
        stop_sharing: "Stop Sharing",
        stop_sharing_short: "Stop",
        share_confirm: "This will create a publicly accessible URL to allow anyone with that URL to view this ADR",
        stop_share_confirm: "Anyone with this ADR's shareable URL will not longer be able to access it",
        view_share_page: "View Shareable Page",
        replace: "Replace",
        refine: "Refine",
        add: "Add Tags",
        save_tags: "Save Tags",
        edit_adr: "Edit ADR",
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
      "Admin::AccountsByExternalIdPage" => {
        entitlements_saved: "Entitlements updated",
        entitlements_cannot_be_saved: "Entitlements cannot be saved",
      },
      "Admin::HomePage" => {
        account_created: "Account created and access granted",
        account_deactivated: "Account has been deactivcated",
      },
    },
    components: {
      "AdrsPage::TabComponent": {
        accepted: "Accepted",
        drafts: "Draft",
        replaced: "Replaced",
        rejected: "Rejected",
      },
      "AdrsPage::TabPanelComponent": {
        captions: {
          accepted: "Accepted ADRs",
          drafts: "Draft ADRs",
          replaced: "Replaced ADRs",
          rejected: "Rejected ADRs",
        },
        columns: {
          title: "Title",
          context: "Context",
          created_at: "Created",
          rejected_at: "Rejected",
          accepted_at: "Accepted",
          actions: "Actions",
        },
        accepted: "Accepted ADRs",
        drafts: "Draft ADRs",
        replaced: "Replaced ADRs",
        rejected: "Rejected ADRs",
        view: "View",
        edit: "Edit",
        none: "None",
      },
      "AdrsPage::AdrTitleComponent": {
        refines: "Refines “%{block}”",
        replaces: "Replaces “%{block}”",
        replaced_by: "Replaced by “%{block}”",
        proposed_replacement: "Proposed to replace “%{block}”",
      },
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

# This is for app-specific stuff. It can oveadrscloud anything in 1_defaults if needed
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
          taken: "%{field}'s value is already taken",
        },
      },
      logout: "Logout",
      help: "Help and Support",
      adrscloud: "ADRs.cloud",
      default_site_announcement: "ADRs.Cloud is working properly",
      current_site_announcement: "ADRs.Cloud is working properly as of %{time}",
      adr_rejected: "ADR Rejected",
      page_title: "Welcome to ADRs.cloud!",
      view_all: "View All",
      sharing_stopped: "ADR no longer shared",
      adr_shared: "ADR now shared",
      adr_accepted: "ADR Accepted",
      adr_created: "ADR Created",
      project_archived: "Project Archived",
      new_project_created: "Project Created",
      project_updated: "Project Updated",
      adr_cannot_be_accepted: "ADR cannot be accepted. See below.",
      new_adr_invalid: "ADR cannot be created. See below.",
      new_project_invalid: "Project cannot be created. See below.",
      save_project_invalid: "Project cannot be saved. See below.",
      tags_updated: "ADR's tags updated",
      draft: "DRAFT",
      back: "Back",
      edit: "Edit",
      view: "View",
      none: "None",
      aria: {
        external_link_icon: "external link icon",
      },
      add_new_limit_exceeded: "You've reached your limit",
      adrs_remaining_counts: "%{num} of %{max} ADRs Remaining",
      project_limit_exceeded: "You've reached your limit",
      projects_remaining_counts: "%{num} of %{max} Projects Remaining",
      contact_support_for_limit_increase: "Reject some ADRs or <a href='mailto:support@adrgp' class='blue-700'>contact support</a> for a limit increase",
      auth: {
        no_account: "No account with that email",
        logged_out: "You have been logged out",
      }
    },
    pages: {
      HelpPage: {
        support_message: "We'll take care of whatever you need, including <strong>plan limits</strong>, <strong>how to</strong> use the app, or even <strong>account &amp; data deletion</strong>.",
      },
      AdrsPage: {
        add_new: "Add New Draft",
        filter_by_tag: "Filter by Tag",
        tag_filter_placeholder: "e.g. OOP",
        remove_filter: "Remove Tag Filter",
        title_additions: {
          refines: "Refines “%{block}”",
          replaces: "Replaces “%{block}”",
          replaced_by: "Replaced by “%{block}”",
          proposed_replacement: "Proposed to replace “%{block}”",
        },
        tabs: {
          accepted: "Accepted",
          drafts: "Draft",
          replaced: "Replaced",
          rejected: "Rejected",
        },
        captions: {
          accepted: "Accepted ADRs",
          drafts: "Draft ADRs",
          replaced: "Replaced ADRs",
          rejected: "Rejected ADRs",
        },
        columns: {
          title: "Title",
          project: "Project",
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
        your_account: "Your Account and Projects",
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
        share: "Share",
        share_confirm: "This will create a publicly accessible URL to allow anyone with that URL to view this ADR",
        stop_share_confirm: "Anyone with this ADR's shareable URL will not longer be able to access it",
        view_share_page: "View Shareable Page",
        replace: "Replace",
        refine: "Refine",
        add_tags: "Add Tags",
        save_tags: "Save Tags",
        edit_adr: "Edit ADR",
        fields: {
          context: "Context",
          facing: "Concerns or Issues",
          decision: "Decision",
          neglected: "Options Considered, but Not Chosen",
          achieve: "System Qualities or Desired Consequences",
          accepting: "Downsides",
          because: "Additional Rationale",
        },
        no_tags: "No Tags",
      },
      EditDraftAdrByExternalIdPage: {
        edit: "Edit Draft ADR",
        proposed_replacement: "Proposed Replacement for “%{block}”",
        refines: "Refines “%{block}”",
        adr_updated: "ADR Updated",
        adr_not_updated: "ADR Could not be updated",
      },
      NewDraftAdrPage: {
        draft_new: "Draft New ADR",
        refines: "Refines “%{title}”",
        replaces: "Proposed to Replace “%{title}”",
      },
      SharedAdrsByShareableIdPage: {
        replaced_on: "Replaced on %{block}",
        replaced_by: "reaplaced by “%{block}”",
        accepted: "Accepted %{block}",
        created: "Created %{block}",
        originally_accepted: "Originally Accepted %{block}",
        replaces: "Replaces “%{block}”",
        refines: "Refines “%{block}”",
        fields: {
          context: "Context",
          facing: "Concerns or Issues",
          decision: "Decision",
          neglected: "Options Considered, but Not Chosen",
          achieve: "System Qualities or Desired Consequences",
          accepting: "Downsides",
          because: "Additional Rationale",
        },
      },
      AccountByExternalIdPage: {
        contact_support_for_limit_increase: "<a href='mailto:support@adrgp' class='blue-300'>Contact support</a> for a limit increase.",
        project_limit_exceeded: "You've reached your limit on number of projects.",
        back_to_adrs: "Back to Your ADRs",
        tabs: {
          "projects": {
            title: "Projects",
            intro: "Organize your ADRs into different projects. This allows you to manage ADRs scoped to just one project or app.",
          },
          "download": {
            title: "Download Your ADRs",
            intro: "The ADRs you have created belong to you. Download them here to use in other systems.",
          },
          "info": {
            title: "Info and Limits",
            intro: "Here you will find all the personal information we are storing, as well as your account's limits.",
          },
        },
        projects: {
          default_shared: "Shared",
          default_private: "Not Shared",
          archived: "Archived",
          add_new: "Add New Project",
          archive: "Archive",
          archive_confirmation: "ADRs will still be available and editable, but no new ADRs can be added to this project",
          columns: {
            name: "Name",
            description: "Description",
            sharing: "Default Sharing",
            actions: "Actions",
          },
        },
        download: {
          create_download: "Create Download",
          create_download_explanation: "We'll assemble all your data into a single download. Check back here to see when it's done. Should be just a few minutes.",
          download: "Download",
        },
        info: {
          personal: {
            title: "Personal Info",
            email: {
              title: "Email",
              note: "This value was provided by GitHub and cannot currently be changed in our system.",
            },
            timezone: {
              title: "Timezone",
              note: "These values are derived from your web browser and currently cannot be overridden.",
            },
            locale: {
              title: "Locale",
            },
          },
          limits: {
            title: "Limits",

          }
        },
      },
      NewProjectPage: {
        new_project: "Create Project",
      },
      EditProjectByExternalIdPage: {
        edit_project: "Edit Project",
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
      "Adrs::FormComponent": {
        adr_title: "Title",
        adr_title_placeholder: "e.g. We Should Write Tests",
        actions: {
          update_draft: "Update Draft",
          save_draft: "Save Draft",
          save_replacement_draft: "Save Replacement Draft",
          save_refining_draft: "Save Refining Draft",
          reject: "Reject ADR",
          accept: "Accept ADR",
        },
        fields: {
          context: {
            label: "Context",
            context: "Background information to provide context for the decision.",
          },
          facing: {
            label: "Concerns or Issues",
            context: "Specific issues that the decision is meant to address",
          },
          decision: {
            label: "Decision",
            context: "The decision that was made.",
          },
          neglected: {
            label: "Options Considered, but Not Chosen",
            context: "Any options evaluated to address the concerns that were not chosen, and why.",
          },
          achieve: {
            label: "System Qualities or Desired Consequences",
            context: "Expected benefits of the decision beyond simply addressing the concerns.",
          },
          accepting: {
            label: "Downsides",
            context: "Trade-offs or consequences of the decision that are understood and accepted.",
          },
          because: {
            label: "Additional Rationale",
            context: "Any additional information relevant to understranding the decision",
          },
          tags: {
            label: "Tags",
            context: "Tags, delimited by commas or newlines to allow categorization of this ADR.",
          },
        },
      },
      "Adrs::GetRefinementsComponent": {
        refinements: "Refinements",
        is_accepted: "Accepted",
        is_rejected: "Rejected",
        is_draft: "Draft",
      },
      "AccountByExternalIdPage::DownloadProgressComponent": {
        download_ready: "Download Ready",
        download_being_assembled: "Download Being Assembled",
        download_ready_text: "Your data as of %{created} is ready to download. It'll be available here until %{deleted}.",
        download: "Download",
        create_new: "Create New Download",
        create_new_confirmation: "This will delete your existing download",
        create_new_explanation: "This will delete the currently-available download and create a new one with all your data as of this moment.",
        assembled_message: "Your data is being assembled. Please check back.",
      },
      "Projects::FormComponent": {
        actions: {
          new: "Create Project",
          edit: "Save Project",
        },
        name: {
          label: "Name",
          placeholder: "e.g. www",
        },
        description: {
          label: "Description",
          placeholder: "e.g. the app running our website",
        },
        adrs_shared_by_default: {
          label: "Share ADRs by Default?",
        }
      },
    },
    domain: {
      account: {
        github: {
          uid_used_by_other_account: "The UID provided by GitHub is linked to another account.",
          uid_changed: "The UID provided by GitHub is not the one used when you first signed up.",
        },
      },
    }
  },
}

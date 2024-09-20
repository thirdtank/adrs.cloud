require "brut/back_end/seed_data"

class One < Brut::Backend::SeedData
  include FactoryBot::Syntax::Methods
  def seed!
    account             = create(:account, :without_entitlement, email: "davec@naildrivin5.com")
    entitlement_default = create(:entitlement_default, internal_name: "basic", max_non_rejected_adrs: 20)
    entitlement         = create(:entitlement, max_non_rejected_adrs: nil, entitlement_default: entitlement_default, account: account)

    create(:adr, account: account,
           title: "Web Apps use GET and POST only",
           context: "Building a web app and *not* an API",
           facing: "complexity and confusion around the various HTTP verbs.  For a web page, PUT, PATCH, and DELETE don""t make sense as the browser cannot use this in a form submission.\n\nFurther, PUT vs PATCH is confusing, and POST seems to cover most needs. There doesn""t seem to be any real technical reason to use PUT, PATCH, or DELETE for a form submission.",
           decision: "To only use `GET` and `POST` for web app interaction, meaning actions that result in rendering HTML or that are intended to interact with a user.",
           neglected: "RESTFul behavior (other verbs), or an abstraction on top of GET/POST",
           achieve: "A simpler surface area for the controller layer that maps directly to HTML and what the web actually does and actually supports",
           accepting: "This will be different than other frameworks, and certainly coerce all non-idempotent actions into a POST.",
           because: "Ultimately, for the web app part, there is no benefit to PATCH, PUT, and DELETE. Forms can""t use these methods, so they must be hacked and then the backend basically conflates all of this stuff in a potentially confusing way.",
           tags: [ "web", "rest", "seeds" ],
           created_at: Time.now  - (60 * 60 * 48),
           accepted_at: Time.now,
           shareable_id: "shared-from-seeds"
          )
    refined = create(:adr, :accepted, account: account)
    replacing = create(:adr, :accepted, account: account)

    replaced = create(:adr, :accepted, account: account, replaced_by_adr_id: replacing.id)
    create(:adr, refines_adr_id: refined.id)

    DB::ProposedAdrReplacement.create(replaced_adr_id: replaced.id,
                                      replacing_adr_id: replacing.id)

    create(:adr)
    create(:adr, :accepted, accepted_at: nil, rejected_at: Time.now)

  end
end

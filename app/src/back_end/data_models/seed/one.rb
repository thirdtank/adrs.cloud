require "brut/back_end/seed_data"
module Seed
end
class Seed::One < Brut::BackEnd::SeedData
  include FactoryBot::Syntax::Methods
  def seed!
    account             = create(:account, :without_entitlement, email: "pat@example.com")
    project             = account.projects.first
                          create(:project, account: account)
                          create(:project, account: account)
    entitlement_default = create(:entitlement_default, internal_name: "basic", max_non_rejected_adrs: 20)
    entitlement         = create(:entitlement, max_non_rejected_adrs: nil, entitlement_default: entitlement_default, account: account)

    postgres = create(:adr, account: account, project: project,
           "title": "Choosing PostgreSQL Over MySQL",
           "context": "We need to select a database management system (DBMS) for our application that requires robust support for complex queries, ACID compliance, and scalability for future growth. The primary candidates are PostgreSQL and MySQL.",
           "facing": "The main challenge is to choose a database that can handle complex queries, provide strong consistency, and scale effectively with anticipated application growth.",
           "decision": "We have decided to use PostgreSQL as the DBMS for our application instead of MySQL.",
           "neglected": "While MySQL is widely used and easier to set up for basic applications, it lacks some advanced features that PostgreSQL offers, such as full ACID compliance by default, better support for complex queries, and advanced data types (e.g., JSONB). NOSQL databases Were neglected due to the strong need for relational integrity and complex queries in our application.",
           "achieve": "We aim to: Ensure robust support for complex queries and data relationships; Leverage PostgreSQL's advanced features like window functions, JSON support, and table partitioning; Benefit from PostgreSQL's superior ACID compliance for transactional integrity.",
           "accepting": "We are accepting the potential trade-off of PostgreSQL being slightly more complex to manage and set up than MySQL. We may also encounter a smaller pool of developers with expertise in PostgreSQL compared to MySQL.",
           "because": "PostgreSQL offers better support for complex queries, ACID compliance, and scalability, which aligns with our long-term needs for the application. Its advanced data types and overall flexibility make it a better fit than MySQL for our current and future use cases.",
           tags: [ "database", "postgresql", "mysql" ],
           created_at: Time.now  - (60 * 60 * 48),
           accepted_at: Time.now,
           shareable_id: "shared-from-seeds"
          )

    tailwind = create(:adr, :accepted, account: account, project: project,
           "title": "Choosing TailwindCSS for Styling",
           "context": "We need to choose a CSS framework for our front-end development that supports rapid UI development, maintains flexibility, and ensures consistency across the application. The primary options are TailwindCSS and traditional CSS frameworks like Bootstrap or custom CSS.",
           "facing": "The main challenge is finding a styling solution that allows for fast iteration on UI components while ensuring maintainability and avoiding excessive custom styles.",
           "decision": "We have decided to use TailwindCSS as the primary styling framework for our application.",
           "neglected": "Bootstrap and custom CSS were considered but rejected. Bootstrap, while useful for pre-built components, is less flexible for custom designs. Custom CSS requires more effort in terms of consistency and maintainability across the project.",
           "achieve": "We aim to speed up UI development by using TailwindCSS's utility-first approach, maintain flexibility for custom designs, and reduce the amount of custom CSS needed.",
           "accepting": "We accept that TailwindCSS may have a learning curve for developers unfamiliar with utility-first CSS frameworks and may lead to longer class lists in HTML.",
           "because": "TailwindCSS provides a faster development experience, allows for greater flexibility in custom designs, and enforces a consistent design system without the overhead of writing repetitive CSS rules.",
           tags: [ "CSS", "TailwindCSS", "frontend" ].map(&:downcase),
          )

    triggers = create(:adr,:accepted, account: account, project: project,
                      "title": "Avoiding the Use of Triggers in PostgreSQL",
                      "context": "We are designing the database architecture for our application, and there is a need to decide whether to use database triggers for certain automated tasks such as auditing, validation, or maintaining data consistency.",
                      "facing": "The challenge is to determine whether triggers, which offer automatic execution of database tasks, should be used despite potential drawbacks in terms of complexity, debugging, and performance.",
                      "decision": "We have decided to avoid using triggers in PostgreSQL for managing database logic.",
                      "neglected": "Triggers were considered for tasks like audit logging and enforcing business rules, but they were rejected due to concerns about hidden logic, difficulties in debugging, and performance impacts. Alternative solutions like explicit application-level logic or database constraints will be used instead.",
                      "achieve": "We aim to simplify database logic, improve maintainability, and make debugging easier by avoiding hidden, implicit behavior caused by triggers.",
                      "accepting": "We accept that certain tasks may require additional effort to implement at the application level and may not be as automatic as with triggers.",
                      "because": "Triggers can introduce hidden side effects, making the system harder to understand and debug. By avoiding triggers, we reduce the risk of unintentional behavior and make the application logic more transparent and maintainable.",
                      tags: [ "maintainability", "triggers", "database", "PostgreSQL" ].map(&:downcase),
                      refines_adr_id: postgres.id,
                     )


    bem = create(:adr, :accepted, account: account, project: project,
                 "title": "Switching to Standardized CSS and BEM Naming Over TailwindCSS",
                 "context": "We initially chose TailwindCSS for our application to accelerate UI development. However, as the project grows, we are reconsidering the long-term maintainability and readability of our codebase, especially for new developers joining the team.",
                 "facing": "The challenge is balancing rapid development with code readability, maintainability, and adherence to widely accepted CSS standards across a growing development team.",
                 "decision": "We have decided to switch from TailwindCSS to standardized CSS with BEM (Block Element Modifier) class names for styling.",
                 "neglected": "TailwindCSS was initially adopted for its speed in building UI components but is now being neglected due to concerns about long HTML class lists, the learning curve for new developers, and difficulties in enforcing consistent design principles.",
                 "achieve": "We aim to achieve better readability and maintainability of our codebase, ensure that styling follows a standardized approach across the team, and make it easier for new developers to onboard quickly by using widely adopted BEM conventions.",
                 "accepting": "We accept that development may slow down slightly as developers move away from utility-first CSS and begin to write more custom styles. Additionally, we will need to ensure consistency across components without Tailwind's design system enforcing it.",
                 "because": "Standardized CSS with BEM class names provides a more universally understood and structured way of writing styles. It simplifies collaboration among developers and makes the code more maintainable in the long term, without the complexity of utility-based class systems.",
                 tags: [ "CSS", "BEM", "TailwindCSS", "frontend" ].map(&:downcase),
                )
    tailwind.update(replaced_by_adr_id: bem.id)
    DB::ProposedAdrReplacement.create(replaced_adr_id: tailwind.id,
                                      replacing_adr_id: bem.id)



    create(:adr, :rejected, account: account, project: project,
           "title": "Using BEM and TailwindCSS Together for Styling",
           "context": "We are looking for a styling approach that combines the flexibility and speed of TailwindCSS with the structure and maintainability of BEM. The goal is to benefit from utility-first CSS while still maintaining clear, modular, and readable class names in the codebase.",
           "decision": "We have decided to use both BEM and TailwindCSS together. Tailwind will handle utility classes for layout, spacing, and minor styling, while BEM will structure our custom components with clear, modular naming conventions.",
          )
    create(:adr, :rejected, account: account, project: project,
             "title": "Adopting JS-in-CSS for Component-Level Styling",
  "context": "We are exploring approaches to manage styles in our application that provide greater flexibility, scope isolation, and dynamic styling tied closely to JavaScript components. JS-in-CSS solutions like styled-components or Emotion offer a modern way to handle these requirements.",
  "decision": "We have decided to adopt JS-in-CSS for component-level styling to take advantage of its ability to scope styles to individual components, enable dynamic styling, and promote better integration between our JavaScript logic and UI styling.",
          )

    create(:adr, account: account, project: project,
           "title": "Deciding Not to Use Rails for Our Application",
           "context": "We are in the process of selecting a web framework for our new application. While Rails is a popular choice with many features out of the box, we need to consider our team’s expertise and the specific requirements of our project.",
           "facing": "The main challenge is determining whether to adopt Rails, which may have a steep learning curve for our team and might not align with our performance and scalability needs.",
           "decision": "We have decided not to use Rails for our application.",
           "neglected": "Rails was considered for its rapid development capabilities and extensive community support, but it was rejected due to concerns about performance, the complexity of deployment, and potential limitations with scaling as the application grows.",
           "achieve": "We aim to achieve a more streamlined development process by selecting a framework that better matches our team’s skills and the specific needs of our application, while also ensuring optimal performance and scalability.",
           "because": "Choosing a framework that aligns with our team’s expertise and project requirements is essential for success. By avoiding Rails, we can select a more suitable technology stack that ensures flexibility, performance, and easier onboarding for new developers.",
          )

  end
end

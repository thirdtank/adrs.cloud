require "spec_helper"

RSpec.describe AcceptedAdrsByProjectExternalIdPage do
  it "shows only those ADRs that are accepted and shared" do
    project = create(:project)

    draft                    = create(:adr,
                                      project: project)
    rejected                 = create(:adr, :rejected,
                                      project: project)
    accepted_private         = create(:adr, :accepted, :private,
                                      project: project)
    accepted_shared_replaced = create(:adr, :accepted, :shared,
                                      project: project,
                                      replaced_by_adr: create(:adr, :accepted,
                                                              project: project))
    accepted_shared         = create(:adr, :accepted, :shared,
                                     project: project)
    accepted_shared_refined = create(:adr, :accepted, :shared,
                                     project: project)
    refines_shared          = create(:adr, :shared,
                                     project: project,
                                     refines_adr_id: accepted_shared_refined.id)
    refines_private         = create(:adr, :private, :accepted,
                                     project: project,
                                     refines_adr_id: accepted_shared_refined.id)

    result = generate_and_parse(
      described_class.new(project_external_id: project.external_id)
    )

    expect(
      result.css("[id='#{draft.external_id}']").length
    ).to eq(0)

    expect(
      result.css("[id='#{rejected.external_id}']").length
    ).to eq(0)

    expect(
      result.css("[id='#{accepted_private.external_id}']").length
    ).to eq(0)

    expect(
      result.css("[id='#{accepted_shared_replaced.external_id}']").length
    ).to eq(0)

    expect(
      result.css("[id='#{accepted_shared.external_id}']").length
    ).to eq(1)

    expect(
      result.css("[id='#{refines_shared.external_id}']").length
    ).to eq(1)

    expect(
      result.css("[id='#{refines_private.external_id}']").length
    ).to eq(0)

    refined  = result.css("[id='#{accepted_shared_refined.external_id}']")

    expect(
      refined.length
    ).to eq(1)

    expect(
      refined[0].css("a[href='##{refines_shared.external_id}']").length
    ).to eq(1)

  end
end

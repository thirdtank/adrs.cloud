class DB::ProposedAdrReplacement < AppDataModel
  # Active verbs here are how to understand this
  #
  # The ADR doing the replacing is replacing_adr
  # The ADR being replaced is the replaced_adr
  #
  many_to_one :replacing_adr, class: "DB::Adr"
  many_to_one :replaced_adr, class: "DB::Adr"

end

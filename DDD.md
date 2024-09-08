# DDD

Draft ADR
      - created
        [] -> DraftAdr
      - edited
        DraftAdr[1] -> DraftAdr[1]
      - rejected
        DraftAdr -> RejectedAdr

Accepted ADR
      - created (from Draft ADR)
        Draft -> Accepted ADR
      - propose replacement
        Accepted ADR -> Draft ADR
      - replace
        Draft ADR[Accepted ADR] -> Accepted ADR
      - propose refinement
        Accepted ADR -> Draft ADR
      - refine
        Draft ADR[Accepted ADR] -> Accepted ADR



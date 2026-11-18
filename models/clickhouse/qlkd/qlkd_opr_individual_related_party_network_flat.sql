-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_related_party_network_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Related Party Network
    o.related_party_network_id,
    o.individual_identification_nbr,
    o.individual_full_nm,
    o.sc_senior_personnel_code,
    o.related_person_full_nm,
    o.rltnp,
    o.representative_position,
    o.related_person_position_nm,
    o.identification_nbr,
    o.shares_count,
    o.ownership_ratio,
    o.relation_start_dt,
    o.effective_from_dt,
    o.effective_to_dt,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_related_party_network') }} o
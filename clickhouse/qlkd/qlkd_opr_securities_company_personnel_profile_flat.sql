-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_personnel_profile_flat
-- Type  : OPERATIONAL
-- [FIX 2026-11-05] cl_sc_position_code/position_nm o Datamart gio la
-- ARRAY<string> dong bo theo index (1 nguoi co the giu nhieu chuc vu dong
-- thoi). Fan-out tai day (tang khong co rang buoc unique_key) bang
-- explode theo POSITION, de 1 nguoi N chuc vu ra N dong - giong dung hanh
-- vi arrayJoin cua cau query ClickHouse nghiep vu.
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Securities Company Personnel Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.department,
    pos_code                                       AS cl_sc_position_code,
    element_at(o.position_nm, pos_idx + 1)         AS position_nm,
    o.email,
    o.phone,
    o.work_start_dt,
    o.dismissal_dt,
    o.personnel_status_code,
    o.src_stm_code

FROM {{ ref('dtm_opr_securities_company_personnel_profile') }} o
LATERAL VIEW OUTER posexplode(o.cl_sc_position_code) pe AS pos_idx, pos_code
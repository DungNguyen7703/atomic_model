-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_investment_fund_representative_board_member_list_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Investment Fund Representative Board Member List
    investment_fund_representative_board_member_code,
    investment_fund_id,
    investment_fund_code,
    board_member_full_nm,
    src_stm_code

FROM {{ ref('dtm_opr_investment_fund_representative_board_member_list') }}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
  AND src_stm_code = 'FMS_REPRESENT'
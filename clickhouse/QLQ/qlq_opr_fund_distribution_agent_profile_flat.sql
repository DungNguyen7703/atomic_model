-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_distribution_agent_profile_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: thêm distributing_fund_count + 14 KPI báo cáo TinhHinhGiaoDichCCQ_06268 theo dtm_opr_fund_distribution_agent_profile
--                    (LLD commit 2f62880d; schema-changing, cần ALTER bảng ClickHouse — ddl/20261014_qlq_ck_flat_sync.sql)
-- 2026-11-03 claude: bỏ 14 cột rpt (chuyển sang fct_fund_management_rpt_cell_val), thêm distribution_cert_dt theo dtm_opr_fund_distribution_agent_profile
--                    (LLD commit f2628ecf, O_QLQ_72; schema-changing, cần ALTER bảng ClickHouse — ddl/20261103_qlq_ck_flat_sync.sql)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Distribution Agent Profile
    securities_distribution_agent_code,
    securities_distribution_agent_full_nm,
    license_nbr,
    license_dt,
    address,
    active_status_flag,
    termination_dt,
    distribution_cert_dt,
    distributing_fund_count,
    src_stm_code

FROM {{ ref('dtm_opr_fund_distribution_agent_profile') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'
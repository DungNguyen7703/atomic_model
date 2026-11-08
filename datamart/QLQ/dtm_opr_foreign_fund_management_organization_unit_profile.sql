/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_foreign_fund_management_organization_unit_profile
* Program name: Dtm Opr Foreign Fund Management Organization Unit Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
* 2026-11-02		claude (sync)		Đồng bộ LLD commit ccc6d036 (O_QLQ_71): nhãn cột thật có đuôi ' >> n' (UAT 2026-11-02): net_profit_after_tax_amt/owner_equity_amt so khớp phần tử ĐẦU của SPLIT(column_label_nm,' >> '); capital_adequacy_ratio dùng LIKE '%Giá trị rủi ro/vốn khả dụng%' (logic-only, schema không đổi)
* 2026-11-03		claude (sync)		Đồng bộ LLD commit f2628ecf (O_QLQ_72): bỏ 5 cột rpt (certified_practitioner_staff_count, capital_adequacy_ratio,
*                                       net_profit_after_tax_amt, owner_equity_amt, portfolio_management_contract_count) — đã chuyển sang fct_fund_management_rpt_cell_val; bỏ CTE fmr_value/fmr_submission/rpt_cell_val/rpt_kpi (schema-changing)
*/

WITH establishment_license AS (
    SELECT
        ip_id,
        MIN(identification_issue_dt) AS identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
    GROUP BY ip_id
),

foreign_fm_ou AS (
    SELECT
        foreign_fund_management_organization_unit_id AS foreign_fm_ou_id,
        foreign_fund_management_organization_unit_code AS foreign_fm_ou_code,
        foreign_fund_management_organization_unit_full_nm AS foreign_fm_ou_full_nm,
        foreign_fund_management_organization_unit_short_nm AS foreign_fm_ou_short_nm,
        src_stm_code
    FROM (
        SELECT 
            foreign_fund_management_organization_unit_id,
            foreign_fund_management_organization_unit_code,
            foreign_fund_management_organization_unit_full_nm,
            foreign_fund_management_organization_unit_short_nm,
            effective_start_dt,
            src_stm_code
        FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'FMS_FOR_BRCH'
            AND branch_tp_code = '1'
    ) foreign_fm_ou
    LEFT JOIN establishment_license
        ON ip_id = foreign_fund_management_organization_unit_id
    WHERE COALESCE(effective_start_dt, identification_issue_dt) <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

foreign_fm_ou_staff AS (
    SELECT
        foreign_fund_management_organization_unit_id AS foreign_fm_ou_id,
        foreign_fund_management_organization_unit_staff_code AS foreign_fm_ou_staff_code,
        foreign_fund_management_organization_unit_staff_full_nm AS foreign_fm_ou_staff_full_nm,
        branch_director_flag
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_staff_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STF_FG_BRCH'
),

director AS (
    SELECT
        foreign_fm_ou_id,
        foreign_fm_ou_staff_full_nm
    FROM (
        SELECT
            foreign_fm_ou_id,
            foreign_fm_ou_staff_full_nm,
            ROW_NUMBER() OVER (PARTITION BY foreign_fm_ou_id
                               ORDER BY foreign_fm_ou_staff_code) AS rn
        FROM foreign_fm_ou_staff
        WHERE branch_director_flag = 1
    ) t
    WHERE rn = 1
)

SELECT
    CAST(foreign_fm_ou.foreign_fm_ou_code AS string)                       AS foreign_fund_management_organization_unit_code,
    CAST(foreign_fm_ou.foreign_fm_ou_full_nm AS string)                    AS foreign_fund_management_organization_unit_full_nm,
    CAST(foreign_fm_ou.foreign_fm_ou_short_nm AS string)                   AS foreign_fund_management_organization_unit_short_nm,
    CAST(director.foreign_fm_ou_staff_full_nm AS string)                   AS director_full_nm,
    CAST(foreign_fm_ou.src_stm_code AS string)                             AS src_stm_code
FROM foreign_fm_ou
LEFT JOIN director
    ON director.foreign_fm_ou_id = foreign_fm_ou.foreign_fm_ou_id

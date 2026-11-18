/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_distribution_agent_fund_list
* Program name: Dtm Opr Fund Distribution Agent Fund List
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_distribution_agent_fund_list_FMS_AGEN_FUNDS.csv
*                                       LLD atomic_table = fund_distribution_agent_x_investment_fund_relationship
*                                       -> ref atm_investment_fund_x_fund_distribution_agent_relationship (scd2, model thực tế cùng src FMS_AGEN_FUNDS)
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude				Đổi ref sang atm_fund_distribution_agent_x_investment_fund_relationship (Atomic đổi tên theo LLD)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: thêm cột securities_distribution_agent_code (K_QLQ_143) — MIN mã ĐLPP
*                                       (dim ĐLPP src FMS_DISTRIBUTOR_AGENT) nối với đại lý (dim src FMS_AGENCIES) theo tên rút gọn
*                                       hoặc LOWER(TRIM(tên đầy đủ)); subquery tương quan LLD -> CTE GROUP BY + LEFT JOIN (schema-changing)
* 2026-10-26		claude (sync)		Đồng bộ LLD commit 7c01421d (src FMS_FUD_AG_AGT, BA 2026-10-26): ref sang
*                                       atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship (khóa nguồn có thêm loại đại lý
*                                       -> DISTINCT theo cặp đại lý-quỹ); securities_distribution_agent_code nối theo mã
*                                       (AGEN_ID = DISTRIBUTOR_AGENT.ID) thay nối theo tên; chỉ giữ cặp có đại lý trong DISTRIBUTOR_AGENT
*                                       và quỹ chưa xóa (INNER JOIN); bỏ CTE fund_distribution_agent/distribution_agent_map. Schema output không đổi (logic-only)
*--------------------------------------------------------------------*
*/

WITH fund_distribution_agent_x_investment_fund_rltnp AS (
    SELECT DISTINCT
        fund_distribution_agent_code,
        investment_fund_id,
        investment_fund_code,
        src_stm_code
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUD_AG_AGT'
),

investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_full_nm
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_code
    FROM {{ ref('dtm_securities_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
)

SELECT
    CAST(rltnp.fund_distribution_agent_code AS string)                                        AS fund_distribution_agent_code,
    CAST(rltnp.investment_fund_code AS string)                                                AS investment_fund_code,
    CAST(investment_fund.investment_fund_full_nm AS string)                                   AS investment_fund_full_nm,
    CAST(securities_distribution_agent.securities_distribution_agent_code AS string)          AS securities_distribution_agent_code,
    CAST(rltnp.src_stm_code AS string)                                                        AS src_stm_code
FROM fund_distribution_agent_x_investment_fund_rltnp rltnp
INNER JOIN investment_fund
    ON investment_fund.investment_fund_id = rltnp.investment_fund_id
INNER JOIN securities_distribution_agent
    ON securities_distribution_agent.securities_distribution_agent_code = rltnp.fund_distribution_agent_code

/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_fund_list
* Program name: Dtm Opr Fund Management Company Fund List
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		claude (sync)		Đồng bộ LLD commit c4746d2d (O_QLQ_69): net_asset_val_amt so nhãn cột theo TIỀN TỐ phần tử đầu
*                                       TRIM(split(column_label_nm, ' >> ')[0]) LIKE 'Kỳ báo cáo%' thay so chính xác = 'Kỳ báo cáo'
*                                       (biến thể ' Kỳ báo cáo', 'Kỳ báo cáo (VND)', 'Kỳ báo cáo >> …') (logic-only, schema không đổi)
* 2026-11-03		claude (sync)		Đồng bộ LLD commit f2628ecf (O_QLQ_72): bỏ cột net_asset_val_amt (chuyển sang fct_fund_management_rpt_cell_val); bỏ CTE fmr_value/fmr_submission/rpt_cell_val/rpt_kpi (schema-changing)
*--------------------------------------------------------------------*
*/

WITH investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_code,
        fmc_id,
        fmc_code,
        investment_fund_full_nm,
        fund_tp_code,
        src_stm_code
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
)

SELECT
    CAST(investment_fund.investment_fund_code AS string)                AS investment_fund_code,
    CAST(investment_fund.fmc_id AS string)                              AS fmc_id,
    CAST(investment_fund.fmc_code AS string)                            AS fmc_code,
    CAST(investment_fund.investment_fund_full_nm AS string)             AS investment_fund_full_nm,
    CAST(investment_fund.fund_tp_code AS string)                        AS fund_tp_code,
    CAST(investment_fund.src_stm_code AS string)                        AS src_stm_code
FROM investment_fund

/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_investment_fund_representative_board_member_list
* Program name: Dtm Opr Investment Fund Representative Board Member List
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_investment_fund_representative_board_member_list_FMS_REPRESENT.csv
*--------------------------------------------------------------------*
*/

WITH representative_board_member AS (
    SELECT
        investment_fund_representative_board_member_code,
        investment_fund_id,
        investment_fund_code,
        board_member_full_nm,
        src_stm_code
    FROM {{ ref('atm_investment_fund_representative_board_member') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_REPRESENT'
)

SELECT
    CAST(investment_fund_representative_board_member_code AS string)        AS investment_fund_representative_board_member_code,
    CAST(investment_fund_id AS string)                                      AS investment_fund_id,
    CAST(investment_fund_code AS string)                                    AS investment_fund_code,
    CAST(board_member_full_nm AS string)                                    AS board_member_full_nm,
    CAST(src_stm_code AS string)                                            AS src_stm_code
FROM representative_board_member

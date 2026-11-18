/*
*--------------------------------------------------------------------*
* Program code: gstt_opr_public_company_insider_ownership_flat
* Program name: Gstt Opr Public Company Insider Ownership Flat
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, LLD GSTT Nhom 35] Flat Operational Public Company
*                                       Insider Ownership (Nguoi noi bo CTDC). Operational/current-
*                                       state: chi lay ban ghi ACTIVE cua snapshot etl_date (mart
*                                       scd4a giu ca ban ghi INACTIVE trong _hstr).
*                                       position_code / position_nm la ARRAY(String).
*--------------------------------------------------------------------*
*/

SELECT
    o.public_company_entity_role_code,
    o.public_company_code,
    o.legal_entity_code,
    o.equity_ticker_symbol,
    o.legal_entity_nm,
    o.ownership_quantity,
    o.ownership_ratio_percentage,
    o.ownership_dt,
    o.position_code,
    o.position_nm,
    o.src_stm_code

FROM {{ ref('dtm_opr_public_company_insider_ownership') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'

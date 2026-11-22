/*
*--------------------------------------------------------------------*
* Program code: atm_end_of_day_open_interest
* Program name: Atomic End Of Day Open Interest
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		[LLD lld_VSDC_END_OF_DAY_OPEN_INTEREST] Tao moi theo LLD: 7 cot (id, src_stm_code, ticker_symbol, open_interest_quantity, rpt_year, rpt_month, rpt_day).
*									LLD khong co rpt_dt -> ngay nghiep vu = make_date(rpt_year, rpt_month, rpt_day) (cac mart tu tinh khi can). ds_snpst_dt/ds_etl_pcs_tms do macro snapshot them.
*--------------------------------------------------------------------*
*/

WITH eo_oi AS (
    SELECT
        contract_code
        , open_interest_volume
        , report_day
        , report_month
        , report_year
    FROM {{ ref('ods_vsdc_end_of_day_open_interest') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_END_OF_DAY_OPEN_INTEREST', "contract_code") }} AS end_of_day_open_interest_id
    , CAST('VSDC_END_OF_DAY_OPEN_INTEREST' AS string)                                   AS src_stm_code
    , CAST(contract_code AS string)                                                     AS ticker_symbol
    , CAST(open_interest_volume AS bigint)                                              AS open_interest_quantity
    , CAST(report_year AS int)                                                          AS rpt_year
    , CAST(report_month AS int)                                                         AS rpt_month
    , CAST(report_day AS int)                                                           AS rpt_day
FROM eo_oi

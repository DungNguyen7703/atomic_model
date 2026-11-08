/*
*--------------------------------------------------------------------*
* Program code: atm_end_of_day_open_interest
* Program name: Atomic End Of Day Open Interest
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* 2026-10-19		tuan.nguyenvanb		[LLD atomic lld_VSDC_END_OF_DAY_OPEN_INTEREST.yaml] Them cot rpt_dt (Report Date, nguon REPORT_DATE) sau
*									open_interest_quantity. Can ALTER ADD COLUMN rpt_dt date AFTER open_interest_quantity (snapshot - insert theo vi tri).
* 2026-10-27		tuan.nguyenvanb		Doi partition sang rpt_dt (+ src_stm_code), loc ODS theo report_date = etl_date (ODS nay cung partition theo report_date).
*									ds_snpst_dt do macro snapshot gan = etl_date (= rpt_dt). Can doi partition bang vat ly (ADD PARTITION FIELD rpt_dt / DROP PARTITION FIELD ds_snpst_dt)
*									va nap lai du lieu. Cot output khong doi.
*/

WITH eo_oi AS (
    SELECT
        contract_code
        , open_interest_volume
        , report_date
    FROM {{ ref('ods_vsdc_end_of_day_open_interest') }}
    WHERE report_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_END_OF_DAY_OPEN_INTEREST', "eo_oi.contract_code") }} AS end_of_day_open_interest_id
    , CAST(eo_oi.contract_code AS string)              AS ticker_symbol
    , CAST('VSDC_END_OF_DAY_OPEN_INTEREST' AS string)  AS src_stm_code
    , CAST(eo_oi.open_interest_volume AS bigint)        AS open_interest_quantity
    , CAST(eo_oi.report_date AS date)                   AS rpt_dt
FROM eo_oi

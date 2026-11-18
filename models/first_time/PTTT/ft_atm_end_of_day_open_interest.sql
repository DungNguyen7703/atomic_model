-- [FIRST-TIME] ft_atm_end_of_day_open_interest: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_end_of_day_open_interest (config ft_target='end_of_day_open_interest', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_end_of_day_open_interest
* Program name: Atomic End Of Day Open Interest (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-27		tuan.nguyenvanb		Tao moi ban first-time: doc ODS first-time khong loc ngay, partition theo rpt_dt + src_stm_code nhu daily.
*									ds_snpst_dt = rpt_dt (daily snapshot: ds_snpst_dt = etl_date = rpt_dt).
*--------------------------------------------------------------------*
*/

WITH eo_oi AS (
    SELECT
        contract_code
        , open_interest_volume
        , report_date
    FROM {{ ft_ref('ft_ods_vsdc_end_of_day_open_interest') }}
    -- [BACKFILL-UAT-ORIG] WHERE report_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_END_OF_DAY_OPEN_INTEREST', "eo_oi.contract_code") }} AS end_of_day_open_interest_id
    , CAST(eo_oi.contract_code AS string)              AS ticker_symbol
    , CAST('VSDC_END_OF_DAY_OPEN_INTEREST' AS string)  AS src_stm_code
    , CAST(eo_oi.open_interest_volume AS bigint)        AS open_interest_quantity
    , CAST(eo_oi.report_date AS date)                   AS rpt_dt
    , CAST(eo_oi.report_date AS date)                   AS ds_snpst_dt
FROM eo_oi

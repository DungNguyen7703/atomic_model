/*
*--------------------------------------------------------------------*
* Program code: atm_fmr_value
* Program name: Atomic Fund Management Report Value
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude				Khởi tạo theo thiết kế dm_atm_fmr_value-FMS.RPT_VALUES.yaml
*										period_type bigint -> string; record_type decimal -> int -> string; year_value decimal -> int
*--------------------------------------------------------------------*
*/

WITH rp_va AS (
    SELECT
        id
        , tgt_id
        , meb_id
        , sheet_id
        , rpt_id
        , prd_id
        , values
        , dynamic_value
        , acc_values
        , period_type
        , format_data_type
        , bkm_id
        , fnd_id
        , fr_br_id
        , sec_id
        , record_type
        , period_value
        , year_value
        , row_dynamic
    FROM {{ ref('ods_fms_rpt_values') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_RPT_VALUES', "id") }}        AS fmr_val_id
    , CAST(id AS string)                                               AS fmr_val_code
    , CAST('FMS_RPT_VALUES' AS string)                                 AS src_stm_code
    , CAST(tgt_id AS string)                                           AS cell_id
    , {{ generate_surrogate_key_bigint('FMS_RPT_MEMBER', "meb_id") }}  AS fmr_submission_id
    , CAST(meb_id AS string)                                           AS fmr_submission_code
    , {{ generate_surrogate_key_bigint('FMS_SHEET', "sheet_id") }}     AS fmr_sheet_id
    , CAST(sheet_id AS string)                                         AS fmr_sheet_code
    , {{ generate_surrogate_key_bigint('FMS_RPT_TEMP', "rpt_id") }}    AS fmr_id
    , CAST(rpt_id AS string)                                           AS fmr_code
    , {{ generate_surrogate_key_bigint('FMS_RPT_PERIOD', "prd_id") }}  AS fmr_period_id
    , CAST(prd_id AS string)                                           AS fmr_period_code
    , CAST(values AS string)                                           AS cell_val
    , CAST(dynamic_value AS int)                                       AS dynamic_val_ind
    , CAST(acc_values AS string)                                       AS accumulated_val
    , CAST(period_type AS string)                                      AS period_tp_code
    , CAST(format_data_type AS string)                                 AS format_data_tp_code
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "bkm_id") }}   AS custodian_bank_id
    , CAST(bkm_id AS string)                                           AS custodian_bank_code
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "fnd_id") }}       AS investment_fund_id
    , CAST(fnd_id AS string)                                           AS investment_fund_code
    , {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "fr_br_id") }}  AS foreign_fm_ou_id
    , CAST(fr_br_id AS string)                                         AS foreign_fm_ou_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "sec_id") }}  AS fmc_id
    , CAST(sec_id AS string)                                           AS fmc_code
    , CAST(CAST(record_type AS int) AS string)                         AS record_tp
    , CAST(period_value AS string)                                     AS period_val
    , CAST(year_value AS int)                                          AS rpt_year
    , CAST(row_dynamic AS int)                                         AS dynamic_row_nbr
FROM rp_va

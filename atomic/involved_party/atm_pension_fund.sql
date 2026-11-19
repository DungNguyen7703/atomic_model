/*
*--------------------------------------------------------------------*
* Program code: atm_pension_fund
* Program name: Atomic Pension Fund
* Created by:
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH fmc_secu AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_securities') }}
),

src AS (
    SELECT
        id
        , sec_id
        , business_cert_no
        , item_name
        , name_en
        , short_name
        , custodian_bank_id
        , supervisor_bank_id
        , status_id
        , note
    FROM {{ ref('ods_fms_pension_fund') }}
),

stat AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_PENSION_FUND', "src.id") }}                AS pension_fund_id
    , CAST(src.id AS string)                                                         AS pension_fund_code
    , CAST('FMS_PENSION_FUND' AS string)                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "fmc_secu.code") }}         AS fmc_id
    , CAST(fmc_secu.code AS string)                                                  AS fmc_code
    , CAST(src.business_cert_no AS string)                                           AS business_certificate_nbr
    , CAST(src.item_name AS string)                                                  AS pension_fund_full_nm
    , CAST(src.name_en AS string)                                                    AS pension_fund_english_nm
    , CAST(src.short_name AS string)                                                 AS pension_fund_short_nm
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "src.custodian_bank_id") }}  AS custodian_bank_id
    , CAST(src.custodian_bank_id AS string)                                          AS custodian_bank_code
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "src.supervisor_bank_id") }} AS supervisor_bank_id
    , CAST(src.supervisor_bank_id AS string)                                         AS supervisor_bank_code
    , {{ generate_surrogate_key_bigint('FMS_STATUS', "stat.code") }}                 AS cl_fms_status_id
    , CAST(stat.code AS string)                                                      AS cl_fms_status_code
    , CAST(src.note AS string)                                                       AS note
FROM src
    LEFT JOIN stat ON src.status_id = stat.id
    LEFT JOIN fmc_secu ON src.sec_id = fmc_secu.id

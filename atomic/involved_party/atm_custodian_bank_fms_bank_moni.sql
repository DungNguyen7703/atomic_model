/*
*--------------------------------------------------------------------*
* Program code: atm_custodian_bank
* Program name: Atomic Custodian Bank FMS.BANK_MONI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , status_id
        , item_name
        , en_name
        , short_name
        , bank_code
        , note
        , record_type
        , voucher_no
        , dec_date
        , des_change
    FROM {{ ref('ods_fms_bank_moni') }}
),

stat AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "ba_mo.id") }} AS custodian_bank_id
    , CAST(ba_mo.id AS string)                                       AS custodian_bank_code
    , CAST('FMS_BANK_MONI' AS string)                                AS src_stm_code
    , CAST(NULL AS string)                                           AS cl_fims_status_id
    , CAST(NULL AS string)                                           AS cl_fims_status_code
    , CAST(ba_mo.item_name AS string)                                AS custodian_bank_full_nm
    , CAST(ba_mo.en_name AS string)                                  AS custodian_bank_english_nm
    , CAST(ba_mo.short_name AS string)                               AS custodian_bank_short_nm
    , CAST(NULL AS string)                                           AS nationality_id
    , CAST(NULL AS string)                                           AS nationality_code
    , CAST(NULL AS decimal(23,2))                                    AS charter_capital_amt
    , CAST(NULL AS string)                                           AS director_full_nm
    , CAST(NULL AS string)                                           AS description
    , {{ generate_surrogate_key_bigint('FMS_STATUS', "stat.code") }} AS cl_fms_status_id
    , CAST(stat.code AS string)                                      AS cl_fms_status_code
    , CAST(ba_mo.bank_code AS string)                                AS bank_swift_code
    , CAST(ba_mo.note AS string)                                     AS note
    , CAST(ba_mo.record_type AS string)                              AS record_cl_text
    , CAST(ba_mo.voucher_no AS string)                               AS amendment_document_nbr
    , CAST(ba_mo.dec_date AS date)                                   AS decision_issue_dt
    , CAST(ba_mo.des_change AS string)                               AS change_description
FROM ba_mo
    LEFT JOIN stat ON ba_mo.STATUS_ID = stat.ID
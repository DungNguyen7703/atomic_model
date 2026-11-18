/*
*--------------------------------------------------------------------*
* Program code: atm_custodian_bank
* Program name: Atomic Custodian Bank FIMS.BANKMONI
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
        , statusid
        , name
        , ename
        , shortname
        , naid
        , capital
        , director
        , description
    FROM {{ ref('ods_fims_bankmoni') }}
),

stat AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fims_status') }}
),

nati AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fims_national') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_BANKMONI', "ba_mo.id") }}    AS custodian_bank_id
    , CAST(ba_mo.id AS string)                                          AS custodian_bank_code
    , CAST('FIMS_BANKMONI' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('FIMS_STATUS', "stat.code") }}   AS cl_fims_status_id
    , CAST(stat.code AS string)                                         AS cl_fims_status_code
    , CAST(ba_mo.name AS string)                                        AS custodian_bank_full_nm
    , CAST(ba_mo.ename AS string)                                       AS custodian_bank_english_nm
    , CAST(ba_mo.shortname AS string)                                   AS custodian_bank_short_nm
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }} AS nationality_id
    , CAST(nati.sname AS string)                                        AS nationality_code
    , CAST(ba_mo.capital AS decimal(23,2))                              AS charter_capital_amt
    , CAST(ba_mo.director AS string)                                    AS director_full_nm
    , CAST(ba_mo.description AS string)                                 AS description
    , CAST(NULL AS string)                                              AS cl_fms_status_id
    , CAST(NULL AS string)                                              AS cl_fms_status_code
    , CAST(NULL AS string)                                              AS bank_swift_code
    , CAST(NULL AS string)                                              AS note
    , CAST(NULL AS string)                                              AS record_cl_text
    , CAST(NULL AS string)                                              AS amendment_document_nbr
    , CAST(NULL AS date)                                                AS decision_issue_dt
    , CAST(NULL AS string)                                              AS change_description
FROM ba_mo
    LEFT JOIN stat ON ba_mo.StatusId = stat.Id
    LEFT JOIN nati ON ba_mo.NaId = nati.Id
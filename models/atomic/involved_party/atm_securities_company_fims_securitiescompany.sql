/*
*--------------------------------------------------------------------*
* Program code: atm_securities_company
* Program name: Atomic Securities Company FIMS.SECURITIESCOMPANY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH se_co AS (
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
    FROM {{ ref('ods_fims_securitiescompany') }}
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
    {{ generate_surrogate_key_bigint('FIMS_SECURITIESCOMPANY', "se_co.id") }} AS sc_id
    , CAST(se_co.id AS string)                                                AS sc_code
    , CAST('FIMS_SECURITIESCOMPANY' AS string)                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('FIMS_STATUS', "stat.code") }}         AS cl_fims_status_id
    , CAST(stat.code AS string)                                               AS cl_fims_status_code
    , CAST(se_co.name AS string)                                              AS sc_nm
    , CAST(se_co.ename AS string)                                             AS sc_english_nm
    , CAST(se_co.shortname AS string)                                         AS sc_short_nm
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }}       AS nationality_id
    , CAST(nati.sname AS string)                                              AS nationality_code
    , CAST(se_co.capital AS decimal(23,2))                                    AS charter_capital_amt
    , CAST(se_co.director AS string)                                          AS director_full_nm
    , CAST(se_co.description AS string)                                       AS description
    , CAST(NULL AS string)                                                    AS parent_sc_id
    , CAST(NULL AS string)                                                    AS parent_sc_code
    , CAST(NULL AS string)                                                    AS company_tp_code
    , CAST(NULL AS string)                                                    AS cl_sc_firm_status_id
    , CAST(NULL AS string)                                                    AS cl_sc_firm_status_code
    , CAST(NULL AS string)                                                    AS cl_sc_event_tp_id
    , CAST(NULL AS string)                                                    AS cl_sc_event_tp_code
    , CAST(NULL AS string)                                                    AS fr_tp_code
    , CAST(NULL AS string)                                                    AS foundation_license_file_path
    , CAST(NULL AS string)                                                    AS termination_decision_nbr
    , CAST(NULL AS decimal(23,2))                                             AS total_shares
    , CAST(NULL AS string)                                                    AS business_lines
    , CAST(NULL AS string)                                                    AS additional_business_lines
    , CAST(NULL AS int)                                                       AS listed_ind
    , CAST(NULL AS int)                                                       AS trading_registered_ind
    , CAST(NULL AS string)                                                    AS exchange_code
    , CAST(NULL AS string)                                                    AS securities_code
    , CAST(NULL AS date)                                                      AS listing_dt
    , CAST(NULL AS date)                                                      AS registration_dt
    , CAST(NULL AS date)                                                      AS official_operation_dt
    , CAST(NULL AS string)                                                    AS fiscal_year_end_dt
    , CAST(NULL AS string)                                                    AS electronic_trading_status_code
    , CAST(NULL AS string)                                                    AS electronic_trading_decision_nbr
    , CAST(NULL AS date)                                                      AS electronic_trading_decision_dt
    , CAST(NULL AS string)                                                    AS electronic_trading_reason
    , CAST(NULL AS int)                                                       AS pc_ind
    , CAST(NULL AS date)                                                      AS pc_registration_dt
    , CAST(NULL AS string)                                                    AS pc_decision_nbr
    , CAST(NULL AS date)                                                      AS pc_end_dt
    , CAST(NULL AS string)                                                    AS pc_end_decision_nbr
    , CAST(NULL AS string)                                                    AS custodian_member_code
    , CAST(NULL AS string)                                                    AS custodian_membership_revocation_decision
    , CAST(NULL AS date)                                                      AS custodian_membership_revocation_dt
    , CAST(NULL AS decimal(5,2))                                              AS foreign_investor_ownership_limit_rate
    , CAST(NULL AS date)                                                      AS ownership_limit_from_dt
    , CAST(NULL AS date)                                                      AS ownership_limit_to_dt
    , CAST(NULL AS int)                                                       AS amendment_declaration_ind
    , CAST(NULL AS string)                                                    AS amendment_document_nbr
    , CAST(NULL AS date)                                                      AS amendment_document_dt
    , CAST(NULL AS date)                                                      AS amendment_effective_dt
    , CAST(NULL AS date)                                                      AS amendment_expiry_dt
    , CAST(NULL AS string)                                                    AS amendment_document_file_path
    , CAST(NULL AS int)                                                       AS provisional_ind
    , CAST(NULL AS int)                                                       AS synced_from_admin_process_ind
    , CAST(NULL AS string)                                                    AS attachment_path
    , CAST(NULL AS string)                                                    AS note
    , CAST(NULL AS bigint) as added_sc_id
FROM se_co
    LEFT JOIN stat ON se_co.StatusId = stat.Id
    LEFT JOIN nati ON se_co.NaId = nati.Id
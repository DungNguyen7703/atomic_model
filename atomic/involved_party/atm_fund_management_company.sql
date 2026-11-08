/*
*--------------------------------------------------------------------*
* Program code: atm_fund_management_company
* Program name: Atomic Fund Management Company
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH secu AS (
    SELECT
        id
        , code
        , status_id
        , item_name
        , tname
        , ename
        , short_name
        , capital
        , total_qtty
        , business_type
        , borf_flag
        , insider_id
        , description
        , stock_code
        , market
        , national
        , bank_id
        , fr_date
        , to_date
        , stop_date
        , active_date
        , record_type
        , pepresent_ative
        , org_name
        , tr_code
        , listed
        , public_listed
        , reg_date
        , fin_date
        , dec_date
        , voucher_no
        , direc_name
        , deput_name
        , des_change
        , foreign_type
        , org_national
        , org_id_no
        , real_business_type
        , par_id
        , real_active_date
        , ct_id
        , event_type_id
    FROM {{ ref('ods_fms_securities') }}
),

co_ty AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_company_type') }}
),

stat AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_fms_status') }}
),

ev_ty AS (
    SELECT
        id
        , event_code
    FROM {{ ref('ods_fms_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_SECURITIES', "secu.code") }}          AS fmc_id
    , CAST(secu.code AS string)                                                 AS fmc_code
    , CAST('FMS_SECURITIES' AS string)                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_STATUS', "stat.code") }}            AS cl_fms_status_id
    , CAST(stat.code AS string)                                                 AS cl_fms_status_code
    , CAST(secu.item_name AS string)                                            AS fmc_full_nm
    , CAST(secu.tname AS string)                                                AS fmc_trading_nm
    , CAST(secu.ename AS string)                                                AS fmc_english_nm
    , CAST(secu.short_name AS string)                                           AS fmc_short_nm
    , CAST(secu.capital AS decimal(23,2))                                       AS charter_capital_amt
    , CAST(secu.total_qtty AS bigint)                                           AS total_outstanding_unit_quantity
    , CAST(secu.business_type AS string)                                        AS business_tp_description
    , CAST(secu.borf_flag AS int)                                               AS organization_territory_ind
    , {{ generate_surrogate_key_bigint('FMS_INSIDER', "secu.insider_id") }}     AS fmc_insider_id
    , CAST(secu.insider_id AS string)                                           AS fmc_insider_code
    , CAST(secu.description AS string)                                          AS description
    , CAST(secu.stock_code AS string)                                           AS stock_ticker_code
    , CAST(secu.market AS string)                                               AS exchange_code
    , CAST(secu.national AS string)                                             AS country_of_registration_nm
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "secu.bank_id") }}      AS custodian_bank_id
    , CAST(secu.bank_id AS string)                                              AS custodian_bank_code
    , CAST(secu.fr_date AS date)                                                AS effective_start_dt
    , CAST(secu.to_date AS date)                                                AS effective_end_dt
    , CAST(secu.stop_date AS date)                                              AS suspension_dt
    , CAST(secu.active_date AS date)                                            AS operation_commencement_dt
    , CAST(secu.record_type AS string)                                          AS record_cl_text
    , CAST(secu.pepresent_ative AS int)                                         AS legal_representative_ind
    , CAST(secu.org_name AS string)                                             AS parent_organization_nm
    , CAST(secu.tr_code AS string)                                              AS internal_transaction_code
    , CAST(secu.listed AS string)                                               AS listing_description
    , CAST(secu.public_listed AS int)                                           AS public_listed_ind
    , CAST(secu.reg_date AS date)                                               AS registration_dt
    , CAST(secu.fin_date AS date)                                               AS financial_activity_end_dt
    , CAST(secu.dec_date AS date)                                               AS decision_issue_dt
    , CAST(secu.voucher_no AS string)                                           AS amendment_document_nbr
    , CAST(secu.direc_name AS string)                                           AS director_full_nm
    , CAST(secu.deput_name AS string)                                           AS deputy_director_full_nm
    , CAST(secu.des_change AS string)                                           AS change_description
    , CAST(secu.foreign_type AS string)                                         AS foreign_organization_tp_description
    , CAST(secu.org_national AS string)                                         AS foreign_organization_country_nm
    , CAST(secu.org_id_no AS string)                                            AS foreign_organization_registration_nbr
    , CAST(secu.real_business_type AS string)                                   AS actual_business_tp_description
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "secu.par_id") }}      AS parent_fmc_id
    , CAST(secu.par_id AS string)                                               AS parent_fmc_code
    , CAST(secu.real_active_date AS date)                                       AS actual_operation_commencement_dt
    , {{ generate_surrogate_key_bigint('FMS_COMPANY_TYPE', "co_ty.code") }}     AS cl_fms_company_tp_id
    , CAST(co_ty.code AS string)                                                AS cl_fms_company_tp_code
    , {{ generate_surrogate_key_bigint('FMS_EVENT_TYPE', "ev_ty.event_code") }} AS cl_fms_event_tp_id
    , CAST(ev_ty.event_code AS string)                                          AS cl_fms_event_tp_code
FROM secu
    LEFT JOIN co_ty ON secu.ct_id = co_ty.id
    LEFT JOIN stat ON secu.status_id = stat.id
    LEFT JOIN ev_ty ON secu.event_type_id = ev_ty.id
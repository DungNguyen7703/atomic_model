/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_organization_unit
* Program name: Atomic Securities Company Foreign Organization Unit SCMS.SC_FIRM_FOREIGN_BRANCH
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_BRANCH.yaml (nguon con cua multi source, khoi phuc tu git 77a9749^ va doi chieu LLD).
*									Cot vat ly = HOP 2 LLD (27 cot, UNION ALL theo vi tri): 25 cot LLD + NULL padding validity_end_dt, operation_term_years (chi co o REP_OFFICE).
*									Khong noi kieu: ods allocated_capital decimal(20,0) <= LLD decimal(23,2); event_type_id bigint -> string.
* 2026-11-14		claude		[Fix] cl_sc_event_tp_id = hash(SCMS_CAT_EVENT_TYPE, EVENT_TYPE_CODE) theo LLD/DM moi; cl_sc_event_tp_code = CAT_EVENT_TYPE.EVENT_TYPE_CODE lay qua join ods_scms_cat_event_type (event_type_id = id)
*--------------------------------------------------------------------*
*/

WITH ca_ev_ty AS (
    SELECT
        id AS ca_ev_ty_id
        , event_type_code AS ca_ev_ty_code
    FROM {{ ref('ods_scms_cat_event_type') }}
),

sc_fo_br AS (
    SELECT
        id
        , sc_firm_info_id
        , branch_name
        , name_en
        , short_name
        , record_status
        , event_type_id
        , allocated_capital
        , financial_report_type
        , fiscal_year_end_date
        , official_operation_date
        , enterprise_code
        , parent_company_name
        , parent_company_license_number
        , parent_company_license_date
        , parent_company_address
        , country
        , note
    FROM {{ ref('ods_scms_sc_firm_foreign_branch') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_sc_fi_st AS (
    SELECT
        id
        , sc_firm_status_code
    FROM {{ ref('ods_scms_cat_sc_firm_status') }}
),

ca_na AS (
    SELECT
        id
        , nationality_code
    FROM {{ ref('ods_scms_cat_nationality') }}
),

ca_ev_ty AS (
    SELECT
        id
        , event_type_code
    FROM {{ ref('ods_scms_cat_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_BRANCH', "sc_fo_br.id") }}                     AS sc_foreign_ou_id
    , CAST(sc_fo_br.id AS string)                                                                         AS sc_foreign_ou_code
    , CAST('SCMS_SC_FIRM_FOREIGN_BRANCH' AS string)                                                       AS src_stm_code
    , CAST('FOREIGN_BRANCH' AS string)                                                                    AS ou_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                           AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                       AS sc_code
    , CAST(sc_fo_br.branch_name AS string)                                                                AS ou_nm
    , CAST(sc_fo_br.name_en AS string)                                                                    AS ou_english_nm
    , CAST(sc_fo_br.short_name AS string)                                                                 AS ou_short_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }}   AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                     AS cl_sc_firm_status_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }}              AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                                            AS cl_sc_event_tp_code
    , CAST(sc_fo_br.allocated_capital AS decimal(23,2))                                                   AS allocated_capital_amt
    , CAST(sc_fo_br.financial_report_type AS string)                                                      AS fr_tp_code
    , CAST(sc_fo_br.fiscal_year_end_date AS string)                                                       AS fiscal_year_end_dt
    , CAST(sc_fo_br.official_operation_date AS date)                                                      AS official_operation_dt
    , CAST(NULL AS date)                                                                                  AS validity_end_dt
    , CAST(NULL AS int)                                                                                   AS operation_term_years
    , CAST(sc_fo_br.enterprise_code AS string)                                                            AS enterprise_code
    , CAST(sc_fo_br.parent_company_name AS string)                                                        AS parent_company_nm
    , CAST(sc_fo_br.parent_company_license_number AS string)                                              AS parent_company_license_nbr
    , CAST(sc_fo_br.parent_company_license_date AS date)                                                  AS parent_company_license_dt
    , CAST(sc_fo_br.parent_company_address AS string)                                                     AS parent_company_adr
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                       AS country_id
    , CAST(ca_na.nationality_code AS string)                                                              AS country_code
    , CAST(sc_fo_br.note AS string)                                                                       AS note
FROM sc_fo_br
    LEFT JOIN sc_fi_in ON sc_fo_br.sc_firm_info_id = sc_fi_in.id
    LEFT JOIN ca_sc_fi_st ON CAST(sc_fo_br.record_status AS string) = CAST(ca_sc_fi_st.id AS string)
    LEFT JOIN ca_na ON CAST(sc_fo_br.country AS string) = CAST(ca_na.id AS string)
    LEFT JOIN ca_ev_ty ON sc_fo_br.event_type_id = ca_ev_ty.id

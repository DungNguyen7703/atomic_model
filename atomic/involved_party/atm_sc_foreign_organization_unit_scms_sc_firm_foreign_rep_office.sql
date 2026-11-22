/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_organization_unit
* Program name: Atomic Securities Company Foreign Organization Unit SCMS.SC_FIRM_FOREIGN_REP_OFFICE
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE.yaml (nguon con cua multi source, khoi phuc tu git 77a9749^ va doi chieu LLD).
*									Cot vat ly = HOP 2 LLD (27 cot, UNION ALL theo vi tri): 21 cot LLD + NULL padding ou_english_nm, ou_short_nm, allocated_capital_amt, fr_tp_code, fiscal_year_end_dt, enterprise_code (chi co o BRANCH).
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

sc_fo_re_of AS (
    SELECT
        id
        , sc_firm_info_id
        , rep_office_name
        , rep_office_status_id
        , event_type_id
        , official_operation_date
        , expiry_date
        , operation_term_years
        , parent_company_name
        , parent_company_license
        , parent_license_date
        , parent_hq_address
        , country
        , note
    FROM {{ ref('ods_scms_sc_firm_foreign_rep_office') }}
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
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "sc_fo_re_of.id") }}              AS sc_foreign_ou_id
    , CAST(sc_fo_re_of.id AS string)                                                                      AS sc_foreign_ou_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE' AS string)                                                   AS src_stm_code
    , CAST('FOREIGN_REP_OFFICE' AS string)                                                                AS ou_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                           AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                       AS sc_code
    , CAST(sc_fo_re_of.rep_office_name AS string)                                                         AS ou_nm
    , CAST(NULL AS string)                                                                                AS ou_english_nm
    , CAST(NULL AS string)                                                                                AS ou_short_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }}   AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                     AS cl_sc_firm_status_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "ca_ev_ty.event_type_code") }}              AS cl_sc_event_tp_id
    , CAST(ca_ev_ty.event_type_code AS string)                                                            AS cl_sc_event_tp_code
    , CAST(NULL AS decimal(23,2))                                                                         AS allocated_capital_amt
    , CAST(NULL AS string)                                                                                AS fr_tp_code
    , CAST(NULL AS string)                                                                                AS fiscal_year_end_dt
    , CAST(sc_fo_re_of.official_operation_date AS date)                                                   AS official_operation_dt
    , CAST(sc_fo_re_of.expiry_date AS date)                                                               AS validity_end_dt
    , CAST(sc_fo_re_of.operation_term_years AS int)                                                       AS operation_term_years
    , CAST(NULL AS string)                                                                                AS enterprise_code
    , CAST(sc_fo_re_of.parent_company_name AS string)                                                     AS parent_company_nm
    , CAST(sc_fo_re_of.parent_company_license AS string)                                                  AS parent_company_license_nbr
    , CAST(sc_fo_re_of.parent_license_date AS date)                                                       AS parent_company_license_dt
    , CAST(sc_fo_re_of.parent_hq_address AS string)                                                       AS parent_company_adr
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                       AS country_id
    , CAST(ca_na.nationality_code AS string)                                                              AS country_code
    , CAST(sc_fo_re_of.note AS string)                                                                    AS note
FROM sc_fo_re_of
    LEFT JOIN sc_fi_in ON sc_fo_re_of.sc_firm_info_id = sc_fi_in.id
    LEFT JOIN ca_sc_fi_st ON CAST(sc_fo_re_of.rep_office_status_id AS string) = CAST(ca_sc_fi_st.id AS string)
    LEFT JOIN ca_na ON CAST(sc_fo_re_of.country AS string) = CAST(ca_na.id AS string)
    LEFT JOIN ca_ev_ty ON sc_fo_re_of.event_type_id = ca_ev_ty.id

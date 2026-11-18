/*
*--------------------------------------------------------------------*
* Program code: atm_cl_securities_company_firm_status
* Program name: Atomic Classification Securities Company Firm Status
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ca_sc_fi_st AS (
    SELECT
        sc_firm_status_code
        , sc_firm_status_name
        , applicable_entity
        , report_submission_enabled
        , disclosure_enabled
        , description
        , note
        , code
        , item_name
    FROM {{ ref('ods_scms_cat_sc_firm_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "ca_sc_fi_st.sc_firm_status_code") }} AS cl_sc_firm_status_id
    , CAST(ca_sc_fi_st.sc_firm_status_code AS string)                                                 AS cl_sc_firm_status_code
    , CAST('SCMS_CAT_SC_FIRM_STATUS' AS string)                                                       AS src_stm_code
    , CAST(ca_sc_fi_st.sc_firm_status_name AS string)                                                 AS cl_sc_firm_status_nm
    , CAST(ca_sc_fi_st.applicable_entity AS string)                                                   AS applicable_entity
    , CAST(ca_sc_fi_st.report_submission_enabled AS int)                                              AS rpt_submission_required_ind
    , CAST(ca_sc_fi_st.disclosure_enabled AS int)                                                     AS disclosure_required_ind
    , CAST(ca_sc_fi_st.description AS string)                                                         AS description
    , CAST(ca_sc_fi_st.note AS string)                                                                AS note
    , CAST(ca_sc_fi_st.code AS string)                                                                AS item_code
    , CAST(ca_sc_fi_st.item_name AS string)                                                           AS item_nm
FROM ca_sc_fi_st
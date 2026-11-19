/*
*--------------------------------------------------------------------*
* Program code: atm_sc_administrative_sanction
* Program name: Atomic Securities Company Administrative Sanction
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_ADMIN_SANCTION.yaml (13 cot, Relative/scd2); tham khao git 09f760f^ nhung bo record_status_code/content/attachment_path (khong co trong LLD/DM), sc_code = SC_FIRM_INFO.CODE (ban cu cast sc_firm_info_id), remediation_measures doc remedial_measure (ban cu bien_phap_khac_phuc khong con trong ODS)
* 2026-11-13		claude		[MOI] Noi kieu theo nguon: amt decimal(23,2)->decimal(38,0) (nguon NUMBER(38,0))
*--------------------------------------------------------------------*
*/

WITH sc_fi_ad_sa AS (
    SELECT
        id
        , sc_firm_info_id
        , form_type
        , amount
        , decision_content
        , decision_date
        , additional_penalty
        , additional_penalty_date
        , remedial_measure
        , processing_unit
    FROM {{ ref('ods_scms_sc_firm_admin_sanction') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_ADMIN_SANCTION', "sc_fi_ad_sa.id") }} AS sc_administrative_sanction_id
    , CAST(sc_fi_ad_sa.id AS string)                                                     AS sc_administrative_sanction_code
    , CAST('SCMS_SC_FIRM_ADMIN_SANCTION' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}          AS sc_id
    , CAST(sc_fi_in.code AS string)                                                      AS sc_code
    , CAST(sc_fi_ad_sa.form_type AS string)                                              AS sanction_form_tp_code
    , CAST(sc_fi_ad_sa.amount AS decimal(23,2))                                          AS amt
    , CAST(sc_fi_ad_sa.decision_content AS string)                                       AS decision_content
    , CAST(sc_fi_ad_sa.decision_date AS date)                                            AS decision_dt
    , CAST(sc_fi_ad_sa.additional_penalty AS string)                                     AS additional_penalty
    , CAST(sc_fi_ad_sa.additional_penalty_date AS date)                                  AS additional_penalty_dt
    , CAST(sc_fi_ad_sa.remedial_measure AS string)                                       AS remediation_measures
    , CAST(sc_fi_ad_sa.processing_unit AS string)                                        AS processing_unit
FROM sc_fi_ad_sa
    LEFT JOIN sc_fi_in ON sc_fi_ad_sa.sc_firm_info_id = sc_fi_in.id
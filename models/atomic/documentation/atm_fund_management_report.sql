/*
*--------------------------------------------------------------------*
* Program code: atm_fund_management_report
* Program name: Atomic Fund Management Report
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_RPT_TEMP.yaml)
*										report_type decimal -> int -> string; version decimal -> int (theo LLD)
*--------------------------------------------------------------------*
*/

WITH rp_te AS (
    SELECT
        id
        , item_name
        , legal_basis
        , report_type
        , require_disclosure
        , description
        , version
        , ftype_id
        , report_group
        , system_objects
        , code
        , audit_report
        , check_price_setting
        , date_used
    FROM {{ ref('ods_fms_rpt_temp') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_RPT_TEMP', "rp_te.id") }}          AS fmr_id
    , CAST(rp_te.id AS string)                                               AS fmr_code
    , CAST('FMS_RPT_TEMP' AS string)                                         AS src_stm_code
    , CAST(rp_te.item_name AS string)                                        AS fmr_nm
    , CAST(rp_te.legal_basis AS string)                                      AS legal_basis
    , CAST(CAST(rp_te.report_type AS int) AS string)                         AS fmr_tp_code
    , CAST(rp_te.require_disclosure AS int)                                  AS disclosure_required_ind
    , CAST(rp_te.description AS string)                                      AS description
    , CAST(rp_te.version AS int)                                             AS version_nbr
    , {{ generate_surrogate_key_bigint('FMS_FUND_TYPE', "rp_te.ftype_id") }} AS cl_fms_fund_tp_id
    , CAST(rp_te.ftype_id AS string)                                         AS cl_fms_fund_tp_code
    , CAST(rp_te.report_group AS string)                                     AS rpt_group_code
    , CAST(rp_te.system_objects AS string)                                   AS stm_object_tp_code
    , CAST(rp_te.code AS string)                                             AS rpt_short_code
    , CAST(rp_te.audit_report AS int)                                        AS audit_rpt_ind
    , CAST(rp_te.check_price_setting AS int)                                 AS price_check_setting_ind
    , CAST(rp_te.date_used AS date)                                          AS usage_start_dt
FROM rp_te
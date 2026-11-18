/*
*--------------------------------------------------------------------*
* Program code: atm_cl_fms_status
* Program name: Atomic Classification FMS Status
* Created by:
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khoi tao theo LLD Atomic FMS UAT 20261006 (lld_FMS_STATUS.yaml)
*										PK hash theo CODE (khong theo ID) dung LLD; type_sec decimal -> int -> string
*--------------------------------------------------------------------*
*/

WITH stat AS (
    SELECT
        code
        , item_name
        , description
        , type_sec
        , submit_report
    FROM {{ ref('ods_fms_status') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_STATUS', "stat.code") }}         AS cl_fms_status_id
    , CAST(stat.code AS string)                                            AS cl_fms_status_code
    , CAST('FMS_STATUS' AS string)                                         AS src_stm_code
    , CAST(stat.item_name AS string)                                       AS cl_fms_status_nm
    , CAST(stat.description AS string)                                     AS description
    , CAST(CAST(stat.type_sec AS int) AS string)                           AS object_tp_code
    , CAST(stat.submit_report AS int)                                      AS rpt_submission_required_ind
FROM stat
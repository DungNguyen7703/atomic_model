/*
*--------------------------------------------------------------------*
* Program code: stg_fms_trs_fer_inder
* Program name: Staging FMS.TRS_FER_INDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                               AS id
    , CAST(date_created AS date)          AS date_created
    , CAST(created_by AS string)          AS created_by
    , CAST(date_modified AS date)         AS date_modified
    , CAST(modify_by AS string)           AS modify_by
    , HEX(sc_id)                          AS sc_id
    , HEX(in_frm_id)                      AS in_frm_id
    , HEX(in_to_id)                       AS in_to_id
    , CAST(id_no AS string)               AS id_no
    , CAST(insider_flag AS int)           AS insider_flag
    , CAST(curr_qtty AS decimal(18,2))    AS curr_qtty
    , CAST(curr_per AS decimal(18,2))     AS curr_per
    , CAST(af_qtty AS decimal(18,2))      AS af_qtty
    , CAST(af_per AS decimal(18,2))       AS af_per
    , CAST(curr_date AS date)             AS curr_date
    , CAST(co_curr_qtty AS decimal(18,2)) AS co_curr_qtty
    , CAST(co_curr_per AS decimal(18,2))  AS co_curr_per
    , CAST(co_curr_date AS date)          AS co_curr_date
    , CAST(co_af_qtty AS decimal(18,2))   AS co_af_qtty
    , CAST(co_af_per AS decimal(18,2))    AS co_af_per
    , CAST(trans_qtty AS decimal(18,2))   AS trans_qtty
    , CAST(per_date AS date)              AS per_date
    , CAST(per_cent AS decimal(18,2))     AS per_cent
    , CAST(deleted AS int)                AS deleted
    , CAST(file_name AS string)           AS file_name
    , CAST(file_data AS string)           AS file_data
    , CAST(data_migration AS int)         AS data_migration
    , CAST(gp_qd_no AS string)            AS gp_qd_no
    , CAST(approval_date AS date)         AS approval_date
FROM {{ source('source_fms', 'raw_trs_fer_inder') }}
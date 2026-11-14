/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_process
* Program name: Staging FMS.RPT_PROCESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , HEX(rp_mb_id)                 AS rp_mb_id
    , HEX(user_id)                  AS user_id
    , CAST(record_status AS bigint) AS record_status
    , CAST(rpt_cmt AS string)       AS rpt_cmt
    , CAST(date_change AS timestamp) AS date_change
    , CAST(file_import AS string)   AS file_import
    , CAST(description AS string)   AS description
FROM {{ source('source_fms', 'raw_rpt_process') }}
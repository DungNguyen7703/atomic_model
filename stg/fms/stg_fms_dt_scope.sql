/*
*--------------------------------------------------------------------*
* Program code: stg_fms_dt_scope
* Program name: Staging FMS.DT_SCOPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot); kieu decimal(38,0) sang int (1 cot); yml append/None -> snapshot/ds_snpst_dt theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS timestamp)    AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS timestamp)   AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(user_id)                       AS user_id
    , CAST(record_type AS int)           AS record_type
FROM {{ source('source_fms', 'raw_dt_scope') }}
/*
*--------------------------------------------------------------------*
* Program code: stg_fms_status
* Program name: Staging FMS.STATUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                           AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)      AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)       AS modify_by
    , CAST(item_name AS string)       AS item_name
    , CAST(type_sec AS decimal(18,2)) AS type_sec
    , CAST(active AS int)             AS active
    , CAST(submit_report AS int)      AS submit_report
    , CAST(description AS string)     AS description
    , CAST(icon AS string)            AS icon
    , CAST(color AS string)           AS color
    , CAST(deleted AS int)            AS deleted
    , CAST(code AS string)            AS code
FROM {{ source('source_fms', 'raw_status') }}
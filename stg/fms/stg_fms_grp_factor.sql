/*
*--------------------------------------------------------------------*
* Program code: stg_fms_grp_factor
* Program name: Staging FMS.GRP_FACTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot); kieu decimal(38,0) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)    AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)     AS modify_by
    , CAST(item_name AS string)     AS item_name
    , CAST(code AS string)          AS code
    , CAST(weight AS int)           AS weight
    , CAST(record_status AS int)    AS record_status
    , CAST(note AS string)          AS note
    , CAST(color AS string)         AS color
FROM {{ source('source_fms', 'raw_grp_factor') }}
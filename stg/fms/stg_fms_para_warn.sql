/*
*--------------------------------------------------------------------*
* Program code: stg_fms_para_warn
* Program name: Staging FMS.PARA_WARN
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)    AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)     AS modify_by
    , CAST(item_name AS string)     AS item_name
    , CAST(note AS string)          AS note
    , CAST(legal_code AS string)    AS legal_code
    , CAST(record_status AS int)    AS record_status
    , CAST(formula_info AS string)  AS formula_info
    , CAST(system_object AS bigint) AS system_object
FROM {{ source('source_fms', 'raw_para_warn') }}
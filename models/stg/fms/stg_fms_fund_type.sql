/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fund_type
* Program name: Staging FMS.FUND_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , CAST(record_status AS int)  AS record_status
    , CAST(item_name AS string)   AS item_name
    , CAST(description AS string) AS description
    , CAST(deleted AS int)        AS deleted
    , CAST(is_open_fund AS int)   AS is_open_fund
FROM {{ source('source_fms', 'raw_fund_type') }}
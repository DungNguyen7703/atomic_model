/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tl_pr_history
* Program name: Staging FMS.TL_PR_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                        AS id
    , HEX(tl_id)                   AS tl_id
    , CAST(date_change AS timestamp) AS date_change
    , CAST(action AS string)       AS action
    , CAST(item_name AS string)    AS item_name
    , CAST(id_no AS string)        AS id_no
    , CAST(prev_value AS string)   AS prev_value
    , CAST(value_change AS string) AS value_change
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)   AS created_by
FROM {{ source('source_fms', 'raw_tl_pr_history') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
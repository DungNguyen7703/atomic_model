/*
*--------------------------------------------------------------------*
* Program code: stg_fms_tp_out_htory
* Program name: Staging FMS.TP_OUT_HTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , HEX(tp_out_id)                 AS tp_out_id
    , CAST(action AS string)         AS action
    , CAST(version AS decimal(18,2)) AS version
    , CAST(downloaded AS int)        AS downloaded
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)     AS created_by
FROM {{ source('source_fms', 'raw_tp_out_htory') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
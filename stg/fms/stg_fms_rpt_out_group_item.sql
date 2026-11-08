/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_out_group_item
* Program name: Staging FMS.RPT_OUT_GROUP_ITEM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo FMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                     AS id
    , HEX(group_id)               AS group_id
    , HEX(rpt_out_id)             AS rpt_out_id
    , CAST(order_index AS bigint) AS order_index
FROM {{ source('source_fms', 'raw_rpt_out_group_item') }}
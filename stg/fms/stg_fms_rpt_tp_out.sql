/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_tp_out
* Program name: Staging FMS.RPT_TP_OUT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                            AS id
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(created_by AS string)       AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)        AS modify_by
    , HEX(sht_ot_id)                   AS sht_ot_id
    , CAST(item_name AS string)        AS item_name
    , CAST(legal_basis AS string)      AS legal_basis
    , CAST(record_status AS bigint)    AS record_status
    , CAST(description AS string)      AS description
    , CAST(deleted AS int)             AS deleted
    , CAST(report_group AS bigint)     AS report_group
    , CAST(system_object AS bigint)    AS system_object
    , CAST(code AS string)             AS code
    , CAST(stat_multi_period AS int)   AS stat_multi_period
    , CAST(search_multi_period AS int) AS search_multi_period
FROM {{ source('source_fms', 'raw_rpt_tp_out') }}
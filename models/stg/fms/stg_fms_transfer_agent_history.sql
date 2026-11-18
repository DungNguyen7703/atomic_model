/*
*--------------------------------------------------------------------*
* Program code: stg_fms_transfer_agent_history
* Program name: Staging FMS.TRANSFER_AGENT_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Theo design: update sang append: yml snapshot/ds_snpst_dt -> append/date_created; WHERE loc date_created = etl_date (giong cac bang *_history Append khac).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , HEX(transfer_agent_id)            AS transfer_agent_id
    , CAST(event_type AS string)        AS event_type
    , CAST(license_amend_no AS string)  AS license_amend_no
    , CAST(approval_date AS date)       AS approval_date
    , CAST(adjustment_reason AS string) AS adjustment_reason
    , CAST(note AS string)              AS note
    , CAST(change_detail AS string)     AS change_detail
    , CAST(date_created AS timestamp)   AS date_created
    , CAST(created_by AS string)        AS created_by
    , CAST(date_modified AS timestamp)  AS date_modified
    , CAST(modify_by AS string)         AS modify_by
FROM {{ source('source_fms', 'raw_transfer_agent_history') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
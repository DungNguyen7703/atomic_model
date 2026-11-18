/*
*--------------------------------------------------------------------*
* Program code: stg_fms_insider_chg_log
* Program name: Staging FMS.INSIDER_CHG_LOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                           AS id
    , HEX(insider_id)                 AS insider_id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)      AS created_by
    , CAST(modify_reason AS string)   AS modify_reason
    , CAST(change_summary AS string)  AS change_summary
    , CAST(event_type AS string)      AS event_type
    , CAST(prev_value AS string)      AS prev_value
    , CAST(value_change AS string)    AS value_change
    , CAST(gp_qd_no AS string)        AS gp_qd_no
    , CAST(approval_date AS date)     AS approval_date
    , CAST(snapshot_json AS string)   AS snapshot_json
FROM {{ source('source_fms', 'raw_insider_chg_log') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
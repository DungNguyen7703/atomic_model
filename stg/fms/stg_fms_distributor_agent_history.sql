/*
*--------------------------------------------------------------------*
* Program code: stg_fms_distributor_agent_history
* Program name: Staging FMS.DISTRIBUTOR_AGENT_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , HEX(distributor_agent_id)         AS distributor_agent_id
    , CAST(event_type AS string)        AS event_type
    , CAST(adjusted_cert_no AS string)  AS adjusted_cert_no
    , CAST(approval_date AS date)       AS approval_date
    , CAST(adjustment_reason AS string) AS adjustment_reason
    , CAST(change_detail AS string)     AS change_detail
    , CAST(date_created AS timestamp)   AS date_created
    , CAST(created_by AS string)        AS created_by
    , CAST(date_modified AS timestamp)  AS date_modified
    , CAST(modify_by AS string)         AS modify_by
    , CAST(snapshot_after AS string)    AS snapshot_after
FROM {{ source('source_fms', 'raw_distributor_agent_history') }}
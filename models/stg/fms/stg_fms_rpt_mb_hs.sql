/*
*--------------------------------------------------------------------*
* Program code: stg_fms_rpt_mb_hs
* Program name: Staging FMS.RPT_MB_HS
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
    , HEX(rpt_mb_id)                  AS rpt_mb_id
    , CAST(rpt_name AS string)        AS rpt_name
    , CAST(record_status AS bigint)   AS record_status
    , CAST(change_date AS date)       AS change_date
    , HEX(chg_by_id)                  AS chg_by_id
    , CAST(content_summary AS string) AS content_summary
    , CAST(file_data AS string)       AS file_data
    , CAST(note AS string)            AS note
FROM {{ source('source_fms', 'raw_rpt_mb_hs') }}
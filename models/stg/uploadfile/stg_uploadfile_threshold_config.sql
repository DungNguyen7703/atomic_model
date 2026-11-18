/*
*--------------------------------------------------------------------*
* Program code: stg_uploadfile_threshold_config
* Program name: Staging UBCK.THRESHOLD_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(indicator_code AS string)      AS indicator_code
    , CAST(indicator_name AS string)      AS indicator_name
    , CAST(value_from AS decimal(18,2))   AS value_from
    , CAST(value_to AS decimal(18,2))     AS value_to
    , CAST(status AS string)              AS status
    , CAST(effective_date AS date)        AS effective_date
    , CAST(end_date AS date)              AS end_date
    , CAST(record_status AS int)          AS record_status
    , CAST(created_at AS date)            AS created_at
    , CAST(createdby AS string)           AS createdby
    , CAST(upload_history_id AS string)   AS upload_history_id
FROM {{ source('source_uploadfile', 'raw_threshold_config') }}
where record_status = 1

/*
*--------------------------------------------------------------------*
* Program code: stg_uploadfile_weight_config
* Program name: Staging UBCK.WEIGHT_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(output_indicator_code AS string)   AS output_indicator_code
    , CAST(input_indicator_code AS string)    AS input_indicator_code
    , CAST(input_indicator_name AS string)    AS input_indicator_name
    , CAST(weight AS decimal(38,20))          AS weight
    , CAST(effective_date AS date)            AS effective_date
    , CAST(end_date AS date)                  AS end_date
    , CAST(record_status AS int)              AS record_status
    , CAST(created_at AS date)                AS created_at
    , CAST(createdby AS string)               AS createdby
    , CAST(upload_history_id AS string)       AS upload_history_id
FROM {{ source('source_uploadfile', 'raw_weight_config') }}

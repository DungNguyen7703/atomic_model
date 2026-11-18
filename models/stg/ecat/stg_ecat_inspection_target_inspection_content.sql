/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_inspection_target_inspection_content
* Program name: Staging ECAT.INSPECTION_TARGET_INSPECTION_CONTENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(inspection_target_id AS string)           AS inspection_target_id
    , CAST(inspection_content_id AS string)        AS inspection_content_id
    , CAST(inspection_target_stable_id AS string)  AS inspection_target_stable_id
    , CAST(inspection_content_stable_id AS string) AS inspection_content_stable_id
FROM {{ source('source_ecat', 'raw_inspection_target_inspection_content') }}
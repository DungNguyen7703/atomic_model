/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fms_indicator_catalog
* Program name: Staging FMS.FMS_INDICATOR_CATALOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                 AS id
    , CAST(indicator_code AS string)        AS indicator_code
    , CAST(indicator_name AS string)        AS indicator_name
    , CAST(description AS string)           AS description
    , CAST(status AS int)                   AS status
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(data_type AS string)             AS data_type
    , HEX(reference_catalog_id)             AS reference_catalog_id
    , CAST(created_by AS string)            AS created_by
    , CAST(updated_by AS string)            AS updated_by
    , CAST(reference_source_code AS string) AS reference_source_code
FROM {{ source('source_fms', 'raw_fms_indicator_catalog') }}
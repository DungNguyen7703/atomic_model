/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fms_reference_catalog
* Program name: Staging FMS.FMS_REFERENCE_CATALOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                         AS id
    , CAST(catalog_code AS string)  AS catalog_code
    , CAST(catalog_name AS string)  AS catalog_name
    , CAST(description AS string)   AS description
    , CAST(status AS int)           AS status
    , CAST(created_at AS timestamp) AS created_at
    , CAST(updated_at AS timestamp) AS updated_at
FROM {{ source('source_fms', 'raw_fms_reference_catalog') }}
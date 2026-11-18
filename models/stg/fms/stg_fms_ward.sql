/*
*--------------------------------------------------------------------*
* Program code: stg_fms_ward
* Program name: Staging FMS.WARD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(code AS string)                  AS code
    , CAST(name_vn AS string)               AS name_vn
    , CAST(name_en AS string)               AS name_en
    , CAST(category AS string)              AS category
    , CAST(effective AS string)             AS effective
    , CAST(display_label AS string)         AS display_label
    , CAST(active AS string)                AS active
    , CAST(province_id AS string)           AS province_id
    , CAST(province_code AS string)         AS province_code
    , CAST(province_name_vn AS string)      AS province_name_vn
    , CAST(deleted AS int)                  AS deleted
    , CAST(last_synced_at AS timestamp)     AS last_synced_at
    , CAST(date_created AS timestamp)       AS date_created
    , CAST(created_by AS string)            AS created_by
    , CAST(date_modified AS timestamp)      AS date_modified
    , CAST(modify_by AS string)             AS modify_by
FROM {{ source('source_fms', 'raw_ward') }}

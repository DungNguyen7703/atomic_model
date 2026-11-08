/*
*--------------------------------------------------------------------*
* Program code: stg_fms_province
* Program name: Staging FMS.PROVINCE
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
    , CAST(effective AS string)             AS effective
    , CAST(display_label AS string)         AS display_label
    , CAST(active AS string)                AS active
    , CAST(region_id AS string)             AS region_id
    , CAST(region_name AS string)           AS region_name
    , CAST(region_code AS string)           AS region_code
    , CAST(country_id AS string)            AS country_id
    , CAST(country_name_vn AS string)       AS country_name_vn
    , CAST(country_code AS string)          AS country_code
    , CAST(country_display_label AS string) AS country_display_label
    , CAST(deleted AS int)                  AS deleted
    , CAST(last_synced_at AS timestamp)     AS last_synced_at
    , CAST(date_created AS timestamp)       AS date_created
    , CAST(created_by AS string)            AS created_by
    , CAST(date_modified AS timestamp)      AS date_modified
    , CAST(modify_by AS string)             AS modify_by
    , CAST(stable_id AS string)             AS stable_id
FROM {{ source('source_fms', 'raw_province') }}
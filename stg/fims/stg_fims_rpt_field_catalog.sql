/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_field_catalog
* Program name: Staging FIMS.RPT_FIELD_CATALOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                       AS id
    , CAST(ma_chi_tieu AS string)            AS ma_chi_tieu
    , CAST(ten_chi_tieu AS string)           AS ten_chi_tieu
    , CAST(mo_ta AS string)                  AS mo_ta
    , CAST(data_type AS int)                 AS data_type
    , CAST(ref_value_catalog_id AS bigint)   AS ref_value_catalog_id
    , CAST(catalog_active AS int)            AS catalog_active
    , CAST(is_deleted AS int)                AS is_deleted
    , CAST(date_created AS timestamp)        AS date_created
    , CAST(date_modified AS timestamp)       AS date_modified
    , CAST(created_by AS string)             AS created_by
    , CAST(modify_by AS string)              AS modify_by
    , CAST(dropdown_option_source AS string) AS dropdown_option_source
    , CAST(dropdown_ref_source AS int)       AS dropdown_ref_source
FROM {{ source('source_fims', 'raw_rpt_field_catalog') }}
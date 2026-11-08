/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_value_catalog
* Program name: Staging FIMS.RPT_VALUE_CATALOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(ma AS string)               AS ma
    , CAST(ten AS string)              AS ten
    , CAST(catalog_active AS int)      AS catalog_active
    , CAST(is_deleted AS int)          AS is_deleted
    , CAST(date_created AS timestamp)  AS date_created
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(created_by AS string)       AS created_by
    , CAST(modify_by AS string)        AS modify_by
FROM {{ source('source_fims', 'raw_rpt_value_catalog') }}
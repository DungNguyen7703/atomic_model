/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_field_catalog_usage
* Program name: Staging FIMS.RPT_FIELD_CATALOG_USAGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(field_catalog_id AS bigint)     AS field_catalog_id
    , CAST(rpt_temp_id AS decimal(38,0)) AS rpt_temp_id
FROM {{ source('source_fims', 'raw_rpt_field_catalog_usage') }}
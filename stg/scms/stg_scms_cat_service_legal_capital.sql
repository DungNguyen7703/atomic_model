/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_service_legal_capital
* Program name: Staging SCMS.CAT_SERVICE_LEGAL_CAPITAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(service_id AS bigint)             AS service_id
    , CAST(service_name AS string)         AS service_name
    , CAST(record_status AS bigint)        AS record_status
    , CAST(legal_capital AS decimal(20,0)) AS legal_capital
    , CAST(description AS string)          AS description
    , CAST(catalog_type AS string)         AS catalog_type
    , CAST(catalog_code AS string)         AS catalog_code
    , CAST(application_type AS int)        AS application_type
FROM {{ source('source_scms', 'raw_cat_service_legal_capital') }}
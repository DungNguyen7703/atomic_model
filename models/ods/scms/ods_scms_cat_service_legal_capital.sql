/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_service_legal_capital
* Program name: ODS SCMS.CAT_SERVICE_LEGAL_CAPITAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    service_id
    , service_name
    , record_status
    , legal_capital
    , description
    , catalog_type
    , catalog_code
    , application_type
FROM {{ ref('stg_scms_cat_service_legal_capital') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
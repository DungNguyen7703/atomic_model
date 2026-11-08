/*
*--------------------------------------------------------------------*
* Program code: ods_fms_agen_funds
* Program name: ODS FMS.AGEN_FUNDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    agency_id
    , fund_id
    , data_migration
FROM {{ ref('stg_fms_agen_funds') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
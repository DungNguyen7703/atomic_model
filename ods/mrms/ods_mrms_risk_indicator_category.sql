/*
*--------------------------------------------------------------------*
* Program code: ods_mrms_risk_indicator_category
* Program name: ODS MRMS.RISK_INDICATOR_CATEGORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , set_code
    , category_code
    , category_name
    , status
    , created_at
    , updated_at
    , created_by_id
    , updated_by_id
    , created_by_name
    , updated_by_name
    , deleted
FROM {{ ref('stg_mrms_risk_indicator_category') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
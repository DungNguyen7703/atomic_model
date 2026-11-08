/*
*--------------------------------------------------------------------*
* Program code: ods_mrms_risk_indicator
* Program name: ODS MRMS.RISK_INDICATOR
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
    , indicator_code
    , indicator_name
    , set_code
    , category_id
    , unit_code
    , source_code
    , period_type
    , status
    , last_sync_time
    , display_order
    , created_at
    , updated_at
    , created_by_id
    , updated_by_id
    , created_by_name
    , updated_by_name
    , deleted
    , is_display
    , show_sync_indicator
FROM {{ ref('stg_mrms_risk_indicator') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
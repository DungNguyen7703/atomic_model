/*
*--------------------------------------------------------------------*
* Program code: ods_mrms_risk_indicator_value
* Program name: ODS MRMS.RISK_INDICATOR_VALUE
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
    , indicator_id
    , period_type
    , period_value
    , period_year
    , period_date
    , period_label
    , unit_code
    , source_code
    , data_origin
    , created_at
    , updated_at
    , created_by_id
    , updated_by_id
    , created_by_name
    , updated_by_name
    , deleted
    , cumulative_value
    , value
FROM {{ ref('stg_mrms_risk_indicator_value') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
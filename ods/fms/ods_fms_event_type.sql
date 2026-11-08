/*
*--------------------------------------------------------------------*
* Program code: ods_fms_event_type
* Program name: ODS FMS.EVENT_TYPE
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
    , category
    , item_name
    , record_status
    , description
    , note
    , metadata
    , deleted
    , date_created
    , created_by
    , date_modified
    , modify_by
    , event_code
    , event_category
    , obligation_type
    , deadline_calc_method
    , business_rule_config
FROM {{ ref('stg_fms_event_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
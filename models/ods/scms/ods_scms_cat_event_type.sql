/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_event_type
* Program name: ODS SCMS.CAT_EVENT_TYPE
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
    , event_type_code
    , event_type_name
    , note
    , created_by
    , created_at
    , record_status
    , requires_license
    , target_entity
    , requires_disclosure
    , obligation_type
    , event_group_id
    , cycle
    , frequency
    , cutoff_date
    , submission_method
    , effective_date
    , expiry_date
    , updated_at
    , updated_by
    , event_category
    , deadline_calculation_method
    , extended_data
FROM {{ ref('stg_scms_cat_event_type') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
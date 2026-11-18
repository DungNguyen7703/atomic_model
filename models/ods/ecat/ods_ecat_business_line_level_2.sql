/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_business_line_level_2
* Program name: ODS ECAT.BUSINESS_LINE_LEVEL_2
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
    , parent_line_id
    , code
    , name
    , effective
    , display_label
    , active
    , active_reason
    , deleted
    , deleted_reason
    , version
    , effective_start_date
    , effective_end_date
    , old_id
    , created_at
    , updated_at
    , created_by_id
    , created_by_name
    , updated_by_id
    , updated_by_name
    , stable_id
    , parent_line_version_id
FROM {{ ref('stg_ecat_business_line_level_2') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and effective = 1
and deleted = 0
and effective_end_date is null
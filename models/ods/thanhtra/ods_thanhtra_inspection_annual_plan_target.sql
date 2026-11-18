/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_inspection_annual_plan_target
* Program name: ODS THANHTRA.INSPECTION_ANNUAL_PLAN_TARGET
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
    , inspection_annual_plan_id
    , target_type
    , target_reference_id
    , target_name
    , target_code
    , target_source
    , planned_quarter
    , planned_content
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_inspection_annual_plan_target') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0
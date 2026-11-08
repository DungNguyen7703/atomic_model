/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_inspection_annual_plan
* Program name: ODS THANHTRA.INSPECTION_ANNUAL_PLAN
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
    , name
    , plan_year
    , decision_number
    , decision_date
    , status
    , note
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_inspection_annual_plan') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0
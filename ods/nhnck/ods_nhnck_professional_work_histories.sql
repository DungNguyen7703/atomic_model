/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_professional_work_histories
* Program name: ODS NHNCK.PROFESSIONAL_WORK_HISTORIES
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
    , organization_id
    , professional_id
    , unit_name
    , start_date
    , end_date
    , workplace
    , position_id
    , position_name
    , awards
    , disciplines
    , created_at
    , created_by
    , updated_at
    , updated_by
FROM {{ ref('stg_nhnck_professional_work_histories') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
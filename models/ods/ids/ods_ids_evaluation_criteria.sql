/*
*--------------------------------------------------------------------*
* Program code: ods_ids_evaluation_criteria
* Program name: ODS IDS.EVALUATION_CRITERIA
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
    , group_id
    , criterion_name
    , criterion_cd
    , description
    , subgroup_name
    , group_cd
    , basic_flg
    , display_order_group
    , display_order_subgroup
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_evaluation_criteria') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
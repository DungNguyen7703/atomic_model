/*
*--------------------------------------------------------------------*
* Program code: ods_ids_evaluation_groups
* Program name: ODS IDS.EVALUATION_GROUPS
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
    , group_name
    , description
    , weight
    , display_order
    , group_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_evaluation_groups') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
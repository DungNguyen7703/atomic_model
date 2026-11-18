/*
*--------------------------------------------------------------------*
* Program code: ods_ids_holder_relationship
* Program name: ODS IDS.HOLDER_RELATIONSHIP
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
    , relationship_type_cd
    , legal_entity_id
    , related_entity_id
    , effective_from_date
    , effective_to_date
    , active_flg
    , relationship_reason
    , remarks
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_holder_relationship') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
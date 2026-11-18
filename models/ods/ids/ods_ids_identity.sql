/*
*--------------------------------------------------------------------*
* Program code: ods_ids_identity
* Program name: ODS IDS.IDENTITY
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
    , legal_entity_id
    , identity_type_cd
    , identity_no
    , identity_issued_date
    , identity_issued_place
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
FROM {{ ref('stg_ids_identity') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
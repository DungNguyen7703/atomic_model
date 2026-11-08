/*
*--------------------------------------------------------------------*
* Program code: ods_ids_positions
* Program name: ODS IDS.POSITIONS
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
    , position_cd
    , appointment_date
    , dismissal_date
    , active_flg
    , legal_entity_id
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , company_profile_id
FROM {{ ref('stg_ids_positions') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
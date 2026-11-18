/*
*--------------------------------------------------------------------*
* Program code: ods_ids_foreign_owner_limit
* Program name: ODS IDS.FOREIGN_OWNER_LIMIT
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
    , company_profile_id
    , max_owner_rate
    , from_date
    , to_date
    , created_by
    , created_date
    , updated_by
    , updated_date
    , delete_flg
    , sync_flg
FROM {{ ref('stg_ids_foreign_owner_limit') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
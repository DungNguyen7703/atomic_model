/*
*--------------------------------------------------------------------*
* Program code: ods_fms_stake
* Program name: ODS FMS.STAKE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , security_id
    , item_name
    , relation_ship
    , capital
    , description
    , deleted
    , data_migration
    , owner_flag
    , id_no
    , period_type
    , period_value
    , year_value
FROM {{ ref('stg_fms_stake') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
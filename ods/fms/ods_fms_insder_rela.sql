/*
*--------------------------------------------------------------------*
* Program code: ods_fms_insder_rela
* Program name: ODS FMS.INSDER_RELA
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
    , insder_id
    , rela_id
    , item_name
    , id_no
    , id_date
    , id_place
    , deleted
    , address
    , description
    , data_migration
    , gp_qd_no
    , approval_date
FROM {{ ref('stg_fms_insder_rela') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
/*
*--------------------------------------------------------------------*
* Program code: ods_scms_sc_firm_ownership_relation
* Program name: ODS SCMS.SC_FIRM_OWNERSHIP_RELATION
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
    , sc_firm_info_id
    , registered_address
    , note
    , enterprise_type_id
    , relation_type
    , enterprise_code
    , last_modified_at
    , end_date
    , ownership_date
    , created_at
    , last_modified_by
    , created_by
    , country_id
    , company_name
    , ownership_ratio
    , deleted
FROM {{ ref('stg_scms_sc_firm_ownership_relation') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
/*
*--------------------------------------------------------------------*
* Program code: ods_fms_inspection_round
* Program name: ODS FMS.INSPECTION_ROUND
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
    , deleted
    , object_type
    , other_object_name
    , inspection_year
    , start_date
    , end_date
    , decision_no
    , decision_date
    , period_from
    , period_to
    , inspection_kind
    , date_created
    , created_by
    , date_modified
    , modify_by
    , data_source
    , thanh_tra_external_id
FROM {{ ref('stg_fms_inspection_round') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
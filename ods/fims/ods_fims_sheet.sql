/*
*--------------------------------------------------------------------*
* Program code: ods_fims_sheet
* Program name: ODS FIMS.SHEET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0 AND status = 1
*--------------------------------------------------------------------*
*/

SELECT
    id
    , deleted
    , datecreated
    , createdby
    , datemodified
    , modifyby
    , rptid
    , code
    , name
    , sheetindex
    , status
    , description
    , mergecells
    , cellsmeta
    , datalabel
    , colwidths
    , rowheights
    , qldmdt_situation_report
    , sectionsmeta
FROM {{ ref('stg_fims_sheet') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND status = 1
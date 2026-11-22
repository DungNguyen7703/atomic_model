/*
*--------------------------------------------------------------------*
* Program code: ods_fims_fundcompany
* Program name: ODS FIMS.FUNDCOMPANY
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
    , datecreated
    , createdby
    , datemodified
    , modifyby
    , name
    , ename
    , shortname
    , naid
    , address
    , telephone
    , fax
    , email
    , website
    , idno
    , iddate
    , idadd
    , regno
    , regdate
    , regadd
    , director
    , capital
    , statusid
    , depcert
    , description
    , filename
    , filedata
    , idold
    , isdatamigration
    , issynced
FROM {{ ref('stg_fims_fundcompany') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
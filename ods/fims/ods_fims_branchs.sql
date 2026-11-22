/*
*--------------------------------------------------------------------*
* Program code: ods_fims_branchs
* Program name: ODS FIMS.BRANCHS
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
    , statusid
    , idno
    , iddate
    , idadd
    , regno
    , regdate
    , regadd
    , codetax
    , capital
    , startdate
    , enddate
    , companynameparent
    , certnoparent
    , addparent
    , idnoparent
    , description
    , filename
    , filedata
    , idold
    , isdatamigration
    , issynced
    , contractcontent
    , operatingterm
    , term
FROM {{ ref('stg_fims_branchs') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
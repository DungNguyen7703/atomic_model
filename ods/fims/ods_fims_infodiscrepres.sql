/*
*--------------------------------------------------------------------*
* Program code: ods_fims_infodiscrepres
* Program name: ODS FIMS.INFODISCREPRES
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
    , objecttype
    , name
    , ename
    , shortname
    , statusid
    , sex
    , dateofbirth
    , naid
    , address
    , idno
    , iddate
    , idadd
    , certno
    , telephone
    , fax
    , email
    , website
    , description
    , filename
    , filedata
    , idold
    , isdatamigration
    , profilekind
    , representedinfodiscrepresid
    , naiddmdc
    , provinceid
    , wardid
FROM {{ ref('stg_fims_infodiscrepres') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
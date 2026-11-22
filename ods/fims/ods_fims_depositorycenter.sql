/*
*--------------------------------------------------------------------*
* Program code: ods_fims_depositorycenter
* Program name: ODS FIMS.DEPOSITORYCENTER
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
    , hotline
    , statusid
    , description
    , filename
    , filedata
    , idold
    , isdatamigration
    , taxcode
    , issynced
FROM {{ ref('stg_fims_depositorycenter') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
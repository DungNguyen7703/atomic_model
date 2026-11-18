/*
*--------------------------------------------------------------------*
* Program code: ods_fims_bankmoni
* Program name: ODS FIMS.BANKMONI
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
FROM {{ ref('stg_fims_bankmoni') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0
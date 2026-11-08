/*
*--------------------------------------------------------------------*
* Program code: ods_fims_securitiescompany
* Program name: ODS FIMS.SECURITIESCOMPANY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-17		tuan.nguyenvanb		[MOI] ODS FIMS.SECURITIESCOMPANY - nguon cua atm_securities_company_fims_securitiescompany. Cung pattern ods_fims_status.
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
FROM {{ ref('stg_fims_securitiescompany') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0

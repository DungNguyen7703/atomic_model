/*
*--------------------------------------------------------------------*
* Program code: ods_fims_tradingauthorization
* Program name: ODS FIMS.TRADINGAUTHORIZATION
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
    , systemobject
    , fundcomid
    , seccomid
    , investorid
    , authorizationtypeid
    , status
    , filedata
    , filename
    , sdate
    , edate
    , note
    , investorids
    , idold
    , deleted
    , datecreated
    , datemodified
    , createdby
    , modifyby
    , tradingrepresentativeid
FROM {{ ref('stg_fims_tradingauthorization') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
  AND status = 1
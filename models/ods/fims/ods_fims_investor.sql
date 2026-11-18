/*
*--------------------------------------------------------------------*
* Program code: ods_fims_investor
* Program name: ODS FIMS.INVESTOR
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
    , objecttype
    , transactioncode
    , name
    , ename
    , sex
    , dateofbirth
    , naid
    , address
    , idno
    , iddate
    , idadd
    , telephone
    , fax
    , email
    , website
    , businessnumber
    , director
    , investortypeid
    , depaccountnumber
    , sysobjecttype
    , seccomaddid
    , bankaddid
    , accountinvescapital
    , bankaddcapid
    , companytypeid
    , statusid
    , description
    , filename
    , filedata
    , idold
    , dmdc_country_id
    , provinceid
    , wardid
FROM {{ ref('stg_fims_investor') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0
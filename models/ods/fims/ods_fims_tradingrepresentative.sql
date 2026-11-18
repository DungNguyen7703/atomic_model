/*
*--------------------------------------------------------------------*
* Program code: ods_fims_tradingrepresentative
* Program name: ODS FIMS.TRADINGREPRESENTATIVE
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
    , fullname
    , sex
    , dateofbirth
    , idno
    , naid
    , address
    , telephone
    , email
    , fax
    , statusid
    , description
    , createdby
    , datecreated
    , modifyby
    , datemodified
    , deleted
    , provinceid
    , wardid
FROM {{ ref('stg_fims_tradingrepresentative') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
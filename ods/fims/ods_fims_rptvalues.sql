/*
*--------------------------------------------------------------------*
* Program code: ods_fims_rptvalues
* Program name: ODS FIMS.RPTVALUES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0
* 2026-11-12		ngoc.pham		Dong bo theo BRD moi (Append OR): WHERE loc theo data_dt, them cot data_dt cuoi SELECT, strategy=append, partition_by=["data_dt"]
*--------------------------------------------------------------------*
*/

SELECT
    id
    , deleted
    , datecreated
    , createdby
    , datemodified
    , modifyby
    , mebid
    , prdid
    , sheetid
    , rptid
    , tgtid
    , type
    , periodtype
    , periodvalue
    , yearvalue
    , values
    , code
    , formatdatatype
    , isdynamic
    , rowdynamic
    , tablename
    , fieldname
    , identification
    , fundid
    , secid
    , bankid
    , depid
    , stockid
    , inid
    , branid
    , data_dt
FROM {{ ref('stg_fims_rptvalues') }}
WHERE data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
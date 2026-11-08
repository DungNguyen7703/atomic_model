/*
*--------------------------------------------------------------------*
* Program code: ods_fims_companytype
* Program name: ODS FIMS.COMPANYTYPE
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
    , sname
    , typeobject
    , name
    , status
    , isdatamigration
    , description
    , idold
    , ecatalog_id
    , code
FROM {{ ref('stg_fims_companytype') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0
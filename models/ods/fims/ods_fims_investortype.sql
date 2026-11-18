/*
*--------------------------------------------------------------------*
* Program code: ods_fims_investortype
* Program name: ODS FIMS.INVESTORTYPE
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
    , name
    , status
    , isdatamigration
    , description
    , ecatalog_id
FROM {{ ref('stg_fims_investortype') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0
/*
*--------------------------------------------------------------------*
* Program code: ods_fims_national
* Program name: ODS FIMS.NATIONAL
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
    , description
    , isdatamigration
    , idold
    , idscmsold
    , ecatalog_id
FROM {{ ref('stg_fims_national') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0
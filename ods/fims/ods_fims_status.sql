/*
*--------------------------------------------------------------------*
* Program code: ods_fims_status
* Program name: ODS FIMS.STATUS
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
    , typeobject
    , isactive
    , issubmitreport
    , description
    , icon
    , color
    , idold
    , ecatalog_id
    , code
FROM {{ ref('stg_fims_status') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
and deleted = 0
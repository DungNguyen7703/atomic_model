/*
*--------------------------------------------------------------------*
* Program code: ods_fims_rptmember
* Program name: ODS FIMS.RPTMEMBER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0
*--------------------------------------------------------------------*
*/

SELECT
    id
    , deleted
    , datecreated
    , createdby
    , datemodified
    , modifyby
    , rptid
    , prdid
    , fundid
    , secid
    , bankid
    , depid
    , stockid
    , inid
    , branid
    , reporttypeid
    , objecttype
    , isimport
    , isworkingday
    , sendinday
    , rptname
    , yearvalue
    , periodvalue
    , dayreport
    , deadlinesend
    , status
    , datesubmitted
    , filedata
    , fileimport
    , datafileimport
    , contentsummary
    , note
    , periodtype
    , idold
    , isdatamigration
    , investorid
    , tradingrepresentativeid
    , rpt_event_type_id
    , rptversionatschedule
    , eformsubmissionjson
    , eformschemasnapshotjson
FROM {{ ref('stg_fims_rptmember') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
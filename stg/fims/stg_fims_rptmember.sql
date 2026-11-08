/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptmember
* Program name: Staging FIMS.RPTMEMBER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))                     AS id
    , CAST(deleted AS int)                        AS deleted
    , CAST(datecreated AS date)                   AS datecreated
    , CAST(createdby AS string)                   AS createdby
    , CAST(datemodified AS date)                  AS datemodified
    , CAST(modifyby AS string)                    AS modifyby
    , CAST(rptid AS decimal(18,2))                AS rptid
    , CAST(prdid AS decimal(18,2))                AS prdid
    , CAST(fundid AS decimal(18,2))               AS fundid
    , CAST(secid AS decimal(18,2))                AS secid
    , CAST(bankid AS decimal(18,2))               AS bankid
    , CAST(depid AS decimal(18,2))                AS depid
    , CAST(stockid AS decimal(18,2))              AS stockid
    , CAST(inid AS decimal(18,2))                 AS inid
    , CAST(branid AS decimal(18,2))               AS branid
    , CAST(reporttypeid AS decimal(18,2))         AS reporttypeid
    , CAST(objecttype AS decimal(18,2))           AS objecttype
    , CAST(isimport AS int)                       AS isimport
    , CAST(isworkingday AS int)                   AS isworkingday
    , CAST(sendinday AS decimal(18,2))            AS sendinday
    , CAST(rptname AS string)                     AS rptname
    , CAST(yearvalue AS decimal(18,2))            AS yearvalue
    , CAST(periodvalue AS string)                 AS periodvalue
    , CAST(dayreport AS date)                     AS dayreport
    , CAST(deadlinesend AS date)                  AS deadlinesend
    , CAST(status AS bigint)                      AS status
    , CAST(datesubmitted AS date)                 AS datesubmitted
    , CAST(filedata AS string)                    AS filedata
    , CAST(fileimport AS string)                  AS fileimport
    , CAST(datafileimport AS string)              AS datafileimport
    , CAST(contentsummary AS string)              AS contentsummary
    , CAST(note AS string)                        AS note
    , CAST(periodtype AS decimal(38,0))           AS periodtype
    , CAST(idold AS string)                       AS idold
    , CAST(isdatamigration AS int)                AS isdatamigration
    , CAST(investorid AS bigint)                  AS investorid
    , CAST(tradingrepresentativeid AS bigint)     AS tradingrepresentativeid
    , CAST(rpt_event_type_id AS bigint)           AS rpt_event_type_id
    , CAST(rptversionatschedule AS decimal(38,0)) AS rptversionatschedule
    , CAST(eformsubmissionjson AS string)         AS eformsubmissionjson
    , CAST(eformschemasnapshotjson AS string)     AS eformschemasnapshotjson
FROM {{ source('source_fims', 'raw_rptmember') }}
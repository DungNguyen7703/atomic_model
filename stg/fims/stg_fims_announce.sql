/*
*--------------------------------------------------------------------*
* Program code: stg_fims_announce
* Program name: Staging FIMS.ANNOUNCE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))               AS id
    , CAST(deleted AS int)                  AS deleted
    , CAST(datecreated AS date)             AS datecreated
    , CAST(createdby AS string)             AS createdby
    , CAST(datemodified AS date)            AS datemodified
    , CAST(modifyby AS string)              AS modifyby
    , CAST(inrepid AS decimal(18,2))        AS inrepid
    , CAST(yearvalue AS decimal(18,2))      AS yearvalue
    , CAST(periodvalue AS string)           AS periodvalue
    , CAST(periodtype AS decimal(18,2))     AS periodtype
    , CAST(announcetypeid AS decimal(18,2)) AS announcetypeid
    , CAST(name AS string)                  AS name
    , CAST(contentsummary AS string)        AS contentsummary
    , CAST(dateannounce AS timestamp)       AS dateannounce
    , CAST(description AS string)           AS description
    , CAST(filename AS string)              AS filename
    , CAST(filedata AS string)              AS filedata
    , CAST(status AS decimal(18,2))         AS status
    , CAST(sendannounceby AS string)        AS sendannounceby
    , CAST(investordata AS string)          AS investordata
    , CAST(investordataname AS string)      AS investordataname
    , CAST(systemobject AS bigint)          AS systemobject
    , CAST(fundcomid AS bigint)             AS fundcomid
    , CAST(seccomid AS bigint)              AS seccomid
    , CAST(bankid AS bigint)                AS bankid
    , CAST(depcenid AS bigint)              AS depcenid
    , CAST(stockcenid AS bigint)            AS stockcenid
    , CAST(branchsid AS bigint)             AS branchsid
    , CAST(investorid AS bigint)            AS investorid
    , CAST(rptmemberid AS bigint)           AS rptmemberid
    , CAST(incidentmattertype AS bigint)    AS incidentmattertype
    , CAST(rpt_event_type_id AS bigint)     AS rpt_event_type_id
    , CAST('EformSubmissionJson' AS string) AS eformsubmissionjson
FROM {{ source('source_fims', 'raw_announce') }}
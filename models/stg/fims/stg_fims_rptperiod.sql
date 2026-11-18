/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptperiod
* Program name: Staging FIMS.RPTPERIOD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))           AS id
    , CAST(deleted AS int)              AS deleted
    , CAST(datecreated AS date)         AS datecreated
    , CAST(createdby AS string)         AS createdby
    , CAST(datemodified AS date)        AS datemodified
    , CAST(modifyby AS string)          AS modifyby
    , CAST(rptid AS decimal(18,2))      AS rptid
    , CAST(sfpdid AS decimal(18,2))     AS sfpdid
    , CAST(periodtype AS decimal(18,2)) AS periodtype
    , CAST(latestsenddate AS timestamp) AS latestsenddate
    , CAST(repeattime AS bigint)        AS repeattime
    , CAST(latestsendweek AS bigint)    AS latestsendweek
    , CAST(datestartcount AS timestamp) AS datestartcount
    , CAST(isworkingday AS int)         AS isworkingday
    , CAST(sendinday AS bigint)         AS sendinday
    , CAST(status AS int)               AS status
    , CAST(description AS string)       AS description
    , CAST(filename AS string)          AS filename
    , CAST(sendpublicinday AS bigint)   AS sendpublicinday
FROM {{ source('source_fims', 'raw_rptperiod') }}
/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptprocess
* Program name: Staging FIMS.RPTPROCESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))        AS id
    , CAST(rpmbid AS decimal(18,2))  AS rpmbid
    , CAST(userid AS decimal(18,2))  AS userid
    , CAST(status AS bigint)         AS status
    , CAST(comment AS string)        AS comment
    , CAST(description AS string)    AS description
    , CAST(datechange AS date)       AS datechange
    , CAST(filedata AS string)       AS filedata
    , CAST(fileimport AS string)     AS fileimport
    , CAST(datafileimport AS string) AS datafileimport
FROM {{ source('source_fims', 'raw_rptprocess') }}
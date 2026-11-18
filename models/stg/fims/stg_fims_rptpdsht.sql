/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rptpdsht
* Program name: Staging FIMS.RPTPDSHT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(shtid AS decimal(18,2))     AS shtid
    , CAST(rptpdid AS decimal(18,2)) AS rptpdid
    , CAST(deleted AS int)           AS deleted
    , CAST(datecreated AS date)      AS datecreated
    , CAST(createdby AS string)      AS createdby
    , CAST(datemodified AS date)     AS datemodified
    , CAST(modifyby AS string)       AS modifyby
FROM {{ source('source_fims', 'raw_rptpdsht') }}
/*
*--------------------------------------------------------------------*
* Program code: stg_fims_selfsetpd
* Program name: Staging FIMS.SELFSETPD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))             AS id
    , CAST(deleted AS int)                AS deleted
    , CAST(datecreated AS date)           AS datecreated
    , CAST(createdby AS string)           AS createdby
    , CAST(datemodified AS date)          AS datemodified
    , CAST(modifyby AS string)            AS modifyby
    , CAST(rptid AS decimal(18,2))        AS rptid
    , CAST(issend AS int)                 AS issend
    , CAST(systemobject AS decimal(18,2)) AS systemobject
    , CAST(lstmember AS string)           AS lstmember
    , CAST(bc_su_vu_id AS bigint)         AS bc_su_vu_id
FROM {{ source('source_fims', 'raw_selfsetpd') }}
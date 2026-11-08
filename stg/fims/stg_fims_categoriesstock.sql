/*
*--------------------------------------------------------------------*
* Program code: stg_fims_categoriesstock
* Program name: Staging FIMS.CATEGORIESSTOCK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                AS id
    , CAST(invesid AS bigint)         AS invesid
    , CAST(secid AS string)           AS secid
    , CAST(quantity AS bigint)        AS quantity
    , CAST(deleted AS int)            AS deleted
    , CAST(datecreated AS timestamp)  AS datecreated
    , CAST(datemodified AS timestamp) AS datemodified
    , CAST(createdby AS string)       AS createdby
    , CAST(modifyby AS string)        AS modifyby
    , CAST(rate AS decimal(18,6))     AS rate
    , CAST(issynced AS int)           AS issynced
FROM {{ source('source_fims', 'raw_categoriesstock') }}
/*
*--------------------------------------------------------------------*
* Program code: stg_fims_menus
* Program name: Staging FIMS.MENUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(18,2))         AS id
    , CAST(deleted AS int)            AS deleted
    , CAST(datecreated AS date)       AS datecreated
    , CAST(createdby AS string)       AS createdby
    , CAST(datemodified AS date)      AS datemodified
    , CAST(modifyby AS string)        AS modifyby
    , CAST(title AS string)           AS title
    , CAST(icon AS string)            AS icon
    , CAST(url AS string)             AS url
    , CAST(parentid AS decimal(18,2)) AS parentid
    , CAST(menutype AS int)           AS menutype
    , CAST(sortorder AS bigint)       AS sortorder
    , CAST(access AS string)          AS access
    , CAST(isactive AS int)           AS isactive
FROM {{ source('source_fims', 'raw_menus') }}
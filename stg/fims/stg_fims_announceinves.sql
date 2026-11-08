/*
*--------------------------------------------------------------------*
* Program code: stg_fims_announceinves
* Program name: Staging FIMS.ANNOUNCEINVES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(auannid AS decimal(18,2))   AS auannid
    , CAST(invesid AS decimal(18,2)) AS invesid
FROM {{ source('source_fims', 'raw_announceinves') }}
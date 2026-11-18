/*
*--------------------------------------------------------------------*
* Program code: stg_fims_categoriesstockhis
* Program name: Staging FIMS.CATEGORIESSTOCKHIS
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
    , CAST(secid AS decimal(18,2))    AS secid
    , CAST(invesid AS decimal(18,2))  AS invesid
    , CAST(quantity AS decimal(18,2)) AS quantity
    , CAST(rate AS decimal(18,2))     AS rate
FROM {{ source('source_fims', 'raw_categoriesstockhis') }}
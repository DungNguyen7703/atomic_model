/*
*--------------------------------------------------------------------*
* Program code: stg_fims_seccombusines
* Program name: Staging FIMS.SECCOMBUSINES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(secid AS decimal(18,2))  AS secid
    , CAST(buid AS decimal(18,2)) AS buid
FROM {{ source('source_fims', 'raw_seccombusines') }}
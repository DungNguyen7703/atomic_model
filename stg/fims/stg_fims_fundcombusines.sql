/*
*--------------------------------------------------------------------*
* Program code: stg_fims_fundcombusines
* Program name: Staging FIMS.FUNDCOMBUSINES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(fundid AS decimal(18,2)) AS fundid
    , CAST(buid AS decimal(18,2)) AS buid
FROM {{ source('source_fims', 'raw_fundcombusines') }}
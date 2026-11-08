/*
*--------------------------------------------------------------------*
* Program code: stg_fims_indirebusiness
* Program name: Staging FIMS.INDIREBUSINESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(indiid AS decimal(18,2)) AS indiid
    , CAST(buid AS decimal(18,2)) AS buid
FROM {{ source('source_fims', 'raw_indirebusiness') }}
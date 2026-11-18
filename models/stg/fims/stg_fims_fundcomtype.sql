/*
*--------------------------------------------------------------------*
* Program code: stg_fims_fundcomtype
* Program name: Staging FIMS.FUNDCOMTYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(fundid AS decimal(18,2))      AS fundid
    , CAST(comtypeid AS decimal(18,2)) AS comtypeid
FROM {{ source('source_fims', 'raw_fundcomtype') }}
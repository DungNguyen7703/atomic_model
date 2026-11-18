/*
*--------------------------------------------------------------------*
* Program code: stg_fims_seccomtype
* Program name: Staging FIMS.SECCOMTYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(secid AS decimal(18,2))       AS secid
    , CAST(comtypeid AS decimal(18,2)) AS comtypeid
FROM {{ source('source_fims', 'raw_seccomtype') }}
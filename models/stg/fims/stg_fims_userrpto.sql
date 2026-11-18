/*
*--------------------------------------------------------------------*
* Program code: stg_fims_userrpto
* Program name: Staging FIMS.USERRPTO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(tpoutid AS decimal(18,2)) AS tpoutid
    , CAST(ssouserid AS string)    AS ssouserid
FROM {{ source('source_fims', 'raw_userrpto') }}
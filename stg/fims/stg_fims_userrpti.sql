/*
*--------------------------------------------------------------------*
* Program code: stg_fims_userrpti
* Program name: Staging FIMS.USERRPTI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(rpttemid AS bigint)    AS rpttemid
    , CAST(ssouserid AS string) AS ssouserid
FROM {{ source('source_fims', 'raw_userrpti') }}
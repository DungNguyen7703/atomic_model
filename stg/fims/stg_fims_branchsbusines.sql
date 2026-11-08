/*
*--------------------------------------------------------------------*
* Program code: stg_fims_branchsbusines
* Program name: Staging FIMS.BRANCHSBUSINES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(braid AS decimal(18,2))  AS braid
    , CAST(buid AS decimal(18,2)) AS buid
FROM {{ source('source_fims', 'raw_branchsbusines') }}
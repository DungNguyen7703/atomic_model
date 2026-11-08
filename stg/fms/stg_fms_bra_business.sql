/*
*--------------------------------------------------------------------*
* Program code: stg_fms_bra_business
* Program name: Staging FMS.BRA_BUSINESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(bra_id)  AS bra_id
    , HEX(bu_id) AS bu_id
FROM {{ source('source_fms', 'raw_bra_business') }}
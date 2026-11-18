/*
*--------------------------------------------------------------------*
* Program code: stg_fms_agen_funds
* Program name: Staging FMS.AGEN_FUNDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(agency_id)                AS agency_id
    , HEX(fund_id)                AS fund_id
    , CAST(data_migration AS int) AS data_migration
FROM {{ source('source_fms', 'raw_agen_funds') }}
/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_active_status
* Program name: Staging ECAT.ACTIVE_STATUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)     AS id
    , CAST(name AS string) AS name
FROM {{ source('source_ecat', 'raw_active_status') }}
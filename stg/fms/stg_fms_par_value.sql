/*
*--------------------------------------------------------------------*
* Program code: stg_fms_par_value
* Program name: Staging FMS.PAR_VALUE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                             AS id
    , CAST(date_created AS date)        AS date_created
    , CAST(created_by AS string)        AS created_by
    , CAST(date_modified AS date)       AS date_modified
    , CAST(modify_by AS string)         AS modify_by
    , CAST(item_value AS decimal(18,2)) AS item_value
    , CAST(active AS int)               AS active
    , CAST(description AS string)       AS description
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_fms', 'raw_par_value') }}
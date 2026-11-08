/*
*--------------------------------------------------------------------*
* Program code: stg_fms_insder_rprst
* Program name: Staging FMS.INSDER_RPRST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , CAST(date_created AS date)     AS date_created
    , CAST(created_by AS string)     AS created_by
    , CAST(date_modified AS date)    AS date_modified
    , CAST(modify_by AS string)      AS modify_by
    , HEX(insdr_id)                  AS insdr_id
    , CAST(item_name AS string)      AS item_name
    , CAST(id_no AS string)          AS id_no
    , CAST(id_date AS date)          AS id_date
    , CAST(id_place AS string)       AS id_place
    , CAST(job AS string)            AS job
    , CAST(record_status AS int)     AS record_status
    , CAST(deleted AS int)           AS deleted
    , CAST(fr_date AS date)          AS fr_date
    , CAST(to_date AS date)          AS to_date
    , CAST(per_rep AS decimal(18,2)) AS per_rep
    , CAST(data_migration AS int)    AS data_migration
FROM {{ source('source_fms', 'raw_insder_rprst') }}
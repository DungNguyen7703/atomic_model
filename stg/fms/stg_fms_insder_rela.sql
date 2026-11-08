/*
*--------------------------------------------------------------------*
* Program code: stg_fms_insder_rela
* Program name: Staging FMS.INSDER_RELA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS date)  AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS date) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , HEX(insder_id)              AS insder_id
    , HEX(rela_id)                AS rela_id
    , CAST(item_name AS string)   AS item_name
    , CAST(id_no AS string)       AS id_no
    , CAST(id_date AS date)       AS id_date
    , CAST(id_place AS string)    AS id_place
    , CAST(deleted AS int)        AS deleted
    , CAST(address AS string)     AS address
    , CAST(description AS string) AS description
    , CAST(data_migration AS int) AS data_migration
    , CAST(gp_qd_no AS string)    AS gp_qd_no
    , CAST(approval_date AS date) AS approval_date
FROM {{ source('source_fms', 'raw_insder_rela') }}
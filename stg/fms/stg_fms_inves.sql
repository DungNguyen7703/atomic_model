/*
*--------------------------------------------------------------------*
* Program code: stg_fms_inves
* Program name: Staging FMS.INVES
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
    , HEX(sec_id)                       AS sec_id
    , HEX(nat_id)                       AS nat_id
    , HEX(sto_id)                       AS sto_id
    , CAST(item_name AS string)         AS item_name
    , CAST(id_type AS int)              AS id_type
    , CAST(id_no AS string)             AS id_no
    , CAST(id_place AS string)          AS id_place
    , CAST(id_date AS date)             AS id_date
    , CAST(dorf AS int)                 AS dorf
    , CAST(address AS string)           AS address
    , CAST(relation_ship AS string)     AS relation_ship
    , CAST(deleted AS int)              AS deleted
    , CAST(ad_scale AS decimal(18,2))   AS ad_scale
    , CAST(act_scale AS decimal(18,2))  AS act_scale
    , CAST(list_value AS decimal(18,2)) AS list_value
    , CAST(data_migration AS int)       AS data_migration
FROM {{ source('source_fms', 'raw_inves') }}
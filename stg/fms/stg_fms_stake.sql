/*
*--------------------------------------------------------------------*
* Program code: stg_fms_stake
* Program name: Staging FMS.STAKE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                          AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)     AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)      AS modify_by
    , HEX(security_id)               AS security_id
    , CAST(item_name AS string)      AS item_name
    , CAST(relation_ship AS string)  AS relation_ship
    , CAST(capital AS decimal(18,2)) AS capital
    , CAST(description AS string)    AS description
    , CAST(deleted AS int)           AS deleted
    , CAST(data_migration AS int)    AS data_migration
    , CAST(owner_flag AS int)        AS owner_flag
    , CAST(id_no AS string)          AS id_no
FROM {{ source('source_fms', 'raw_stake') }}
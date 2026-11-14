/*
*--------------------------------------------------------------------*
* Program code: stg_fms_agencies_bra
* Program name: Staging FMS.AGENCIES_BRA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                       AS id
    , CAST(date_created AS timestamp) AS date_created
    , CAST(created_by AS string)  AS created_by
    , CAST(date_modified AS timestamp) AS date_modified
    , CAST(modify_by AS string)   AS modify_by
    , HEX(agen_id)                AS agen_id
    , CAST(item_name AS string)   AS item_name
    , CAST(address AS string)     AS address
    , CAST(telephone AS string)   AS telephone
    , CAST(fax AS string)         AS fax
    , CAST(record_status AS int)  AS record_status
    , CAST(deleted AS int)        AS deleted
    , CAST(data_migration AS int) AS data_migration
FROM {{ source('source_fms', 'raw_agencies_bra') }}
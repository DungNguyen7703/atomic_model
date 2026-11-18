/*
*--------------------------------------------------------------------*
* Program code: stg_fms_mb_change
* Program name: Staging FMS.MB_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-08		tuan.nguyenvanb		Dong bo theo brd_FMS.yaml va khao sat du lieu nguon prod: kieu date sang timestamp (2 cot); kieu timestamp sang date (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS timestamp)    AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS timestamp)   AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(mbf_id)                        AS mbf_id
    , CAST(tx_date AS date)              AS tx_date
    , CAST(tx_num AS string)             AS tx_num
    , CAST(aoorp AS string)              AS aoorp
    , CAST(bus_date AS timestamp)        AS bus_date
    , CAST(prepercent AS decimal(18,2))  AS prepercent
    , CAST(aft_percent AS decimal(18,2)) AS aft_percent
    , CAST(pre_qtty AS decimal(18,2))    AS pre_qtty
    , CAST(aft_qtty AS decimal(18,2))    AS aft_qtty
    , CAST(precapital AS decimal(18,2))  AS precapital
    , CAST(aft_capital AS decimal(18,2)) AS aft_capital
FROM {{ source('source_fms', 'raw_mb_change') }}
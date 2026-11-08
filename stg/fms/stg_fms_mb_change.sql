/*
*--------------------------------------------------------------------*
* Program code: stg_fms_mb_change
* Program name: Staging FMS.MB_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , CAST(date_created AS date)         AS date_created
    , CAST(created_by AS string)         AS created_by
    , CAST(date_modified AS date)        AS date_modified
    , CAST(modify_by AS string)          AS modify_by
    , HEX(mbf_id)                        AS mbf_id
    , CAST(tx_date AS timestamp)         AS tx_date
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
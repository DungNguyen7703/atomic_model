/*
*--------------------------------------------------------------------*
* Program code: stg_fms_fund_bup
* Program name: Staging FMS.FUND_BUP
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
    , HEX(fun_hs_id)                    AS fun_hs_id
    , CAST(item_name AS string)         AS item_name
    , CAST(ename AS string)             AS ename
    , CAST(id_no AS string)             AS id_no
    , CAST(id_date AS date)             AS id_date
    , CAST(capital AS decimal(18,2))    AS capital
    , CAST(total_qtty AS decimal(18,2)) AS total_qtty
    , CAST(description AS string)       AS description
    , CAST(cer_code AS string)          AS cer_code
    , CAST(type_of_fund_no AS string)   AS type_of_fund_no
    , CAST(type_of_fund_mnp AS string)  AS type_of_fund_mnp
    , CAST(type_of_fund_dent AS string) AS type_of_fund_dent
    , CAST(deleted AS int)              AS deleted
    , CAST(time_of_fund AS string)      AS time_of_fund
    , CAST(voucher_no AS string)        AS voucher_no
    , CAST(nav AS decimal(18,2))        AS nav
    , CAST(nav_ccq AS decimal(18,2))    AS nav_ccq
    , CAST(inves_strategy AS string)    AS inves_strategy
    , CAST(file_name AS string)         AS file_name
    , CAST(file_data AS string)         AS file_data
    , CAST(dec_date AS date)            AS dec_date
    , CAST(deschange AS string)         AS deschange
    , CAST(par_value AS decimal(18,2))  AS par_value
    , CAST(ftype AS string)             AS ftype
    , CAST(bank AS string)              AS bank
    , CAST(sec AS string)               AS sec
    , CAST(record_status AS string)     AS record_status
    , CAST(str_represents AS string)    AS str_represents
    , CAST(str_mb_funds AS string)      AS str_mb_funds
    , CAST(str_agencies AS string)      AS str_agencies
    , CAST(str_transfer_mbfs AS string) AS str_transfer_mbfs
    , CAST(created_by AS string)        AS created_by
    , CAST(date_created AS date)        AS date_created
    , CAST(date_modified AS date)       AS date_modified
    , CAST(modify_by AS string)         AS modify_by
    , CAST(short_name AS string)        AS short_name
FROM {{ source('source_fms', 'raw_fund_bup') }}
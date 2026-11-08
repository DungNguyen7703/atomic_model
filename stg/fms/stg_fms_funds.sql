/*
*--------------------------------------------------------------------*
* Program code: stg_fms_funds
* Program name: Staging FMS.FUNDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                        AS id
    , CAST(date_created AS date)                   AS date_created
    , CAST(created_by AS string)                   AS created_by
    , CAST(date_modified AS date)                  AS date_modified
    , CAST(modify_by AS string)                    AS modify_by
    , CAST(item_name AS string)                    AS item_name
    , CAST(ename AS string)                        AS ename
    , CAST(short_name AS string)                   AS short_name
    , CAST(id_no AS string)                        AS id_no
    , CAST(id_date AS date)                        AS id_date
    , CAST(capital AS decimal(18,2))               AS capital
    , CAST(total_qtty AS decimal(18,2))            AS total_qtty
    , CAST(description AS string)                  AS description
    , CAST(cer_code AS string)                     AS cer_code
    , CAST(type_of_fund_no AS string)              AS type_of_fund_no
    , CAST(type_of_fund_mnp AS string)             AS type_of_fund_mnp
    , CAST(type_of_fund_dent AS string)            AS type_of_fund_dent
    , CAST(deleted AS int)                         AS deleted
    , CAST(time_of_fund AS string)                 AS time_of_fund
    , HEX(ftype_id)                                AS ftype_id
    , HEX(sec_id)                                  AS sec_id
    , HEX(bank_id)                                 AS bank_id
    , HEX(status_id)                               AS status_id
    , CAST(voucher_no AS string)                   AS voucher_no
    , CAST(nav AS decimal(18,2))                   AS nav
    , CAST(nav_ccq AS decimal(18,2))               AS nav_ccq
    , CAST(file_name AS string)                    AS file_name
    , CAST(file_data AS string)                    AS file_data
    , CAST(dec_date AS date)                       AS dec_date
    , CAST(par_value AS decimal(18,2))             AS par_value
    , CAST(inves_strategy AS string)               AS inves_strategy
    , CAST(deschange AS string)                    AS deschange
    , CAST(data_migration AS int)                  AS data_migration
    , CAST(id_db_old AS string)                    AS id_db_old
    , CAST(listing_date AS date)                   AS listing_date
    , CAST(number_fund_cer_first AS decimal(18,2)) AS number_fund_cer_first
    , CAST(stock_exchange AS string)               AS stock_exchange
    , CAST(open_fund_type AS string)               AS open_fund_type
FROM {{ source('source_fms', 'raw_funds') }}
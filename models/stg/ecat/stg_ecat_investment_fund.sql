/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_investment_fund
* Program name: Staging ECAT.INVESTMENT_FUND
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu timestamp sang date (2 cot); kieu bigint sang decimal(18,2) (5 cot); them cot fund_management_company_version_id, fund_management_company_name, id_sync, status_id, custodian_bank_name.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                           AS id
    , CAST(code AS string)                       AS code
    , CAST(short_name AS string)                 AS short_name
    , CAST(fund_type_id AS string)               AS fund_type_id
    , CAST(fund_management_company_id AS string) AS fund_management_company_id
    , CAST(custodian_bank_id AS string)          AS custodian_bank_id
    , CAST(id_no AS string)                      AS id_no
    , CAST(id_date AS date)                              AS id_date
    , CAST(dec_date AS date)                             AS dec_date
    , CAST(time_of_fund AS string)               AS time_of_fund
    , CAST(investment_strategy AS string)        AS investment_strategy
    , CAST(voucher_no AS string)                 AS voucher_no
    , CAST(description_change AS string)         AS description_change
    , CAST(file_data AS string)                  AS file_data
    , CAST(note AS string)                       AS note
    , CAST(status AS int)                        AS status
    , CAST(active AS int)                        AS active
    , CAST(active_reason AS string)              AS active_reason
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(updated_at AS timestamp)              AS updated_at
    , CAST(created_by_id AS string)              AS created_by_id
    , CAST(created_by_name AS string)            AS created_by_name
    , CAST(updated_by_id AS string)              AS updated_by_id
    , CAST(updated_by_name AS string)            AS updated_by_name
    , CAST(effective_start_date AS timestamp)    AS effective_start_date
    , CAST(effective_end_date AS timestamp)      AS effective_end_date
    , CAST(deleted AS int)                       AS deleted
    , CAST(deleted_reason AS string)             AS deleted_reason
    , CAST(version AS int)                       AS version
    , CAST(old_id AS string)                     AS old_id
    , CAST(stable_id AS string)                  AS stable_id
    , CAST(fund_management_company_version_id AS string) AS fund_management_company_version_id
    , CAST(custodian_bank_version_id AS string)  AS custodian_bank_version_id
    , CAST(fund_type_version_id AS string)       AS fund_type_version_id
    , CAST(fund_management_company_name AS string)       AS fund_management_company_name
    , CAST(id_sync AS string)                            AS id_sync
    , CAST(status_id AS string)                          AS status_id
    , CAST(custodian_bank_name AS string)                AS custodian_bank_name
    , CAST(name_vn AS string)                    AS name_vn
    , CAST(name_en AS string)                    AS name_en
    , CAST(fund_code AS string)                  AS fund_code
    , CAST(file_name AS string)                  AS file_name
    , CAST(charter_capital AS decimal(18,2))             AS charter_capital
    , CAST(total_quantity AS decimal(18,2))              AS total_quantity
    , CAST(par_value AS decimal(18,2))                   AS par_value
    , CAST(nav AS decimal(18,2))                         AS nav
    , CAST(nav_per_unit AS decimal(18,2))                AS nav_per_unit
FROM {{ source('source_ecat', 'raw_investment_fund') }}
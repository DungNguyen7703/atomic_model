/*
*--------------------------------------------------------------------*
* Program code: dtm_fund_management_company_dim
* Program name: Dtm Fund Management Company Dim
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_fund_management_company_dim_FMS_SECURITIES.csv
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): fmc_short_code đọc fmc_short_nm; đọc cl_fms_status_code,
*                                       organization_territory_ind, exchange_code, cl_fms_company_tp_code, cl_fms_event_tp_id/code;
*                                       BỎ cột other_business_activity_description (schema-changing)
* 2026-10-10		claude				total_outstanding_unit_quantity int -> bigint theo LLD sửa 2026-10-08 (commit 216a6491, tránh tràn số âm) (schema-changing:
*                                       Iceberg cần ALTER COLUMN ... TYPE bigint trên bảng chính + _hstr trước khi chạy)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit 2f62880d: market_code đọc fund_management_company.exchange_code (Atomic đổi tên từ stock_exchange_code;
*                                       logic-only ở Datamart, schema Datamart không đổi)
*--------------------------------------------------------------------*
*/

WITH fund_management_company AS (
    SELECT fmc_id,
        fmc_code,
        fmc_full_nm,
        fmc_trading_nm,
        fmc_english_nm,
        fmc_short_nm,
        cl_fms_status_code,
        organization_territory_ind,
        exchange_code,
        cl_fms_company_tp_code,
        cl_fms_event_tp_id,
        cl_fms_event_tp_code,
        charter_capital_amt,
        total_outstanding_unit_quantity,
        business_tp_description,
        actual_business_tp_description,
        description,
        stock_ticker_code,
        country_of_registration_nm,
        record_cl_text,
        internal_transaction_code,
        listing_description,
        foreign_organization_tp_description,
        foreign_organization_country_nm,
        foreign_organization_registration_nbr,
        amendment_document_nbr,
        change_description,
        parent_organization_nm,
        director_full_nm,
        deputy_director_full_nm,
        legal_representative_ind,
        public_listed_ind,
        effective_start_dt,
        effective_end_dt,
        suspension_dt,
        operation_commencement_dt,
        actual_operation_commencement_dt,
        registration_dt,
        financial_activity_end_dt,
        decision_issue_dt,
        custodian_bank_id,
        custodian_bank_code,
        parent_fmc_id,
        parent_fmc_code,
        src_stm_code
    FROM {{ ref('atm_fund_management_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
)

SELECT
    CAST(fmc_id as string)                                   AS fmc_id,
    CAST(fmc_code AS string)                                 AS fmc_code,
    CAST(fmc_full_nm AS string)                              AS fmc_full_nm,
    CAST(fmc_trading_nm AS string)                           AS fmc_trading_nm,
    CAST(fmc_english_nm AS string)                           AS fmc_english_nm,
    CAST(fmc_short_nm AS string)                             AS fmc_short_nm,
    CAST(fmc_short_nm AS string)                             AS fmc_short_code,
    CAST(cl_fms_status_code AS string)                       AS operation_status_code,
    CAST(organization_territory_ind AS string)               AS organization_territory_tp_code,
    CAST(exchange_code AS string)                            AS market_code,
    CAST(cl_fms_company_tp_code AS string)                   AS company_tp_code,
    CAST(cl_fms_event_tp_id AS string)                       AS event_tp_id,
    CAST(cl_fms_event_tp_code AS string)                     AS event_tp_code,
    CAST(charter_capital_amt AS decimal(23,2))               AS charter_capital_amt,
    CAST(total_outstanding_unit_quantity AS bigint)          AS total_outstanding_unit_quantity,
    CAST(business_tp_description AS string)                  AS business_tp_description,
    CAST(actual_business_tp_description AS string)           AS actual_business_tp_description,
    CAST(description AS string)                              AS description,
    CAST(stock_ticker_code AS string)                        AS stock_ticker_code,
    CAST(country_of_registration_nm AS string)               AS country_of_registration_nm,
    CAST(record_cl_text AS string)                           AS record_cl_text,
    CAST(internal_transaction_code AS string)                AS internal_transaction_code,
    CAST(listing_description AS string)                      AS listing_description,
    CAST(foreign_organization_tp_description AS string)      AS foreign_organization_tp_description,
    CAST(foreign_organization_country_nm AS string)          AS foreign_organization_country_nm,
    CAST(foreign_organization_registration_nbr AS string)    AS foreign_organization_registration_nbr,
    CAST(amendment_document_nbr AS string)                   AS amendment_document_nbr,
    CAST(change_description AS string)                       AS change_description,
    CAST(parent_organization_nm AS string)                   AS parent_organization_nm,
    CAST(director_full_nm AS string)                         AS director_full_nm,
    CAST(deputy_director_full_nm AS string)                  AS deputy_director_full_nm,
    CAST(legal_representative_ind AS string)                 AS legal_representative_ind,
    CAST(public_listed_ind AS string)                        AS public_listed_ind,
    CAST(effective_start_dt AS date)                         AS effective_start_dt,
    CAST(effective_end_dt AS date)                           AS effective_end_dt,
    CAST(suspension_dt AS date)                              AS suspension_dt,
    CAST(operation_commencement_dt AS date)                  AS operation_commencement_dt,
    CAST(actual_operation_commencement_dt AS date)           AS actual_operation_commencement_dt,
    CAST(registration_dt AS date)                            AS registration_dt,
    CAST(financial_activity_end_dt AS date)                  AS financial_activity_end_dt,
    CAST(decision_issue_dt AS date)                          AS decision_issue_dt,
    CAST(custodian_bank_id AS string)                        AS custodian_bank_id,
    CAST(custodian_bank_code AS string)                      AS custodian_bank_code,
    CAST(parent_fmc_id AS string)                            AS parent_fmc_id,
    CAST(parent_fmc_code AS string)                          AS parent_fmc_code,
    CAST(src_stm_code AS string)                             AS src_stm_code
FROM fund_management_company

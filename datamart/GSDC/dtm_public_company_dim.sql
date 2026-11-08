/*
*--------------------------------------------------------------------*
* Program code: dtm_public_company_dim
* Program name: Dtm Public Company Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-23		tuan.nguyenvanb		[SUA] Doi nguon nganh: atm_cl_business_line (ECAT_BUSINESS_LINE_LEVEL_1) -> atm_cl_ids_business_line (IDS_CATEGORIES). Khong doi cot/kieu mart.
*
*--------------------------------------------------------------------*
*/

WITH company_profile AS (
    SELECT
        pc_code,
        equity_ticker_symbol,
        pc_nm,
        exchange_code,
        cl_ids_business_line_level_1_code,
        ids_registration_dt,
        pc_status_code,
        src_stm_code,
        pc_english_nm,
        enterprise_tp_code,
        pc_tp_code,
        head_office_province_nm,
        operating_status_code,
        has_state_ownership_ind,
        charter_capital_amt,
        first_registration_dt,
        latest_registration_dt,
        latest_registration_province_nm,
        ids_registration_ind,
        pc_form_tp_code,
        former_state_owned_ind,
        foreign_direct_investment_ind,
        has_parent_company_ind,
        has_subsidiary_ind,
        has_joint_venture_ind,
        ipo_company_ind,
        cl_ids_business_line_level_1_id
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES'
),

business_line AS (
    SELECT
        cl_ids_business_line_nm,
        cl_ids_business_line_id
    FROM {{ ref('atm_cl_ids_business_line') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_CATEGORIES'
),

catalog_value AS (
    SELECT
        cl_nm,
        cl_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code in('ENTERPRISE_TYPE', 'LISTED_EXCHANGE_CODE')
)

SELECT
    CAST({{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', 'company_profile.pc_code') }} AS string) AS public_company_dim_id,
    CAST(company_profile.pc_code AS string)                                            AS public_company_code,
    CAST(company_profile.equity_ticker_symbol AS string)                               AS equity_ticker_symbol,
    CAST(company_profile.pc_nm AS string)                                              AS public_company_nm,
    CAST(company_profile.exchange_code AS string)                       AS equity_listing_exchange_code,
    CAST(exchange_catalog.cl_nm AS string)                                             AS equity_listing_exchange_name,
    CAST(company_profile.cl_ids_business_line_level_1_code AS string)                         AS business_line_level_1_code,
    CAST(company_profile.ids_registration_dt AS date)                                  AS ids_registration_dt,
    CAST(company_profile.pc_status_code AS string)                                     AS public_company_status_code,
    CAST(company_profile.src_stm_code AS string)                                       AS src_stm_code,
    CAST(business_line.cl_ids_business_line_nm AS string)                              AS classification_business_line_nm,
    CAST(company_profile.pc_english_nm AS string)                                      AS public_company_english_nm,
    CAST(company_profile.enterprise_tp_code AS string)                                 AS enterprise_tp_code,
    CAST(enterprise_type_catalog.cl_nm AS string)                                      AS enterprise_tp_nm,
    CAST(company_profile.pc_tp_code AS string)                                         AS public_company_tp_code,
    CAST(company_profile.head_office_province_nm AS string)                            AS head_office_province_nm,
    CAST(company_profile.operating_status_code AS string)                              AS operating_status_code,
    CAST(company_profile.has_state_ownership_ind AS int)                               AS has_state_ownership_indicator,
    CAST(company_profile.charter_capital_amt AS decimal(23,2))                         AS charter_capital_amt,
    CAST(company_profile.first_registration_dt AS date)                                AS first_registration_dt,
    CAST(company_profile.latest_registration_dt AS date)                               AS latest_registration_dt,
    CAST(company_profile.latest_registration_province_nm AS string)                    AS latest_registration_province_nm,
    CAST(company_profile.ids_registration_ind AS int)                                  AS ids_registration_indicator,
    CAST(company_profile.pc_form_tp_code AS string)                                       AS public_company_form_code,
    CAST(company_profile.former_state_owned_ind AS int)                                AS former_state_owned_indicator,
    CAST(company_profile.foreign_direct_investment_ind AS int)                         AS foreign_direct_investment_indicator,
    CAST(company_profile.has_parent_company_ind AS int)                                AS has_parent_company_indicator,
    CAST(company_profile.has_subsidiary_ind AS int)                                    AS has_subsidiary_indicator,
    CAST(company_profile.has_joint_venture_ind AS int)                                 AS has_joint_venture_indicator,
    CAST(company_profile.ipo_company_ind AS int)                                       AS ipo_company_indicator
FROM company_profile
LEFT JOIN business_line
    ON  business_line.cl_ids_business_line_id = company_profile.cl_ids_business_line_level_1_id
LEFT JOIN catalog_value exchange_catalog
    ON exchange_catalog.cl_code = company_profile.exchange_code
LEFT JOIN catalog_value enterprise_type_catalog
    on enterprise_type_catalog.cl_code = company_profile.enterprise_tp_code

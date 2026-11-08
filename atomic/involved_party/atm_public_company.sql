/*
*--------------------------------------------------------------------*
* Program code: atm_public_company
* Program name: Atomic Public Company
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH co_pr AS (
    SELECT
        id
        , company_name_vn
        , company_name_en
        , first_reg_date
        , latest_reg_date
        , latest_reg_prov
        , capital_paid_reported
        , treasury_shares
        , category_l1_id
        , category_l2_id
        , enterprise_type_cd
        , financial_stmt_type_cd
        , securities_type_cd
        , equity_listing_exch
        , equity_ticker
        , equity_security_flg
        , equity_listed_qty
        , bond_listing_exch
        , bond_ticker
        , bond_security_flg
        , bond_listed_qty
        , intl_exch
        , intl_ticker
        , status_ids_cd
        , auto_approval_flg
        , company_login
        , approver_comment
        , specialist_notes
        , ids_reg_status_flg
        , ids_reg_date
        , operating_status_cd
        , fy_end_date
        , public_company_form_cd
        , public_com_type_cd
        , public_bond_issuer_flg
        , former_state_owned_flg
        , equit_license_date
        , capital_at_equit
        , has_state_own_flg
        , fdi_com_flg
        , has_parent_com_flg
        , has_subsidiaries_flg
        , has_joint_ventures_flg
        , head_office_prov
        , ipo_company_flg
        , approval_status_cd
    FROM {{ ref('ods_ids_company_profiles') }}
),

cate AS (
    SELECT
        id
        , industry_cd
    FROM {{ ref('ods_ids_categories') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "co_pr.id") }}                 AS pc_id
    , CAST(co_pr.id AS string)                                                              AS pc_code
    , CAST('IDS_COMPANY_PROFILES' AS string)                                                AS src_stm_code
    , CAST(co_pr.company_name_vn AS string)                                                 AS pc_nm
    , CAST(co_pr.company_name_en AS string)                                                 AS pc_english_nm
    , CAST(co_pr.first_reg_date AS date)                                                    AS first_registration_dt
    , CAST(co_pr.latest_reg_date AS date)                                                   AS latest_registration_dt
    , CAST(co_pr.latest_reg_prov AS string)                                                 AS latest_registration_province_nm
    , CAST(co_pr.capital_paid_reported AS decimal(23,2))                                    AS charter_capital_amt
    , CAST(co_pr.treasury_shares AS int)                                                    AS treasury_share_quantity
    , {{ generate_surrogate_key_bigint('IDS_CATEGORIES', "cate_l1.industry_cd") }}          AS cl_ids_business_line_level_1_id
    , CAST(cate_l1.industry_cd AS string)                                                   AS cl_ids_business_line_level_1_code
    , {{ generate_surrogate_key_bigint('IDS_CATEGORIES', "cate_l2.industry_cd") }}          AS cl_ids_business_line_level_2_id
    , CAST(cate_l2.industry_cd AS string)                                                   AS cl_ids_business_line_level_2_code
    , CAST(co_pr.enterprise_type_cd AS string)                                              AS enterprise_tp_code
    , CAST(co_pr.financial_stmt_type_cd AS string)                                          AS financial_statement_tp_code
    , CAST(co_pr.securities_type_cd AS string)                                              AS securities_tp_code
    , CAST(co_pr.equity_listing_exch AS string)                                             AS exchange_code
    , CAST(co_pr.equity_ticker AS string)                                                   AS equity_ticker_symbol
    , CAST(co_pr.equity_security_flg AS int)                                                AS equity_security_ind
    , CAST(co_pr.equity_listed_qty AS int)                                                  AS equity_listed_quantity
    , CAST(co_pr.bond_listing_exch AS string)                                               AS bond_exchange_code
    , CAST(co_pr.bond_ticker AS string)                                                     AS bond_ticker_symbol
    , CAST(co_pr.bond_security_flg AS int)                                                  AS bond_security_ind
    , CAST(co_pr.bond_listed_qty AS int)                                                    AS bond_listed_quantity
    , CAST(co_pr.intl_exch AS string)                                                       AS international_exchange_nm
    , CAST(co_pr.intl_ticker AS string)                                                     AS international_ticker_symbol
    , CAST(co_pr.status_ids_cd AS string)                                                   AS pc_status_code
    , CAST(co_pr.auto_approval_flg AS int)                                                  AS auto_approval_ind
    , CAST(co_pr.company_login AS string)                                                   AS company_login_username
    , CAST(co_pr.approver_comment AS string)                                                AS approver_comment
    , CAST(co_pr.specialist_notes AS string)                                                AS specialist_note
    , CAST(co_pr.ids_reg_status_flg AS int)                                                 AS ids_registration_ind
    , CAST(co_pr.ids_reg_date AS date)                                                      AS ids_registration_dt
    , CAST(co_pr.operating_status_cd AS string)                                             AS operating_status_code
    , CAST(co_pr.fy_end_date AS date)                                                       AS fiscal_year_end_dt
    , CAST(co_pr.public_company_form_cd AS string)                                          AS pc_form_tp_code
    , CAST(co_pr.public_com_type_cd AS string)                                              AS pc_tp_code
    , CAST(co_pr.public_bond_issuer_flg AS int)                                             AS public_bond_issuer_ind
    , CAST(co_pr.former_state_owned_flg AS int)                                             AS former_state_owned_ind
    , CAST(co_pr.equit_license_date AS date)                                                AS equitization_license_dt
    , CAST(co_pr.capital_at_equit AS decimal(23,2))                                         AS equitization_capital_amt
    , CAST(co_pr.has_state_own_flg AS int)                                                  AS has_state_ownership_ind
    , CAST(co_pr.fdi_com_flg AS int)                                                        AS foreign_direct_investment_ind
    , CAST(co_pr.has_parent_com_flg AS int)                                                 AS has_parent_company_ind
    , CAST(co_pr.has_subsidiaries_flg AS int)                                               AS has_subsidiary_ind
    , CAST(co_pr.has_joint_ventures_flg AS int)                                             AS has_joint_venture_ind
    , CAST(co_pr.head_office_prov AS string)                                                AS head_office_province_nm
    , CAST(co_pr.ipo_company_flg AS int)                                                    AS ipo_company_ind
    , CAST(co_pr.approval_status_cd AS string)                                              AS approval_status_code
FROM co_pr
LEFT JOIN cate AS cate_l1 ON co_pr.category_l1_id = cate_l1.id
LEFT JOIN cate AS cate_l2 ON co_pr.category_l2_id = cate_l2.id
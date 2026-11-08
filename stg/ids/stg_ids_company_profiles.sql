/*
*--------------------------------------------------------------------*
* Program code: stg_ids_company_profiles
* Program name: Staging IDS.COMPANY_PROFILES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(company_name_vn AS string)        AS company_name_vn
    , CAST(company_name_en AS string)        AS company_name_en
    , CAST(business_reg_no AS string)        AS business_reg_no
    , CAST(first_reg_date AS date)           AS first_reg_date
    , CAST(latest_reg_date AS date)          AS latest_reg_date
    , CAST(latest_reg_prov AS string)        AS latest_reg_prov
    , CAST(capital_paid_reported AS bigint)  AS capital_paid_reported
    , CAST(treasury_shares AS int)           AS treasury_shares
    , CAST(head_office_addr AS string)       AS head_office_addr
    , CAST(province_id AS string)            AS province_id
    , CAST(trading_office_addr AS string)    AS trading_office_addr
    , CAST(website AS string)                AS website
    , CAST(phone_no AS string)               AS phone_no
    , CAST(fax_no AS string)                 AS fax_no
    , CAST(category_l1_id AS int)            AS category_l1_id
    , CAST(category_l2_id AS int)            AS category_l2_id
    , CAST(enterprise_type_cd AS string)     AS enterprise_type_cd
    , CAST(financial_stmt_type_cd AS string) AS financial_stmt_type_cd
    , CAST(securities_type_cd AS string)     AS securities_type_cd
    , CAST(equity_listing_exch AS string)    AS equity_listing_exch
    , CAST(equity_ticker AS string)          AS equity_ticker
    , CAST(equity_security_flg AS int)       AS equity_security_flg
    , CAST(equity_listed_qty AS int)         AS equity_listed_qty
    , CAST(bond_listing_exch AS string)      AS bond_listing_exch
    , CAST(bond_ticker AS string)            AS bond_ticker
    , CAST(bond_security_flg AS int)         AS bond_security_flg
    , CAST(bond_listed_qty AS int)           AS bond_listed_qty
    , CAST(intl_exch AS string)              AS intl_exch
    , CAST(intl_ticker AS string)            AS intl_ticker
    , CAST(status_ids_cd AS string)          AS status_ids_cd
    , CAST(auto_approval_flg AS int)         AS auto_approval_flg
    , CAST(company_login AS string)          AS company_login
    , CAST(approver_comment AS string)       AS approver_comment
    , CAST(specialist_notes AS string)       AS specialist_notes
    , CAST(ids_reg_status_flg AS int)        AS ids_reg_status_flg
    , CAST(ids_reg_date AS date)             AS ids_reg_date
    , CAST(operating_status_cd AS string)    AS operating_status_cd
    , CAST(fy_end_date AS date)              AS fy_end_date
    , CAST(public_company_form_cd AS string) AS public_company_form_cd
    , CAST(public_com_type_cd AS string)     AS public_com_type_cd
    , CAST(public_bond_issuer_flg AS int)    AS public_bond_issuer_flg
    , CAST(former_state_owned_flg AS int)    AS former_state_owned_flg
    , CAST(equit_license_date AS date)       AS equit_license_date
    , CAST(capital_at_equit AS int)          AS capital_at_equit
    , CAST(has_state_own_flg AS int)         AS has_state_own_flg
    , CAST(fdi_com_flg AS int)               AS fdi_com_flg
    , CAST(has_parent_com_flg AS int)        AS has_parent_com_flg
    , CAST(has_subsidiaries_flg AS int)      AS has_subsidiaries_flg
    , CAST(has_joint_ventures_flg AS int)    AS has_joint_ventures_flg
    , CAST(delete_flg AS int)                AS delete_flg
    , CAST(created_by AS string)             AS created_by
    , CAST(created_date AS date)             AS created_date
    , CAST(updated_by AS string)             AS updated_by
    , CAST(updated_date AS date)             AS updated_date
    , CAST(head_office_prov AS string)       AS head_office_prov
    , CAST(ipo_company_flg AS int)           AS ipo_company_flg
    , CAST(approval_status_cd AS string)     AS approval_status_cd
FROM {{ source('source_ids', 'raw_company_profiles') }}
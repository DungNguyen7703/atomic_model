/*
*--------------------------------------------------------------------*
* Program code: ods_ids_company_profiles
* Program name: ODS IDS.COMPANY_PROFILES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_name_vn
        , company_name_en
        , business_reg_no
        , first_reg_date
        , latest_reg_date
        , latest_reg_prov
        , capital_paid_reported
        , treasury_shares
        , head_office_addr
        , province_id
        , trading_office_addr
        , website
        , phone_no
        , fax_no
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
        , delete_flg
        , created_by
        , created_date
        , updated_by
        , updated_date
        , head_office_prov
        , ipo_company_flg
        , approval_status_cd
    FROM {{ ref('stg_ids_company_profiles') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND delete_flg = 0
)

SELECT
    id
    , company_name_vn
    , company_name_en
    , business_reg_no
    , first_reg_date
    , latest_reg_date
    , latest_reg_prov
    , capital_paid_reported
    , treasury_shares
    , head_office_addr
    , province_id
    , trading_office_addr
    , website
    , phone_no
    , fax_no
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
    , delete_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , head_office_prov
    , ipo_company_flg
    , approval_status_cd
FROM src

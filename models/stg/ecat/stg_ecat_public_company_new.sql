/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_public_company_new
* Program name: Staging ECAT.PUBLIC_COMPANY_NEW
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Bo sung STG cho bang thieu so voi BRD brd_ECAT.yaml (cot/kieu theo ECAT_ddl_prod.sql).
* 2026-11-07		tuan.nguyenvanb		Dong bo theo ECAT_ddl_prod.sql va ket qua khao sat du lieu nguon prod: kieu decimal(38,10) sang int (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(company_name_vn AS string)          AS company_name_vn
    , CAST(company_name_en AS string)          AS company_name_en
    , CAST(business_reg_no AS string)          AS business_reg_no
    , CAST(first_reg_date AS timestamp)        AS first_reg_date
    , CAST(latest_reg_date AS timestamp)       AS latest_reg_date
    , CAST(latest_reg_prov AS string)          AS latest_reg_prov
    , CAST(capital_paid_reported AS bigint)    AS capital_paid_reported
    , CAST(treasury_shares AS decimal(19,0))   AS treasury_shares
    , CAST(head_office_addr AS string)         AS head_office_addr
    , CAST(province_id AS string)              AS province_id
    , CAST(trading_office_addr AS string)      AS trading_office_addr
    , CAST(website AS string)                  AS website
    , CAST(phone_no AS string)                 AS phone_no
    , CAST(fax_no AS string)                   AS fax_no
    , CAST(category_l1_id AS string)           AS category_l1_id
    , CAST(category_l2_id AS string)           AS category_l2_id
    , CAST(enterprise_type_cd AS string)       AS enterprise_type_cd
    , CAST(financial_stmt_type_cd AS string)   AS financial_stmt_type_cd
    , CAST(securities_type_cd AS string)       AS securities_type_cd
    , CAST(equity_listing_exch AS string)      AS equity_listing_exch
    , CAST(equity_ticker AS string)            AS equity_ticker
    , CAST(equity_security_flg AS int)         AS equity_security_flg
    , CAST(equity_listed_qty AS decimal(19,0)) AS equity_listed_qty
    , CAST(bond_listing_exch AS string)        AS bond_listing_exch
    , CAST(bond_ticker AS string)              AS bond_ticker
    , CAST(bond_security_flg AS int)           AS bond_security_flg
    , CAST(bond_listed_qty AS decimal(19,0))   AS bond_listed_qty
    , CAST(intl_exch AS string)                AS intl_exch
    , CAST(intl_ticker AS string)              AS intl_ticker
    , CAST(status_ids_cd AS string)            AS status_ids_cd
    , CAST(auto_approval_flg AS int)           AS auto_approval_flg
    , CAST(company_login AS string)            AS company_login
    , CAST(approver_comment AS string)         AS approver_comment
    , CAST(specialist_notes AS string)         AS specialist_notes
    , CAST(ids_reg_status_flg AS int)          AS ids_reg_status_flg
    , CAST(ids_reg_date AS timestamp)          AS ids_reg_date
    , CAST(operating_status_cd AS string)      AS operating_status_cd
    , CAST(fy_end_date AS timestamp)           AS fy_end_date
    , CAST(public_company_form_cd AS string)   AS public_company_form_cd
    , CAST(public_com_type_cd AS string)       AS public_com_type_cd
    , CAST(public_bond_issuer_flg AS int)      AS public_bond_issuer_flg
    , CAST(former_state_owned_flg AS int)      AS former_state_owned_flg
    , CAST(equit_license_date AS timestamp)    AS equit_license_date
    , CAST(capital_at_equit AS bigint)         AS capital_at_equit
    , CAST(has_state_own_flg AS int)           AS has_state_own_flg
    , CAST(fdi_com_flg AS int)                 AS fdi_com_flg
    , CAST(has_parent_com_flg AS int)          AS has_parent_com_flg
    , CAST(has_subsidiaries_flg AS int)        AS has_subsidiaries_flg
    , CAST(has_joint_ventures_flg AS int)      AS has_joint_ventures_flg
    , CAST(delete_flg AS int)                  AS delete_flg
    , CAST(deleted AS int)                     AS deleted
    , CAST(deleted_reason AS string)           AS deleted_reason
    , CAST(version AS int)                     AS version
    , CAST(effective_start_date AS timestamp)  AS effective_start_date
    , CAST(effective_end_date AS timestamp)    AS effective_end_date
    , CAST(old_id AS string)                   AS old_id
    , CAST(stable_id AS string)                AS stable_id
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(created_by_id AS string)            AS created_by_id
    , CAST(created_by_name AS string)          AS created_by_name
    , CAST(updated_by_id AS string)            AS updated_by_id
    , CAST(updated_by_name AS string)          AS updated_by_name
    , CAST(head_office_prov AS string)         AS head_office_prov
    , CAST(ipo_company_flg AS int)             AS ipo_company_flg
    , CAST(id_sync AS string)                  AS id_sync
    , CAST(approval_status_cd AS string)       AS approval_status_cd
FROM {{ source('source_ecat', 'raw_public_company_new') }}
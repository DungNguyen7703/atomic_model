/*
*--------------------------------------------------------------------*
* Program code: stg_ids_bond_payment_status
* Program name: Staging IDS.BOND_PAYMENT_STATUS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                    AS id
    , CAST(bond_ticker AS string)                        AS bond_ticker
    , CAST(company_name AS string)                       AS company_name
    , CAST(business_reg_no AS string)                    AS business_reg_no
    , CAST(issuance_value AS decimal(19,0))              AS issuance_value
    , CAST(outstanding_principal_value AS decimal(19,0)) AS outstanding_principal_value
    , CAST(payment_type AS string)                       AS payment_type
    , CAST(nominal_payment_date AS date)                 AS nominal_payment_date
    , CAST(planned_payment_date AS date)                 AS planned_payment_date
    , CAST(actual_payment_date AS date)                  AS actual_payment_date
    , CAST(coupon_rate AS decimal(5,2))                  AS coupon_rate
    , CAST(amount_payable AS decimal(19,0))              AS amount_payable
    , CAST(amount_paid_on_time AS decimal(19,0))         AS amount_paid_on_time
    , CAST(late_amount_paid AS decimal(19,0))            AS late_amount_paid
    , CAST(unpaid_amount AS decimal(19,0))               AS unpaid_amount
    , CAST(late_payment_reason AS string)                AS late_payment_reason
    , CAST(investor_negotiation_status AS string)        AS investor_negotiation_status
    , CAST(created_by AS string)                         AS created_by
    , CAST(created_date AS date)                         AS created_date
    , CAST(updated_by AS string)                         AS updated_by
    , CAST(updated_date AS date)                         AS updated_date
    , CAST(delete_flg AS int)                            AS delete_flg
FROM {{ source('source_ids', 'raw_bond_payment_status') }}
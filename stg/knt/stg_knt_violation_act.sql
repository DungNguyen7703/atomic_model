/*
*--------------------------------------------------------------------*
* Program code: stg_knt_violation_act
* Program name: Staging KNT.VIOLATION_ACT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                     AS id
    , CAST(subject_profile_id AS string)     AS subject_profile_id
    , CAST(penalty_decision_id AS string)    AS penalty_decision_id
    , CAST(violation_act_id AS string)       AS violation_act_id
    , CAST(fine_amount AS int)               AS fine_amount
    , CAST(legal_basis_doc AS string)        AS legal_basis_doc
    , CAST(violation_handling_doc AS string) AS violation_handling_doc
    , CAST(remedial_measure AS string)       AS remedial_measure
    , CAST(created_by AS string)             AS created_by
    , CAST(created_at AS date)               AS created_at
    , CAST(violation_act_name AS string)     AS violation_act_name
    , CAST(securities_code AS string)        AS securities_code
    , CAST(account_number AS string)         AS account_number
    , CAST(violation_type AS int)            AS violation_type
    , CAST(shares_quantity AS int)           AS shares_quantity
    , CAST(holding_ratio AS string)          AS holding_ratio
    , CAST(buy_quantity AS int)              AS buy_quantity
    , CAST(sell_quantity AS int)             AS sell_quantity
    , CAST(transaction_date AS string)       AS transaction_date
FROM {{ source('source_knt', 'raw_violation_act') }}
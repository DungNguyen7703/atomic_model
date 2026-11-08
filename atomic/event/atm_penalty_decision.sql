/*
*--------------------------------------------------------------------*
* Program code: atm_penalty_decision
* Program name: Atomic Penalty Decision
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de AS (
    SELECT
        id
        , violation_case_id
        , decision_number
        , issued_date
        , decision_category
        , status
        , anti_money_laundering
        , total_fine_amount
        , payment_deadline
        , submitted_at
        , complaint_exists
        , complaint_content
        , complaint_received_date
        , complaint_status
        , complaint_result
        , lawsuit_exists
        , lawsuit_content
        , signed_document_url
        , summary
        , source_document_url
        , enforcement_status
        , confiscated_asset_sale_amount
        , other_penalty_revenue_amount
        , report_classification
    FROM {{ ref('ods_thanhtra_penalty_decision') }}
),

vi_ca AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_case') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', "pe_de.id") }}   AS pd_id
    , CAST(pe_de.id AS string)                                                     AS pd_code
    , CAST('THANHTRA_PENALTY_DECISION' AS string)                                  AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE', "vi_ca.code") }} AS violation_case_id
    , CAST(vi_ca.code AS string)                                                   AS violation_case_code
    , CAST(pe_de.decision_number AS string)                                        AS decision_nbr
    , CAST(pe_de.issued_date AS date)                                              AS issued_dt
    , CAST(pe_de.decision_category AS string)                                      AS decision_category_code
    , CAST(pe_de.status AS string)                                                 AS life_cycle_status_code
    , CAST(pe_de.anti_money_laundering AS int)                                     AS anti_money_laundering_ind
    , CAST(pe_de.total_fine_amount AS decimal(23,2))                               AS total_fine_amt
    , CAST(pe_de.payment_deadline AS date)                                         AS payment_deadline
    , CAST(pe_de.submitted_at AS timestamp)                                        AS submitted_tms
    , CAST(pe_de.complaint_exists AS int)                                          AS complaint_exists_ind
    , CAST(pe_de.complaint_content AS string)                                      AS complaint_content
    , CAST(pe_de.complaint_received_date AS date)                                  AS complaint_received_dt
    , CAST(pe_de.complaint_status AS string)                                       AS complaint_status_code
    , CAST(pe_de.complaint_result AS string)                                       AS complaint_result
    , CAST(pe_de.lawsuit_exists AS int)                                            AS lawsuit_exists_ind
    , CAST(pe_de.lawsuit_content AS string)                                        AS lawsuit_content
    , CAST(pe_de.signed_document_url AS string)                                    AS signed_document_url
    , CAST(pe_de.summary AS string)                                                AS summary
    , CAST(pe_de.source_document_url AS string)                                    AS src_document_url
    , CAST(pe_de.enforcement_status AS string)                                     AS enforcement_status_code
    , CAST(pe_de.confiscated_asset_sale_amount AS decimal(23,2))                   AS confiscated_asset_sale_amt
    , CAST(pe_de.other_penalty_revenue_amount AS decimal(23,2))                    AS other_penalty_revenue_amt
    , CAST(pe_de.report_classification AS string)                                  AS rpt_cl_code
FROM pe_de
    LEFT JOIN vi_ca ON pe_de.VIOLATION_CASE_ID = vi_ca.ID
/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_post_processing
* Program name: Atomic Inspection Post Processing
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH po_in_pr AS (
    SELECT
        id
        , inspection_conclusion_id
        , requirement_type
        , responsible_party
        , due_date
        , status
        , requirement_summary
        , implementation_notes
        , result_summary
        , last_updated_date
        , monitoring_officer_id
        , monitoring_officer_name
    FROM {{ ref('ods_thanhtra_post_inspection_processing') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_POST_INSPECTION_PROCESSING', "po_in_pr.id") }}                    AS inspection_post_processing_id
    , CAST(po_in_pr.id AS string)                                                                                AS inspection_post_processing_code
    , CAST('THANHTRA_POST_INSPECTION_PROCESSING' AS string)                                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_CONCLUSION', "po_in_pr.inspection_conclusion_id") }} AS inspection_conclusion_id
    , CAST(po_in_pr.inspection_conclusion_id AS string)                                                          AS inspection_conclusion_code
    , CAST(po_in_pr.requirement_type AS string)                                                                  AS requirement_tp_code
    , CAST(po_in_pr.responsible_party AS string)                                                                 AS responsible_party
    , CAST(po_in_pr.due_date AS date)                                                                            AS due_dt
    , CAST(po_in_pr.status AS string)                                                                            AS life_cycle_status_code
    , CAST(po_in_pr.requirement_summary AS string)                                                               AS requirement_summary
    , CAST(po_in_pr.implementation_notes AS string)                                                              AS implementation_notes
    , CAST(po_in_pr.result_summary AS string)                                                                    AS result_summary
    , CAST(po_in_pr.last_updated_date AS date)                                                                   AS last_updated_dt
    , {{ generate_surrogate_key_bigint('IAM_USERS', "po_in_pr.monitoring_officer_id") }}                         AS monitoring_officer_id
    , CAST(po_in_pr.monitoring_officer_name AS string)                                                           AS monitoring_officer_code
FROM po_in_pr
/*
*--------------------------------------------------------------------*
* Program code: dtm_penalty_decision_subject_dim
* Program name: Penalty Decision Subject Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        pd_subject_code,
        subject_tp_code,
        src_stm_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT', 'pe_de_su.pd_subject_code') }} AS string) AS penalty_decision_subject_dim_id,
    CAST(pe_de_su.pd_subject_code AS string)                                 AS penalty_decision_subject_code,
    CAST(pe_de_su.subject_tp_code AS string)                                 AS subject_tp_code,
    CAST(pe_de_su.src_stm_code AS string)                                    AS src_stm_code
FROM pe_de_su

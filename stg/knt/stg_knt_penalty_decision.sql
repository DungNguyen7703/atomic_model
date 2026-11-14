/*
*--------------------------------------------------------------------*
* Program code: stg_knt_penalty_decision
* Program name: Staging KNT.PENALTY_DECISION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: WHERE loc theo BRD filter_logic; kieu int sang decimal(38,10) (6 cot); kieu date sang timestamp (1 cot); yml snapshot/ds_snpst_dt -> append/created_at theo BRD.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(inspection_dossier_id AS string)   AS inspection_dossier_id
    , CAST(complaint_dossier_id AS string)    AS complaint_dossier_id
    , CAST(penalty_decision_number AS string) AS penalty_decision_number
    , CAST(violation_record_number AS string) AS violation_record_number
    , CAST(violation_record_date AS date)     AS violation_record_date
    , CAST(main_penalty_type AS int)          AS main_penalty_type
    , CAST(supplementary_penalty AS string)   AS supplementary_penalty
    , CAST(aggravating_mitigating AS string)  AS aggravating_mitigating
    , CAST(total_fine_amount AS decimal(38,10))       AS total_fine_amount
    , CAST(note AS string)                    AS note
    , CAST(status AS int)                     AS status
    , CAST(created_by AS string)              AS created_by
    , CAST(created_at AS timestamp)                   AS created_at
    , CAST(aml_violation AS int)              AS aml_violation
    , CAST(paid_fine_amount AS decimal(38,10))        AS paid_fine_amount
    , CAST(complaint_id AS string)            AS complaint_id
    , CAST(subject_type AS int)               AS subject_type
    , CAST(subject_id AS string)              AS subject_id
    , CAST(subject_name AS string)            AS subject_name
    , CAST(inspected_subject_id AS string)    AS inspected_subject_id
    , CAST(classification AS int)             AS classification
    , CAST(full_search AS string)             AS full_search
    , CAST(end_date AS date)                  AS end_date
    , CAST(violation_amount AS decimal(38,10))        AS violation_amount
    , CAST(decision_revision_count AS decimal(38,10)) AS decision_revision_count
    , CAST(enforcement_from_date AS date)     AS enforcement_from_date
    , CAST(enforcement_to_date AS date)       AS enforcement_to_date
    , CAST(decision_signed_date AS date)      AS decision_signed_date
    , CAST(content AS string)                 AS content
    , CAST(revoke_license_flag AS decimal(38,10))     AS revoke_license_flag
    , CAST(suspend_operation_flag AS decimal(38,10))  AS suspend_operation_flag
    , CAST(suspension_duration AS string)     AS suspension_duration
    , CAST(decision_name AS string)           AS decision_name
FROM {{ source('source_knt', 'raw_penalty_decision') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
/*
*--------------------------------------------------------------------*
* Program code: dtm_inspection_team_violation_behavior_dim
* Program name: Inspection Team Violation Behavior Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Doi INNER JOIN -> LEFT JOIN voi violation_behavior
*                       (truoc do INNER JOIN lam mat het cac dong khong
*                       match thay vi gan 'Khac'), bo sung COALESCE
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA Nhom 3/8] BO COALESCE 'Khac': violation_behavior_nm
*                       la NULL khi hanh vi khong ACTIVE/khong co; KPI loc violation_behavior_nm IS NOT NULL
*                       (BA bo nhom 'Khac'). Dim scd4a insert theo TEN -> khong can ALTER dim; flat
*                       tt_fct_inspection_team_violation_behavior_flat can MODIFY COLUMN violation_behavior_nm
*                       Nullable(String) (xem scratch/alter_tt_lld_20261001.sql).
* 2026-10-25		tuan.nguyenvanb		[DESIGN tra loi, LLD mart] violation_record_behavior_code = CONCAT(violation_record_code, '_', violation_behavior_code) (atomic bo cot violation_record_behavior_code). Cot output khong doi; gia tri code/dim_id doi.
*--------------------------------------------------------------------*
*/

WITH vrb AS (
    SELECT
        CONCAT(violation_record_code, '_', violation_behavior_code) AS violation_record_behavior_code,
        violation_behavior_id,
        src_stm_code
    FROM {{ ref('atm_violation_record_x_violation_behavior_relationship') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_RECORD_BEHAVIOR'
),

vb AS (
    SELECT
        violation_behavior_id,
        violation_behavior_nm
    FROM {{ ref('atm_violation_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
        AND life_cycle_status_code = 'ACTIVE'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_RECORD_BEHAVIOR', 'vrb.violation_record_behavior_code') }} AS string) AS inspection_team_violation_behavior_dim_id,
    CAST(vrb.violation_record_behavior_code AS string)                                                                              AS violation_record_behavior_code,
    CAST(vb.violation_behavior_nm AS string)                                                                                         AS violation_behavior_nm,
    CAST(vrb.src_stm_code AS string)                                                                                                AS src_stm_code
FROM vrb
LEFT JOIN vb
    ON vb.violation_behavior_id = vrb.violation_behavior_id

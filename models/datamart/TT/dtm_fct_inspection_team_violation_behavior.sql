/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_inspection_team_violation_behavior
* Program name: Fact Inspection Team Violation Behavior
* NEW mapping = UNION(Nguon A: qua VIOLATION_RECORD, Nguon B: qua VIOLATION_CASE)
*   dedupe theo inspection_team_violation_behavior_dim_id (theo mapping CSV)
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Bo sung cot ky thuat data_dt (yyyy-MM-dd) - dung lam
*                       partition_by moi (append) va la cot loc/xoa
*                       duy nhat cho tang flat ClickHouse
* 2026-09-28   tuan.nguyenvanb   [LLD moi tu Data Modeler] Doi ten cot
*                       calendar_dt_dim_id -> decision_dt_dim_id (khong doi
*                       logic/gia tri, chi doi ten cho dung ngu nghia). Bat
*                       lai dieu kien loc ngay nghiep vu decision_dt =
*                       :etl_date o ca 2 nguon A/B (truoc do bi comment,
*                       khong loc gi ca).
* 2026-09-28b  tuan.nguyenvanb   [TAM THOI - theo yeu cau] Comment lai
*                       dieu kien decision_dt = :etl_date de 1 lan chay bat
*                       ky ngay nao cung ra DU TOAN BO lich su. CANH BAO:
*                       model la incremental_rebase/append, partition
*                       theo data_dt (ngay CHAY, khong phai decision_dt) -
*                       neu de nguyen chay hang ngay lau dai, MOI ngay se
*                       ghi DU BAN SAO toan bo lich su vao partition ngay
*                       do -> phinh du lieu vo han. Chi dung tam cho 1 lan
*                       load, nho BAT LAI dieu kien nay truoc khi van hanh
*                       chay hang ngay that.
* 2026-10-25		tuan.nguyenvanb		[DESIGN tra loi, LLD mart] violation_record_behavior_code = CONCAT(violation_record_code, '_', violation_behavior_code) de lookup dim (atomic bo cot violation_record_behavior_code).
* 2026-11-03		tuan.nguyenvanb		[LLD 2026-11-03, BA bo AND NAME IS NOT NULL - O_TT_24] Them NGUON C: doan khong co hanh vi
*                       ACTIVE (qua nguon A/B) van co 1 dong, FK hanh vi = NULL (nhan 'Khong xac dinh' xu ly o BI/flat).
*                       Nguon A/B chi lay hanh vi ACTIVE (vrb INNER JOIN violation_behavior ACTIVE). Dedupe chi ap dung
*                       cho A/B (dong NULL cua nguon C khong duoc gop lai). Cot output khong doi, FK hanh vi nay NULLABLE.
*--------------------------------------------------------------------*
*/

WITH vrb AS (
    SELECT
        CONCAT(r.violation_record_code, '_', r.violation_behavior_code) AS violation_record_behavior_code,
        r.violation_record_id
    FROM {{ ref('atm_violation_record_x_violation_behavior_relationship') }}_hstr r
    INNER JOIN {{ ref('atm_violation_behavior') }}_hstr vb
        ON vb.violation_behavior_id = r.violation_behavior_id
        AND vb.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND vb.ds_rcrd_st = 'ACTIVE'
        AND vb.src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
        AND vb.life_cycle_status_code = 'ACTIVE'
    WHERE r.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND r.ds_rcrd_st = 'ACTIVE'
        AND r.src_stm_code = 'THANHTRA_VIOLATION_RECORD_BEHAVIOR'
),

-- ===== NGUON A: qua Violation Record truc tiep (giu nguyen code cu) =====
vr_a AS (
    SELECT
        violation_record_id,
        inspection_team_id,
        inspection_team_code
    FROM {{ ref('atm_violation_record') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_RECORD'
        AND inspection_team_id IS NOT NULL
),

in_te_a AS (
    SELECT
        inspection_team_id,
        decision_dt
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

nguon_a AS (
    SELECT
        CAST(date_format(in_te_a.decision_dt, 'yyyyMMdd') AS STRING)                                 AS decision_dt_dim_id,
        CAST(itd.inspection_team_dim_id AS string)                       AS inspection_team_dim_id,
        CAST(itvbd.inspection_team_violation_behavior_dim_id AS string)  AS inspection_team_violation_behavior_dim_id
    FROM vrb
    INNER JOIN vr_a
        ON vr_a.violation_record_id = vrb.violation_record_id
    INNER JOIN in_te_a
        ON in_te_a.inspection_team_id = vr_a.inspection_team_id
    LEFT JOIN {{ ref('dtm_inspection_team_dim') }}_hstr itd
        ON itd.inspection_team_code = vr_a.inspection_team_code
        AND itd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND itd.ds_rcrd_st = 'ACTIVE'
    LEFT JOIN {{ ref('dtm_inspection_team_violation_behavior_dim') }}_hstr itvbd
        ON itvbd.violation_record_behavior_code = vrb.violation_record_behavior_code
        AND itvbd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND itvbd.ds_rcrd_st = 'ACTIVE'
),

-- ===== NGUON B (MOI): qua Violation Case -> Violation Case Received Document =====
vi_ca_re_do AS (
    SELECT
        violation_case_id,
        violation_record_id
    FROM {{ ref('atm_violation_case_received_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE_RECEIVED_DOCUMENT'
        AND violation_record_id IS NOT NULL
),

vi_ca AS (
    SELECT
        violation_case_id,
        inspection_team_id,
        inspection_team_code
    FROM {{ ref('atm_violation_case') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE'
        AND inspection_team_id IS NOT NULL
),

in_te_b AS (
    SELECT
        inspection_team_id,
        decision_dt
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

nguon_b AS (
    SELECT
        CAST(date_format(in_te_b.decision_dt, 'yyyyMMdd') AS STRING)                                 AS decision_dt_dim_id,
        CAST(itd.inspection_team_dim_id AS string)                       AS inspection_team_dim_id,
        CAST(itvbd.inspection_team_violation_behavior_dim_id AS string)  AS inspection_team_violation_behavior_dim_id
    FROM vrb
    INNER JOIN vi_ca_re_do
        ON vi_ca_re_do.violation_record_id = vrb.violation_record_id
    INNER JOIN vi_ca
        ON vi_ca.violation_case_id = vi_ca_re_do.violation_case_id
    INNER JOIN in_te_b
        ON in_te_b.inspection_team_id = vi_ca.inspection_team_id
    LEFT JOIN {{ ref('dtm_inspection_team_dim') }}_hstr itd
        ON itd.inspection_team_code = vi_ca.inspection_team_code
        AND itd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND itd.ds_rcrd_st = 'ACTIVE'
    LEFT JOIN {{ ref('dtm_inspection_team_violation_behavior_dim') }}_hstr itvbd
        ON itvbd.violation_record_behavior_code = vrb.violation_record_behavior_code
        AND itvbd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND itvbd.ds_rcrd_st = 'ACTIVE'
),

-- ===== NGUON C (MOI 2026-11-03): doan KHONG co hanh vi ACTIVE o nguon A/B -> FK hanh vi NULL =====
te_co_hv AS (
    SELECT vr_a.inspection_team_id AS inspection_team_id
    FROM vrb
    INNER JOIN vr_a
        ON vr_a.violation_record_id = vrb.violation_record_id
    UNION
    SELECT vi_ca.inspection_team_id AS inspection_team_id
    FROM vrb
    INNER JOIN vi_ca_re_do
        ON vi_ca_re_do.violation_record_id = vrb.violation_record_id
    INNER JOIN vi_ca
        ON vi_ca.violation_case_id = vi_ca_re_do.violation_case_id
),

in_te_c AS (
    SELECT
        inspection_team_id,
        inspection_team_code,
        decision_dt
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

nguon_c AS (
    SELECT
        CAST(date_format(in_te_c.decision_dt, 'yyyyMMdd') AS STRING)       AS decision_dt_dim_id,
        CAST(itd.inspection_team_dim_id AS string)                              AS inspection_team_dim_id,
        CAST(NULL AS string)                                              AS inspection_team_violation_behavior_dim_id
    FROM in_te_c
    LEFT JOIN te_co_hv
        ON te_co_hv.inspection_team_id = in_te_c.inspection_team_id
    LEFT JOIN {{ ref('dtm_inspection_team_dim') }}_hstr itd
        ON itd.inspection_team_code = in_te_c.inspection_team_code
        AND itd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND itd.ds_rcrd_st = 'ACTIVE'
    WHERE te_co_hv.inspection_team_id IS NULL
),

-- ===== UNION nguon A/B + dedupe (chi A/B) theo inspection_team_violation_behavior_dim_id =====
unioned AS (
    SELECT * FROM nguon_a
    UNION ALL
    SELECT * FROM nguon_b
),

deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY inspection_team_violation_behavior_dim_id
            ORDER BY inspection_team_violation_behavior_dim_id
        ) AS rn
    FROM unioned
),

ab AS (
    SELECT
        decision_dt_dim_id,
        inspection_team_dim_id,
        inspection_team_violation_behavior_dim_id
    FROM deduped
    WHERE rn = 1
),

all_src AS (
    SELECT * FROM ab
    UNION ALL
    SELECT * FROM nguon_c
)

SELECT
    decision_dt_dim_id,
    inspection_team_dim_id,
    inspection_team_violation_behavior_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM all_src

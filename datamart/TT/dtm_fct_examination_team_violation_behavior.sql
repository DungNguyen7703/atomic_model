/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_examination_team_violation_behavior
* Program name: Fact Examination Team Violation Behavior
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Sua nham entity: file nay truoc do bi copy 100%
*                       tu fct_inspection_team_violation_behavior (dung
*                       inspection_team thay vi examination_team). Da sua
*                       lai dung entity examination_team.
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

-- ===== NGUON A: qua Violation Record truc tiep =====
vr_a AS (
    SELECT
        violation_record_id,
        examination_team_id,
        examination_team_code
    FROM {{ ref('atm_violation_record') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_RECORD'
        AND examination_team_id IS NOT NULL
),

ex_te_a AS (
    SELECT
        examination_team_id,
        decision_dt
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

nguon_a AS (
    SELECT
        CAST(date_format(ex_te_a.decision_dt, 'yyyyMMdd') AS STRING)                                 AS decision_dt_dim_id,
        CAST(etd.examination_team_dim_id AS string)                       AS examination_team_dim_id,
        CAST(etvbd.examination_team_violation_behavior_dim_id AS string)  AS examination_team_violation_behavior_dim_id
    FROM vrb
    INNER JOIN vr_a
        ON vr_a.violation_record_id = vrb.violation_record_id
    INNER JOIN ex_te_a
        ON ex_te_a.examination_team_id = vr_a.examination_team_id
    LEFT JOIN {{ ref('dtm_examination_team_dim') }}_hstr etd
        ON etd.examination_team_code = vr_a.examination_team_code
        AND etd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND etd.ds_rcrd_st = 'ACTIVE'
    LEFT JOIN {{ ref('dtm_examination_team_violation_behavior_dim') }}_hstr etvbd
        ON etvbd.violation_record_behavior_code = vrb.violation_record_behavior_code
        AND etvbd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND etvbd.ds_rcrd_st = 'ACTIVE'
),

-- ===== NGUON B: qua Violation Case -> Violation Case Received Document =====
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
        examination_team_id,
        examination_team_code
    FROM {{ ref('atm_violation_case') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE'
        AND examination_team_id IS NOT NULL
),

ex_te_b AS (
    SELECT
        examination_team_id,
        decision_dt
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

nguon_b AS (
    SELECT
        CAST(date_format(ex_te_b.decision_dt, 'yyyyMMdd') AS STRING)                                 AS decision_dt_dim_id,
        CAST(etd.examination_team_dim_id AS string)                       AS examination_team_dim_id,
        CAST(etvbd.examination_team_violation_behavior_dim_id AS string)  AS examination_team_violation_behavior_dim_id
    FROM vrb
    INNER JOIN vi_ca_re_do
        ON vi_ca_re_do.violation_record_id = vrb.violation_record_id
    INNER JOIN vi_ca
        ON vi_ca.violation_case_id = vi_ca_re_do.violation_case_id
    INNER JOIN ex_te_b
        ON ex_te_b.examination_team_id = vi_ca.examination_team_id
    LEFT JOIN {{ ref('dtm_examination_team_dim') }}_hstr etd
        ON etd.examination_team_code = vi_ca.examination_team_code
        AND etd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND etd.ds_rcrd_st = 'ACTIVE'
    LEFT JOIN {{ ref('dtm_examination_team_violation_behavior_dim') }}_hstr etvbd
        ON etvbd.violation_record_behavior_code = vrb.violation_record_behavior_code
        AND etvbd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND etvbd.ds_rcrd_st = 'ACTIVE'
),

-- ===== NGUON C (MOI 2026-11-03): doan KHONG co hanh vi ACTIVE o nguon A/B -> FK hanh vi NULL =====
te_co_hv AS (
    SELECT vr_a.examination_team_id AS examination_team_id
    FROM vrb
    INNER JOIN vr_a
        ON vr_a.violation_record_id = vrb.violation_record_id
    UNION
    SELECT vi_ca.examination_team_id AS examination_team_id
    FROM vrb
    INNER JOIN vi_ca_re_do
        ON vi_ca_re_do.violation_record_id = vrb.violation_record_id
    INNER JOIN vi_ca
        ON vi_ca.violation_case_id = vi_ca_re_do.violation_case_id
),

ex_te_c AS (
    SELECT
        examination_team_id,
        examination_team_code,
        decision_dt
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
        --AND decision_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

nguon_c AS (
    SELECT
        CAST(date_format(ex_te_c.decision_dt, 'yyyyMMdd') AS STRING)       AS decision_dt_dim_id,
        CAST(etd.examination_team_dim_id AS string)                              AS examination_team_dim_id,
        CAST(NULL AS string)                                              AS examination_team_violation_behavior_dim_id
    FROM ex_te_c
    LEFT JOIN te_co_hv
        ON te_co_hv.examination_team_id = ex_te_c.examination_team_id
    LEFT JOIN {{ ref('dtm_examination_team_dim') }}_hstr etd
        ON etd.examination_team_code = ex_te_c.examination_team_code
        AND etd.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND etd.ds_rcrd_st = 'ACTIVE'
    WHERE te_co_hv.examination_team_id IS NULL
),

-- ===== UNION nguon A/B + dedupe (chi A/B) theo examination_team_violation_behavior_dim_id =====
unioned AS (
    SELECT * FROM nguon_a
    UNION ALL
    SELECT * FROM nguon_b
),

deduped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY examination_team_violation_behavior_dim_id
            ORDER BY examination_team_violation_behavior_dim_id
        ) AS rn
    FROM unioned
),

ab AS (
    SELECT
        decision_dt_dim_id,
        examination_team_dim_id,
        examination_team_violation_behavior_dim_id
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
    examination_team_dim_id,
    examination_team_violation_behavior_dim_id,
    date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyy-MM-dd') AS data_dt
FROM all_src

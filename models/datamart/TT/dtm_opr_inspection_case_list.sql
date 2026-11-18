/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_inspection_case_list
* Program name: Operational Inspection Case List
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA STT 5] status_code: start = COALESCE(start_dt, ky tu ngay),
*                       end = COALESCE(end_dt, ky den ngay); co start va (end NULL hoac end > etl_date) -> IN_PROGRESS;
*                       co start va end <= etl_date -> COMPLETED; ca 2 NULL -> NOT_STARTED. Gia tri phu thuoc NGAY ETL
*                       (sysdate trong SQL BA) -> can nap lai hang ngay. Cot dau ra KHONG doi.
* 2026-11-03   tuan.nguyenvanb   [LLD 2026-11-03, BA O_TT_25] Them cot violation_behavior_nm (PK ghep voi ma luot doi tuong,
*                       vi tri truoc src_stm_code). Grain = luot doi tuong x hanh vi: gop 2 nhanh (bien ban truc tiep / qua ho so
*                       vu viec) bang UNION, KHONG loc ord = 1; COALESCE 'Khong xac dinh'. unique_key doi sang
*                       [ma luot doi tuong, violation_behavior_nm] (xem schema_dtm_tt.yml).
*--------------------------------------------------------------------*
*/

WITH in_te_tg AS (
    SELECT
        inspection_team_target_code,
        inspection_team_code,
        target_nm,
        target_tp_code,
        inspection_team_id,
        src_stm_code
    FROM {{ ref('atm_inspection_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM_TARGET'
),

in_te AS (
    SELECT
        inspection_team_id,
        form_tp_code,
        COALESCE(start_dt, inspection_period_from_dt) AS effective_start_dt,
        COALESCE(end_dt, inspection_period_to_dt)     AS effective_end_dt,
        decision_dt
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
),

-- Hanh vi vi pham cua doan: 2 nhanh (A: qua bien ban truc tiep, B: qua ho so vu viec), UNION (distinct) theo LLD/BA
vr AS (
    SELECT
        violation_record_id,
        inspection_team_id
    FROM {{ ref('atm_violation_record') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_RECORD'
),

vrb AS (
    SELECT
        violation_record_id,
        violation_behavior_id
    FROM {{ ref('atm_violation_record_x_violation_behavior_relationship') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
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
),

vi_ca AS (
    SELECT
        violation_case_id,
        inspection_team_id
    FROM {{ ref('atm_violation_case') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE'
),

vi_ca_re_do AS (
    SELECT
        violation_case_id,
        violation_record_id
    FROM {{ ref('atm_violation_case_received_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

behavior_src AS (
    SELECT
        in_te.inspection_team_id,
        vb.violation_behavior_nm
    FROM in_te
    LEFT JOIN vr
        ON vr.inspection_team_id = in_te.inspection_team_id
    LEFT JOIN vrb
        ON vrb.violation_record_id = vr.violation_record_id
    LEFT JOIN vb
        ON vb.violation_behavior_id = vrb.violation_behavior_id
    UNION
    SELECT
        in_te.inspection_team_id,
        vb.violation_behavior_nm
    FROM in_te
    LEFT JOIN vi_ca
        ON vi_ca.inspection_team_id = in_te.inspection_team_id
    LEFT JOIN vi_ca_re_do
        ON vi_ca_re_do.violation_case_id = vi_ca.violation_case_id
    LEFT JOIN vr vr2
        ON vr2.violation_record_id = vi_ca_re_do.violation_record_id
    LEFT JOIN vrb vrb2
        ON vrb2.violation_record_id = vr2.violation_record_id
    LEFT JOIN vb
        ON vb.violation_behavior_id = vrb2.violation_behavior_id
)

SELECT
    CAST(in_te_tg.inspection_team_target_code AS string)    AS inspection_team_target_code,
    CAST(in_te_tg.inspection_team_code AS string)           AS inspection_team_code,
    CAST(in_te_tg.target_nm AS string)                      AS target_nm,
    CAST(in_te_tg.target_tp_code AS string)                 AS target_tp_code,
    CAST(in_te.form_tp_code AS string)                      AS form_tp_code,
    CAST(
        CASE
            WHEN in_te.effective_start_dt IS NOT NULL AND in_te.effective_end_dt IS NULL                                      THEN 'IN_PROGRESS'
            WHEN in_te.effective_start_dt IS NOT NULL AND in_te.effective_end_dt >  to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN 'IN_PROGRESS'
            WHEN in_te.effective_start_dt IS NOT NULL AND in_te.effective_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN 'COMPLETED'
            WHEN in_te.effective_start_dt IS NULL     AND in_te.effective_end_dt IS NULL                                      THEN 'NOT_STARTED'
        END
    AS string)                                              AS status_code,
    CAST(in_te.decision_dt AS date)                         AS decision_dt,
    CAST(YEAR(in_te.decision_dt) AS int)                    AS decision_year,
    CAST(COALESCE(behavior_src.violation_behavior_nm, 'Không xác định') AS string) AS violation_behavior_nm,
    CAST(in_te_tg.src_stm_code AS string)                   AS src_stm_code
FROM in_te_tg
INNER JOIN in_te
    ON in_te.inspection_team_id = in_te_tg.inspection_team_id
LEFT JOIN behavior_src
    ON behavior_src.inspection_team_id = in_te_tg.inspection_team_id

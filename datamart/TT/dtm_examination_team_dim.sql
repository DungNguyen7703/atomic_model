/*
*--------------------------------------------------------------------*
* Program code: dtm_examination_team_dim
* Program name: Examination Team Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28   tuan.nguyenvanb   [LLD moi tu Data Modeler] Bo attribute
*                       Content - khong con trong LLD (dropped). Model nay
*                       la scd4a (insert theo TEN cot qua danh sach tuong
*                       minh), nen bo cot khong lam lech vi tri cac cot con
*                       lai - chi can DROP COLUMN ben Iceberg (xem DDL kem
*                       theo) cho ca bang current va _hstr.
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA STT 6,7,10] Them effective_start_dt/effective_end_dt =
*                       COALESCE(start_dt, ky kiem tra tu ngay) / COALESCE(end_dt, ky kiem tra den ngay),
*                       dat sau end_dt. Dim scd4a insert theo TEN -> ADD COLUMN an toan.
*--------------------------------------------------------------------*
*/

WITH ex_te AS (
    SELECT
        examination_team_code,
        start_dt,
        end_dt,
        examination_period_from_dt,
        examination_period_to_dt,
        src_stm_code
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
)


SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', 'ex_te.examination_team_code') }} AS string) AS examination_team_dim_id,
    CAST(ex_te.examination_team_code AS string)                               AS examination_team_code,
    CAST(ex_te.start_dt AS date)                                              AS start_dt,
    CAST(ex_te.end_dt AS date)                                                AS end_dt,
    CAST(COALESCE(ex_te.start_dt, ex_te.examination_period_from_dt) AS date)  AS effective_start_dt,
    CAST(COALESCE(ex_te.end_dt, ex_te.examination_period_to_dt) AS date)      AS effective_end_dt,
    CAST(ex_te.src_stm_code AS string)                                        AS src_stm_code
FROM ex_te

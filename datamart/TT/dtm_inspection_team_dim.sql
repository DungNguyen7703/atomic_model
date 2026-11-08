/*
*--------------------------------------------------------------------*
* Program code: dtm_inspection_team_dim
* Program name: Inspection Team Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA STT 1,2,5,6,7] Them effective_start_dt/effective_end_dt =
*                       COALESCE(start_dt, ky thanh tra tu ngay) / COALESCE(end_dt, ky thanh tra den ngay),
*                       dat sau end_dt. Dim scd4a insert theo TEN -> ADD COLUMN an toan (scratch: xem tra loi).
* 2026-10-25		tuan.nguyenvanb		[DESIGN tra loi, BA chot] Bo cot content (atomic inspection_team bo cot). CAN ALTER DROP COLUMN content o mart (main + _hstr) va 3 flat ClickHouse.
*--------------------------------------------------------------------*
*/

WITH in_te AS (
    SELECT
        inspection_team_code,
        start_dt,
        end_dt,
        inspection_period_from_dt,
        inspection_period_to_dt,
        src_stm_code
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
)

SELECT
    CAST({{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', 'in_te.inspection_team_code') }} AS string) AS inspection_team_dim_id,
    CAST(in_te.inspection_team_code AS string)                               AS inspection_team_code,
    CAST(in_te.start_dt AS date)                                             AS start_dt,
    CAST(in_te.end_dt AS date)                                               AS end_dt,
    CAST(COALESCE(in_te.start_dt, in_te.inspection_period_from_dt) AS date)  AS effective_start_dt,
    CAST(COALESCE(in_te.end_dt, in_te.inspection_period_to_dt) AS date)      AS effective_end_dt,
    CAST(in_te.src_stm_code AS string)                                       AS src_stm_code
FROM in_te

/*
*--------------------------------------------------------------------*
* Program code: dtm_depository_member_dim
* Program name: Depository Member Dimension
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-04		claude				Tao moi theo LLD TKNB 7ae22069 (TKNB Nhom 13 TTLK01): Dim TVLK, BK = depository_member_nm
*									(cell_val cua column_path 'TVLK'), khu trung SELECT DISTINCT theo BK.
*--------------------------------------------------------------------*
*/

WITH statistical_report AS (
    SELECT DISTINCT
        cell_val,
        src_stm_code
    FROM {{ ref('atm_internal_statistical_report') }}
    WHERE src_stm_code = 'ISS_INTERNAL_STATISTICAL_REPORT'
        AND ds_rcrd_st = 'ACTIVE'
        AND rpt_code = 'TTLK01'
        AND rpt_submission_stm_code = 'ICP'
        AND submission_status_code IN ('SUBMITTED','LATE_SUBMITTED')
        AND LAST_DAY(TO_DATE(CONCAT('01/', period_val), 'dd/MM/yyyy')) <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND column_path = 'TVLK'
        AND cell_val IS NOT NULL
)

SELECT
    CAST({{ generate_surrogate_key_bigint('ISS_INTERNAL_STATISTICAL_REPORT', 'cell_val') }} AS string) AS depository_member_dim_id,
    CAST(cell_val AS string)                                        AS depository_member_nm,
    CAST(src_stm_code AS string)                                    AS src_stm_code
FROM statistical_report

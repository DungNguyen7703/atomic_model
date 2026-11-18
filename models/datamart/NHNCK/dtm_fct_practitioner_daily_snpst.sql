/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_practitioner_daily_snpst
* Program name: Dtm Fct Practitioner Daily Snpst
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-03		claude				Đồng bộ LLD 2026-10-23/2026-11-02: bỏ cột violation_record_dt (LLD đã loại);
*                                       thêm 4 cột Indicator practicing_indicator / concurrent_employment_indicator /
*                                       insufficient_training_indicator / no_practice_3_years_indicator
*                                       (BA sau UAT 27/10, O_NHNCK_35). LLD viết EXISTS/subquery tương quan theo
*                                       từng NHN -> chuyển thành CTE gộp theo sp_code rồi LEFT JOIN (cùng kết quả).
*                                       Báo cáo tổ chức đọc từ atm_sp_organization_employment_report KHÔNG _hstr,
*                                       cùng cách dtm_opr_practitioner_employment_hist.
*--------------------------------------------------------------------*
*/

WITH violations AS (
    SELECT
        sp_conduct_violation_code,
        sp_code,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_conduct_violation') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_VIOLATIONS'
),

decisions AS (
    SELECT
        sp_license_decision_document_id,
        decision_signed_dt
    FROM {{ ref('atm_sp_license_decision_document') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_DECISIONS'
),

practitioner AS (
    SELECT
        securities_practitioner_dim_id,
        practitioner_code,
        practice_status_code,
        birth_dt,
        birth_year
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st  = 'ACTIVE'
      AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

certificates AS (
    SELECT
        sp_code,
        MIN(issue_dt)                                                                  AS first_license_issue_dt,
        COUNT(*)                                                                       AS certificate_cnt,
        MAX(YEAR(issue_dt))                                                            AS max_issue_year,
        MAX(CASE WHEN status_code IN ('0','1','2','5')
                  AND issue_dt < trunc(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'YEAR')
                 THEN 1 ELSE 0 END)                                                    AS has_monitored_certificate
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
    GROUP BY sp_code
),

confirmed_violations AS (
    SELECT
        violations.sp_conduct_violation_code,
        violations.sp_code,
        decisions.decision_signed_dt
    FROM violations
    INNER JOIN decisions
        ON  decisions.sp_license_decision_document_id = violations.sp_license_decision_document_id
),

-- Báo cáo tổ chức đã xác nhận (Status = '2' hoặc Organization Status At Report = '2'), có ngày vào làm
confirmed_employment AS (
    SELECT
        sp_code,
        securities_organization_reference_code,
        hire_dt,
        termination_dt
    FROM {{ ref('atm_sp_organization_employment_report') }}
    WHERE src_stm_code = 'NHNCK_ORGANIZATION_REPORTS'
      AND (status_code = '2' OR organization_status_code_at_rpt = '2')
      AND hire_dt IS NOT NULL
),

employment_agg AS (
    SELECT
        sp_code,
        MAX(CASE WHEN hire_dt <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
                  AND (termination_dt IS NULL OR termination_dt > to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'))
                 THEN 1 ELSE 0 END)                                                    AS has_active_period,
        MAX(termination_dt)                                                            AS max_termination_dt
    FROM confirmed_employment
    GROUP BY sp_code
),

-- Khoảng trống giữa 2 kỳ làm việc liền nhau (sắp theo hire_dt) đủ 36 tháng
employment_gap AS (
    SELECT DISTINCT sp_code
    FROM (
        SELECT
            sp_code,
            hire_dt,
            LAG(termination_dt) OVER (
                PARTITION BY sp_code
                ORDER BY hire_dt, securities_organization_reference_code
            ) AS prev_termination_dt
        FROM confirmed_employment
    ) g
    WHERE prev_termination_dt IS NOT NULL
      AND add_months(prev_termination_dt, 36) <= hire_dt
),

-- Làm việc đồng thời tại 2 tổ chức khác nhau trong cửa sổ lũy kế 01/01 năm snapshot -> ngày snapshot
concurrent_employment AS (
    SELECT DISTINCT a.sp_code
    FROM confirmed_employment a
    INNER JOIN confirmed_employment b
        ON  b.sp_code = a.sp_code
        AND b.securities_organization_reference_code <> a.securities_organization_reference_code
    WHERE GREATEST(a.hire_dt, b.hire_dt, trunc(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'YEAR'))
        < LEAST(
              COALESCE(date_add(a.termination_dt, 1), DATE '9999-12-31'),
              COALESCE(date_add(b.termination_dt, 1), DATE '9999-12-31'),
              date_add(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 1)
          )
),

-- Số giờ tập huấn Hoàn thành từ 01/01 năm snapshot đến ngày snapshot
training_hours_ytd AS (
    SELECT
        sp_code,
        SUM(training_hours) AS total_training_hours
    FROM {{ ref('atm_sp_post_certification_training_result') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_POST_CERT_TRAINING_RESULTS'
      AND training_result_status_code = '1'
      AND training_end_dt >= trunc(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'YEAR')
      AND training_end_dt <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    GROUP BY sp_code
)

SELECT
    CAST(practitioner.securities_practitioner_dim_id AS string)                                        AS practitioner_dim_id,
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                            AS snpst_dt_dim_id,
    CAST(YEAR(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')) - COALESCE(YEAR(practitioner.birth_dt), practitioner.birth_year) AS int) AS age,
    CAST(CASE WHEN confirmed_violations.sp_conduct_violation_code IS NOT NULL THEN 'Y'
              ELSE 'N' END AS string)                                                                  AS has_active_violation,
    CAST(certificates.first_license_issue_dt AS date)                                                  AS first_license_dt,
    -- Đang hành nghề: có báo cáo xác nhận VÀ (trạng thái hành nghề = '1' HOẶC có kỳ làm việc đang hiệu lực)
    CAST(CASE WHEN employment_agg.sp_code IS NOT NULL
               AND (practitioner.practice_status_code = '1' OR employment_agg.has_active_period = 1)
              THEN 'Y' ELSE 'N' END AS string)                                                         AS practicing_indicator,
    CAST(CASE WHEN concurrent_employment.sp_code IS NOT NULL THEN 'Y' ELSE 'N' END AS string)          AS concurrent_employment_indicator,
    -- Chưa đủ 8 giờ/năm; miễn nếu chỉ có đúng 1 CCHN cấp trong năm snapshot; chỉ xét NHN có CCHN theo dõi cấp trước 01/01
    CAST(CASE WHEN COALESCE(training_hours_ytd.total_training_hours, 0) < 8
               AND NOT (COALESCE(certificates.certificate_cnt, 0) = 1
                        AND certificates.max_issue_year = YEAR(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')))
               AND COALESCE(certificates.has_monitored_certificate, 0) = 1
              THEN 'Y' ELSE 'N' END AS string)                                                         AS insufficient_training_indicator,
    -- Không hành nghề 3 năm liên tục: không có kỳ đang hiệu lực VÀ (nghỉ hết >= 36 tháng | gap >= 36 tháng | chưa có báo cáo, CCHN sớm nhất >= 36 tháng)
    CAST(CASE WHEN COALESCE(employment_agg.has_active_period, 0) = 0
               AND (   (employment_agg.max_termination_dt IS NOT NULL
                        AND add_months(employment_agg.max_termination_dt, 36) <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'))
                    OR employment_gap.sp_code IS NOT NULL
                    OR (employment_agg.sp_code IS NULL
                        AND certificates.first_license_issue_dt IS NOT NULL
                        AND add_months(certificates.first_license_issue_dt, 36) <= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')))
              THEN 'Y' ELSE 'N' END AS string)                                                         AS no_practice_3_years_indicator
FROM practitioner
LEFT JOIN confirmed_violations
    ON confirmed_violations.sp_code = practitioner.practitioner_code
LEFT JOIN certificates
    ON certificates.sp_code = practitioner.practitioner_code
LEFT JOIN employment_agg
    ON employment_agg.sp_code = practitioner.practitioner_code
LEFT JOIN employment_gap
    ON employment_gap.sp_code = practitioner.practitioner_code
LEFT JOIN concurrent_employment
    ON concurrent_employment.sp_code = practitioner.practitioner_code
LEFT JOIN training_hours_ytd
    ON training_hours_ytd.sp_code = practitioner.practitioner_code

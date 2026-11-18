/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_360_profile
* Program name: Dtm Opr Practitioner 360 Profile
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		nguyet.do			BA cập nhật lấy report mới nhất: giữ partition theo sp_id (BA partition
*                                       thêm hire/termination sẽ nhân dòng), bổ sung tie-breaker
*                                       termination_dt DESC NULLS FIRST, rpt_code DESC cho kết quả ổn định
* 2026-11-03		claude				Đồng bộ LLD 2026-11-02: practice_status_code/nm dẫn xuất từ practice_status_code của
*                                       dim (2/3/0/1/4) kết hợp báo cáo tổ chức mới nhất (lr) tại etl_date, ELSE '9';
*                                       practice_status_nm lấy nhãn tiếng Việt theo CASE của LLD (bỏ lookup cl_value).
*                                       lr xếp theo data_dt DESC NULLS LAST, termination_dt DESC NULLS FIRST,
*                                       hire_dt DESC NULLS LAST (theo LLD); giữ rpt_code DESC làm tie-breaker cuối.
* 2026-11-05		claude				Đồng bộ LLD 2026-11-03 (O_NHNCK_43..46): thêm identification_tp_code (chuyển từ
*                                       Data Explorer đã bãi bỏ) — LEFT JOIN ip_alternative_identification theo sp_id, không lọc loại.
*--------------------------------------------------------------------*
*/

WITH practitioner AS (
    SELECT
        practitioner_code AS sp_code,
        full_nm,
        birth_dt,
        birth_year,
        education_level_code,
        practice_status_code,
        src_stm_code,
        nationality_code,
        securities_practitioner_dim_id,
        workplace_nm
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

geographic_area AS (
    SELECT
        geographic_area_code,
        geographic_area_nm
    FROM {{ ref('atm_geographic_area') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_COUNTRY'
        AND geographic_area_tp_code = 'COUNTRY'
),

ip_alternative_id AS (
    SELECT
        identification_nbr,
        identification_tp_code,
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

active_certificate AS (
    SELECT
        sp_license_certificate_tp_code,
        certificate_nbr,
        sp_id
    FROM (
        SELECT
            sp_license_certificate_tp_code,
            certificate_nbr,
            sp_id,
            ROW_NUMBER() OVER (
                PARTITION BY sp_id 
                ORDER BY issue_dt DESC
            ) AS rn
        FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
    ) t
    WHERE rn = 1
),

employment_report_latest AS (
    SELECT
        sp_id,
        hire_dt,
        termination_dt
    FROM (
        SELECT
            sp_id,
            hire_dt,
            termination_dt,
            ROW_NUMBER() OVER (
                PARTITION BY sp_id
                ORDER BY data_dt DESC NULLS LAST,
                    termination_dt DESC NULLS FIRST,
                    hire_dt DESC NULLS LAST,
                    CAST(sp_organization_employment_rpt_code AS bigint) DESC
            ) AS rn
        FROM {{ ref('atm_sp_organization_employment_report') }}
        WHERE src_stm_code = 'NHNCK_ORGANIZATION_REPORTS'
    ) t
    WHERE rn = 1
),

-- CTE trung gian: dẫn xuất practice_status_code/nm theo LLD (mã dim 2/3/0/1/4 + báo cáo tổ chức mới nhất tại etl_date)
practitioner_enriched AS (
    SELECT
        p.*,
        CASE
            WHEN p.practice_status_code = '2' THEN '2'
            WHEN p.practice_status_code = '3' THEN '3'
            WHEN p.practice_status_code = '0'
                 OR (r.hire_dt IS NULL AND r.termination_dt IS NULL) THEN '0'
            WHEN p.practice_status_code = '1'
                 OR (r.hire_dt < to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                     AND (r.termination_dt IS NULL OR r.termination_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))) THEN '1'
            WHEN p.practice_status_code = '4'
                 OR (p.practice_status_code IS NULL
                     AND (r.hire_dt >= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                          OR r.termination_dt IS NOT NULL)) THEN '4'
            ELSE '9'
        END AS derived_practice_status_code,
        CASE
            WHEN p.practice_status_code = '2' THEN 'Thu hồi có cấp lại'
            WHEN p.practice_status_code = '3' THEN 'Thu hồi không cấp lại'
            WHEN p.practice_status_code = '0'
                 OR (r.hire_dt IS NULL AND r.termination_dt IS NULL) THEN 'Chưa hành nghề'
            WHEN p.practice_status_code = '1'
                 OR (r.hire_dt < to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                     AND (r.termination_dt IS NULL OR r.termination_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))) THEN 'Đang hoạt động'
            WHEN p.practice_status_code = '4'
                 OR (p.practice_status_code IS NULL
                     AND (r.hire_dt >= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                          OR r.termination_dt IS NOT NULL)) THEN 'Đã nghỉ'
            ELSE 'Trạng thái hành nghề khác'
        END AS derived_practice_status_nm
    FROM practitioner p
    LEFT JOIN employment_report_latest r
        ON r.sp_id = p.securities_practitioner_dim_id
),

category_value AS (
    SELECT
        cl_nm,
        cl_code,
        schema_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
),

certificate_type AS (
    SELECT
        certificate_tp_nm,
        sp_license_certificate_tp_code
    FROM {{ ref('atm_sp_license_certificate_type') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATES'
)

SELECT
    CAST(practitioner.sp_code AS string)                                              AS practitioner_code,
    CAST(practitioner.full_nm AS string)                                              AS full_nm,
    CAST(practitioner.birth_dt AS date)                                               AS birth_dt,
    CAST(YEAR(to_date('{{ var("etl_date") }}','yyyy-MM-dd')) - COALESCE(YEAR(practitioner.birth_dt), practitioner.birth_year) AS int) AS age,
    CAST(geographic_area.geographic_area_code AS string)                              AS nationality_code,
    CAST(geographic_area.geographic_area_nm AS string)                                AS nationality_nm,
    CAST(ip_alternative_id.identification_nbr AS string)                              AS identification_nbr,
    CAST(ip_alternative_id.identification_tp_code AS string)                          AS identification_tp_code,
    CAST(practitioner.education_level_code AS string)                                 AS education_level_code,
    CAST(education_level_lookup.cl_nm AS string)                                      AS education_level_nm,
    CAST(practitioner.workplace_nm AS string)                                         AS workplace_nm,
    CAST(practitioner.derived_practice_status_code AS string)                         AS practice_status_code,
    CAST(practitioner.derived_practice_status_nm AS string)                           AS practice_status_nm,
    CAST(active_certificate.sp_license_certificate_tp_code AS string)                 AS active_certificate_tp_code,
    CAST(certificate_type.certificate_tp_nm AS string)                                AS active_certificate_tp_nm,
    CAST(active_certificate.certificate_nbr AS string)                                AS active_certificate_nbr,
    CAST(practitioner.src_stm_code AS string)                                         AS src_stm_code
FROM practitioner_enriched practitioner
LEFT JOIN geographic_area
    ON geographic_area.geographic_area_code = practitioner.nationality_code
LEFT JOIN ip_alternative_id
    ON ip_alternative_id.ip_id = practitioner.securities_practitioner_dim_id
LEFT JOIN active_certificate
    ON active_certificate.sp_id = practitioner.securities_practitioner_dim_id
LEFT JOIN category_value education_level_lookup
    ON education_level_lookup.cl_code = practitioner.education_level_code
    AND education_level_lookup.schema_code = 'EDUCATIONAL_LEVEL'
LEFT JOIN certificate_type
    ON certificate_type.sp_license_certificate_tp_code = active_certificate.sp_license_certificate_tp_code

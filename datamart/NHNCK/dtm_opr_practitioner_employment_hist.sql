/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_employment_hist
* Program name: Dtm Opr Practitioner Employment Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		duc.luxuan			BA update Nhóm 8: dedupe 1 dòng / (NHN, tổ chức, hire_dt, termination_dt),
*										giữ báo cáo có ngày cấp CC mới nhất. Thêm tổ chức vào partition
*										(khác SQL BA) để không mất tổ chức khi trùng ngày.
* 2026-11-05		claude				Đồng bộ LLD 2026-11-03 (O_NHNCK_43..46): thêm practitioner_workplace_at_rpt
*										(K_NHNCK_132, Nhóm 6 'Đơn vị công tác') — direct từ atm_sp_organization_employment_report.
*--------------------------------------------------------------------*
* [NGHI VẤN ATOMIC] atm_sp_organization_employment_report chỉ nạp báo cáo có created_at = etl_date
* (append theo data_dt) -> báo cáo cũ cập nhật termination_dt về sau KHÔNG vào lại Atomic: NHN đã nghỉ
* vẫn có termination_dt NULL ("Đang làm việc"), dedupe cũng chạy trên giá trị cũ. Chờ Atomic xác nhận.
*--------------------------------------------------------------------*
*/

WITH employment_report AS (
    SELECT
        sp_code,
        sp_organization_employment_rpt_code,
        securities_organization_reference_code,
        practitioner_workplace_at_rpt,
        practitioner_position_at_rpt,
        practitioner_department_at_rpt,
        hire_dt,
        termination_dt,
        src_stm_code,
        securities_organization_reference_id
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY sp_code, securities_organization_reference_code, hire_dt, termination_dt
                ORDER BY certificate_issue_dt_at_rpt DESC NULLS LAST,
                         sp_organization_employment_rpt_code DESC
            ) AS rn
        FROM {{ ref('atm_sp_organization_employment_report') }}
        WHERE src_stm_code = 'NHNCK_ORGANIZATION_REPORTS'
    ) x
    WHERE rn = 1
),

organization_reference AS (
    SELECT
        securities_organization_reference_nm,
        organization_tp_code,
        securities_organization_reference_id
    FROM {{ ref('atm_securities_organization_reference') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_ORGANIZATIONS'
),

organization_type_lookup AS (
    SELECT
        cl_nm,
        cl_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
    WHERE schema_code = 'ORGANIZATION_TYPE'
)

SELECT
    CAST(employment_report.sp_code AS string)                                   AS practitioner_code,
    CAST(employment_report.sp_organization_employment_rpt_code AS string)       AS organization_employment_rpt_code,
    CAST(employment_report.securities_organization_reference_code AS string)    AS securities_organization_reference_code,
    CAST(organization_reference.securities_organization_reference_nm AS string) AS securities_organization_reference_nm,
    CAST(organization_reference.organization_tp_code AS string)                 AS organization_tp_code,
    CAST(organization_type_lookup.cl_nm AS string)                              AS organization_tp_nm,
    CAST(employment_report.practitioner_workplace_at_rpt AS string)             AS practitioner_workplace_at_rpt,
    CAST(employment_report.practitioner_position_at_rpt AS string)              AS practitioner_position_at_rpt,
    CAST(employment_report.practitioner_department_at_rpt AS string)            AS practitioner_department_at_rpt,
    CAST(employment_report.hire_dt AS date)                                     AS hire_dt,
    CAST(employment_report.termination_dt AS date)                              AS termination_dt,
    CAST(employment_report.src_stm_code AS string)                              AS src_stm_code
FROM employment_report
INNER JOIN organization_reference
    ON organization_reference.securities_organization_reference_id = employment_report.securities_organization_reference_id
LEFT JOIN organization_type_lookup
    ON organization_type_lookup.cl_code = organization_reference.organization_tp_code

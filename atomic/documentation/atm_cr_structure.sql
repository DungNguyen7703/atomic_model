/*
*--------------------------------------------------------------------*
* Program code: atm_cr_structure
* Program name: Atomic Compliance Report Structure
* Created by: claude
* Created date: 2026-11-16
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-19		tuan.nguyenvanb		ODS structure doi sang snapshot: loc ds_snpst_dt = etl_date (tranh trung khoa MERGE scd2); bo dau phay thua truoc SELECT cuoi (loi cu phap).
* 2026-11-16		claude				[MOI] Tao model theo lld_TMS_COMPLIANCE_REPORT_STRUCTURE.yaml (Relative -> scd2). Nguon ods_tms_report (truncate+insert, khong co data_dt -> doc toan bang, khong loc ngay). BK = form_code || column_code (khong gom template_code) theo quyet dinh Data Modeler 2026-11-16.
*                                       [DEDUPE] 1 dong / (form_code, column_code): scd2 loi MERGE_CARDINALITY_VIOLATION neu trung unique_key; neu 1 form_code xuat hien o nhieu template thi giu dong co column_index nho nhat, template_code nho nhat (can profile - LLD ghi FORM_CODE phai duy nhat).
*--------------------------------------------------------------------*
*/

WITH struc AS (
    SELECT
        template_code
        , form_code
        , form_name
        , column_index
        , column_code
        , column_label
        , status
        , version
        , key_columns
        , form_template_id
    FROM {{ ref('ods_tms_compliance_report_structure') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')   -- [2026-11-19] ODS structure snapshot: chi lay ban chup ngay chay
)

SELECT
    {{ generate_surrogate_key_bigint('TMS_COMPLIANCE_REPORT_STRUCTURE', "concat_ws('-', form_code, column_code)") }}   AS cr_structure_id
    , CAST(concat_ws('-', form_code, column_code) AS string)                                                           AS cr_structure_code
    , CAST('TMS_COMPLIANCE_REPORT_STRUCTURE' AS string)                                                       AS src_stm_code
    , CAST(template_code AS string)                                                                           AS template_code
    , CAST(form_code AS string)                                                                               AS form_code
    , CAST(form_name AS string)                                                                               AS form_nm
    , CAST(column_index AS int)                                                                               AS column_index
    , CAST(column_code AS string)                                                                             AS column_code
    , CAST(column_label AS string)                                                                            AS column_label
    , CAST(status AS string)                                                                                  AS form_status_code
    , CAST(version AS int)                                                                                    AS form_version
    , CAST(key_columns AS string)                                                                             AS key_columns
FROM struc

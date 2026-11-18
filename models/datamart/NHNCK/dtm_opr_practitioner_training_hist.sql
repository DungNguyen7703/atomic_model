/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_training_hist
* Program name: Dtm Opr Practitioner Training Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-09		duc.luxuan			Theo BA SQL mới nhóm 11 (Cập nhật kiến thức hành nghề): 
                                        bỏ join NHNCK_SPECIALIZATION_COURSE_DETAILS (exam_score không còn); 
                                        Sửa exam_result_code,exam_result_nm lấy từ training_result_status_code, training_cl_result_code 
                                        thuộc sp_post_certification_training_result.
*--------------------------------------------------------------------*
*/

WITH sp_po_ce_tr_re AS (
    SELECT
        sp_code,
        sp_post_certification_training_result_code,
        sp_post_certification_training_course_id,
        training_start_dt,
        training_end_dt,
        training_hours,
        training_result_status_code,
        training_cl_result_code,
        src_stm_code
    FROM {{ ref('atm_sp_post_certification_training_result') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_POST_CERT_TRAINING_RESULTS'
),

sp_po_ce_tr_co AS (
    SELECT
        sp_post_certification_training_course_code,
        training_course_nm,
        sp_post_certification_training_course_id
    FROM {{ ref('atm_sp_post_certification_training_course') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_POST_CERT_TRAINING_COURSES'
)

SELECT
    CAST(sp_po_ce_tr_re.sp_code AS string)                                    AS practitioner_code,
    CAST(sp_po_ce_tr_re.sp_post_certification_training_result_code AS string) AS training_result_code,
    CAST(sp_po_ce_tr_co.sp_post_certification_training_course_code AS string) AS training_class_code,
    CAST(sp_po_ce_tr_co.training_course_nm AS string)                         AS training_class_nm,
    CAST(sp_po_ce_tr_re.training_start_dt AS date)                            AS training_start_dt,
    CAST(sp_po_ce_tr_re.training_end_dt AS date)                              AS training_end_dt,
    CAST(sp_po_ce_tr_re.training_hours AS int)                                AS training_hours,
    CAST(CASE WHEN sp_po_ce_tr_re.training_hours >= 8 THEN 'Y' ELSE 'N' END AS string) AS hours_sufficiency_indicator,
    CAST(sp_po_ce_tr_re.training_result_status_code AS string)                AS exam_result_code,
    CAST(sp_po_ce_tr_re.training_cl_result_code AS string)                    AS exam_result_nm,
    CAST(sp_po_ce_tr_re.src_stm_code AS string)                               AS src_stm_code
FROM sp_po_ce_tr_re
LEFT JOIN sp_po_ce_tr_co
    ON sp_po_ce_tr_co.sp_post_certification_training_course_id = sp_po_ce_tr_re.sp_post_certification_training_course_id

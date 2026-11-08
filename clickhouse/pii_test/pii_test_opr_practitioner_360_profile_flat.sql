-- ────────────────────────────────────────────────────────────
-- Model : pii_test_opr_practitioner_360_profile_flat
-- Type  : OPERATIONAL (TEST PII)
-- Clone : nhnck_opr_practitioner_360_profile_flat — chỉ dùng để test mã hóa PII,
--         ghi vào bảng riêng, không ảnh hưởng bảng gốc.
--         Đặt ngoài thư mục NHNCK, tên không chứa "nhnck", không tag domain::nhnck
--         để orchestrator domain-full không tự gom vào lượt chạy phân hệ NHNCK.
-- ────────────────────────────────────────────────────────────

WITH src AS (
    SELECT
        practitioner_code,
        full_nm,
        birth_dt,
        age,
        nationality_code,
        nationality_nm,
        identification_nbr,
        education_level_code,
        education_level_nm,
        workplace_nm,
        practice_status_code,
        practice_status_nm,
        active_certificate_tp_code,
        active_certificate_tp_nm,
        active_certificate_nbr,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_360_profile') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    practitioner_code,
    full_nm,
    birth_dt,
    age,
    nationality_code,
    nationality_nm,
    {{ pii_encrypt('identification_nbr') }} AS identification_nbr,
    education_level_code,
    {{ pii_encrypt('education_level_nm') }} AS education_level_nm,
    workplace_nm,
    practice_status_code,
    practice_status_nm,
    active_certificate_tp_code,
    active_certificate_tp_nm,
    active_certificate_nbr,
    src_stm_code

FROM src

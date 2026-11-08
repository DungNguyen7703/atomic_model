/*
*--------------------------------------------------------------------*
* Program code: dtm_securities_practitioner_dim
* Program name: Dtm Securities Practitioner Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-11		nam.tranhoai		Chỉ nhận là NHNCK khi có Certificate_Record (JOIN sp_li_ce_do);
*                                       bổ sung pass-through birth_year/nationality_id/workplace_nm
*                                       để các bảng fct/opr đổi ref sang dim này không phải viết lại join
*                                       (không thêm sp_id vì trùng giá trị với securities_practitioner_dim_id
*                                       -- cả hai đều hash từ cùng professional id nguồn NHNCK_PROFESSIONALS)
* 2026-09-12		nguyet.do			Expose birth_year (atomic để string) ra output, cast int, để các
*                                       job tính tuổi phía sau coalesce với birth_dt khi birth_dt NULL
*--------------------------------------------------------------------*
*/

WITH securities_practitioner AS (
    SELECT
        sp_code,
        full_nm,
        birth_year,
        education_level_code,
        nationality_id,
        workplace_nm,
        birth_dt,
        practice_status_code,
        src_stm_code
    FROM {{ ref('atm_securities_practitioner') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

certificate_document AS (
    SELECT DISTINCT
        sp_code
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
),

geographic_area AS (
    SELECT
        geographic_area_code,
        geographic_area_id
    FROM {{ ref('atm_geographic_area') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_COUNTRY'
        AND geographic_area_tp_code = 'COUNTRY'
),

category_value AS (
    SELECT
        cl_nm,
        cl_code,
        schema_code
    FROM {{ source('source_atm', 'raw_classification_value') }}
)

SELECT
    CAST({{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', 'securities_practitioner.sp_code') }} AS string) AS securities_practitioner_dim_id,
    CAST(securities_practitioner.sp_code AS string)                                            AS practitioner_code,
    CAST(securities_practitioner.full_nm AS string)                                            AS full_nm,
    CAST(securities_practitioner.education_level_code AS string)                               AS education_level_code,
    CAST(education_level_lookup.cl_nm AS string)                                                AS education_level_nm,
    CAST(geographic_area.geographic_area_code AS string)                               AS nationality_code,
    CAST(securities_practitioner.workplace_nm AS string)                                       AS workplace_nm,
    CAST(securities_practitioner.birth_dt AS date)                                             AS birth_dt,
    CAST(securities_practitioner.birth_year AS int)                                            AS birth_year,
    CAST(securities_practitioner.practice_status_code AS string)                               AS practice_status_code,
    CAST(practice_status_lookup.cl_nm AS string)                                                AS practice_status_nm,
    CAST(securities_practitioner.src_stm_code AS string)                                       AS src_stm_code
FROM securities_practitioner
JOIN certificate_document
    ON certificate_document.sp_code = securities_practitioner.sp_code
LEFT JOIN geographic_area
    ON geographic_area.geographic_area_id = securities_practitioner.nationality_id
LEFT JOIN category_value education_level_lookup
    ON education_level_lookup.cl_code = securities_practitioner.education_level_code
    AND education_level_lookup.schema_code = 'EDUCATIONAL_LEVEL'
LEFT JOIN category_value practice_status_lookup
    ON practice_status_lookup.cl_code = securities_practitioner.practice_status_code
    AND practice_status_lookup.schema_code = 'PRACTITIONER_PRACTICE_STATUS'

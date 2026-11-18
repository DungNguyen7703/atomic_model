/*
*--------------------------------------------------------------------*
* Program code: atm_sp_professional_training_class
* Program name: Atomic Securities Practitioner Professional Training Class
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sp_co_all AS (
    SELECT
        course_code
        , course_name
        , academic_year
        , specialization_id
        , exam_date_from
        , exam_date_to
        , address
        , province_id
        , id
        , row_number() over (partition by course_code order by id desc) as rn
    FROM {{ ref('ods_nhnck_specialization_courses') }}
),

sp_co AS (
    SELECT
        course_code
        , course_name
        , academic_year
        , specialization_id
        , exam_date_from
        , exam_date_to
        , address
        , province_id
    FROM sp_co_all
    where rn = 1
),

prov AS (
    SELECT
        id
        , province_code
    FROM {{ ref('ods_nhnck_provinces') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_SPECIALIZATION_COURSES', "sp_co.course_code") }} AS sp_professional_training_class_id
    , CAST(sp_co.course_code AS string)                                                      AS sp_professional_training_class_code
    , CAST('NHNCK_SPECIALIZATION_COURSES' AS string)                                         AS src_stm_code
    , CAST(sp_co.course_name AS string)                                                      AS training_class_nm
    , CAST(sp_co.academic_year AS int)                                                       AS academic_year
    , CAST(sp_co.specialization_id AS string)                                                AS specialization_tp_code
    , CAST(sp_co.exam_date_from AS date)                                                     AS exam_start_dt
    , CAST(sp_co.exam_date_to AS date)                                                       AS exam_end_dt
    , CAST(sp_co.address AS string)                                                          AS exam_location_adr
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_NEW', "prov.province_code") }}         AS province_id
    , CAST(sp_co.province_id AS string)                                                      AS province_code
FROM sp_co
    LEFT JOIN prov ON sp_co.PROVINCE_ID = prov.ID
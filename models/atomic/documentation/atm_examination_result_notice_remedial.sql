/*
*--------------------------------------------------------------------*
* Program code: atm_examination_result_notice_remedial
* Program name: Atomic Examination Result Notice Remedial
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_re_no_re AS (
    SELECT
        id
        , examination_result_notice_id
        , description
        , sort_order
    FROM {{ ref('ods_thanhtra_examination_result_notice_remedial') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_RESULT_NOTICE_REMEDIAL', "ex_re_no_re.id") }}                    AS examination_result_notice_remedial_id
    , CAST(ex_re_no_re.id AS string)                                                                                        AS examination_result_notice_remedial_code
    , CAST('THANHTRA_EXAMINATION_RESULT_NOTICE_REMEDIAL' AS string)                                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_RESULT_NOTICE', "ex_re_no_re.examination_result_notice_id") }} AS examination_result_notice_id
    , CAST(ex_re_no_re.examination_result_notice_id AS string)                                                              AS examination_result_notice_code
    , CAST(ex_re_no_re.description AS string)                                                                               AS description
    , CAST(ex_re_no_re.sort_order AS int)                                                                                   AS sort_order
FROM ex_re_no_re
/*
*--------------------------------------------------------------------*
* Program code: atm_examination_result_notice
* Program name: Atomic Examination Result Notice
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_re_no AS (
    SELECT
        id
        , examination_team_id
        , notice_number
        , issued_date
        , announced_date
        , target_type
        , target_reference_id
        , target_name
        , content
        , recommendation
        , execution_status
        , execution_description
    FROM {{ ref('ods_thanhtra_examination_result_notice') }}
),

ex_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_RESULT_NOTICE', "ex_re_no.id") }} AS examination_result_notice_id
    , CAST(ex_re_no.id AS string)                                                            AS examination_result_notice_code
    , CAST('THANHTRA_EXAMINATION_RESULT_NOTICE' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }}         AS examination_team_id
    , CAST(ex_re_no.examination_team_id AS string)                                           AS examination_team_code
    , CAST(ex_re_no.notice_number AS string)                                                 AS notice_nbr
    , CAST(ex_re_no.issued_date AS date)                                                     AS issued_dt
    , CAST(ex_re_no.announced_date AS date)                                                  AS announced_dt
    , CAST(ex_re_no.target_type AS string)                                                   AS target_tp_code
    , CAST(ex_re_no.target_reference_id AS string)                                           AS target_reference_id
    , CAST(ex_re_no.target_name AS string)                                                   AS target_nm
    , CAST(ex_re_no.content AS string)                                                       AS content
    , CAST(ex_re_no.recommendation AS string)                                                AS recommendation
    , CAST(ex_re_no.execution_status AS string)                                              AS execution_status_code
    , CAST(ex_re_no.execution_description AS string)                                         AS execution_description
FROM ex_re_no
    LEFT JOIN ex_te ON ex_re_no.EXAMINATION_TEAM_ID = ex_te.ID
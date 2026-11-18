/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.TL_PROFILES
* Created by: claude
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo theo LLD TL_PROFILES_IP_Alt_Identification
*--------------------------------------------------------------------*
*/

WITH tl_pr AS (
    SELECT
        id
        , id_no
        , id_date
        , id_add
        , cert_no
        , cert_date
    FROM {{ ref('ods_fms_tl_profiles') }}
),

unpvt AS (
    SELECT *
    FROM tl_pr
    UNPIVOT (
        (identification_nbr, identification_issue_dt)
        FOR identification_tp_code IN (
            (id_no, id_date) AS IDENTIFICATION,
            (cert_no, cert_date) AS PRACTITIONER_LICENSE
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_TL_PROFILES', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                         AS ip_code
    , CAST('FMS_TL_PROFILES' AS string)                                  AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string)                     AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string)                         AS identification_nbr
    , CAST(unpvt.identification_issue_dt AS date)                      AS identification_issue_dt
    , CAST(CASE WHEN unpvt.identification_tp_code = 'IDENTIFICATION'
                THEN unpvt.id_add END AS string)                       AS identification_issue_place
FROM unpvt

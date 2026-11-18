/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.INVES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				Đổi alias CTE in -> inve (IN là từ khóa SQL); map ID_TYPE 1..4 sang mã IP_ALT_ID_TYPE
*										theo LLD INVES_IP_Alt_Identification (giá trị ngoài map giữ nguyên mã nguồn)
*--------------------------------------------------------------------*
*/

WITH inve AS (
    SELECT
        id
        , id_type
        , id_no
        , id_date
        , id_place
    FROM {{ ref('ods_fms_inves') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INVES', "inve.id") }} AS ip_id
    , CAST(inve.id AS string)                                   AS ip_code
    , CAST('FMS_INVES' AS string)                             AS src_stm_code
    , CAST(CASE inve.id_type
                WHEN 1 THEN 'NATIONAL_ID'
                WHEN 2 THEN 'CITIZEN_ID'
                WHEN 3 THEN 'PASSPORT'
                WHEN 4 THEN 'ENTERPRISE_CODE'
                ELSE CAST(inve.id_type AS string)
           END AS string)                                           AS identification_tp_code
    , CAST(inve.id_no AS string)                                AS identification_nbr
    , CAST(inve.id_date AS date)                                AS identification_issue_dt
    , CAST(inve.id_place AS string)                             AS identification_issue_place
FROM inve
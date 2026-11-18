/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification NHNCK.PROFESSIONALS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-29		tra					Bổ sung xử lý Hộ chiếu (identity_type = 2): lấy số/ngày cấp/nơi cấp
*									từ passport_number/passport_issue_date/passport_issue_place; chuẩn hoá
*									identification_tp_code theo mapping LLD (0=NATIONAL_ID, 1=CITIZEN_ID, 2=PASSPORT)
*--------------------------------------------------------------------*
*/

WITH pro AS (
    SELECT
        id
        , identity_type
        , identity_number
        , identity_issue_date
        , identity_issue_place
        , passport_number
        , passport_issue_date
        , passport_issue_place
    FROM {{ ref('ods_nhnck_professionals') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pro.id") }} AS ip_id
    , CAST(pro.id AS string)                                               AS ip_code
    , CAST('NHNCK_PROFESSIONALS' AS string)                                  AS src_stm_code
    , CAST(CASE pro.identity_type
                WHEN 0 THEN 'NATIONAL_ID'
                WHEN 1 THEN 'CITIZEN_ID'
                WHEN 2 THEN 'PASSPORT'
                ELSE CAST(pro.identity_type AS string)
           END AS string)                                                  AS identification_tp_code
    , CAST(CASE
                WHEN pro.identity_type IN (0, 1) THEN pro.identity_number
                WHEN pro.identity_type = 2 THEN pro.passport_number
           END AS string)                                                  AS identification_nbr
    , CAST(CASE
                WHEN pro.identity_type IN (0, 1) THEN pro.identity_issue_date
                WHEN pro.identity_type = 2 THEN pro.passport_issue_date
           END AS date)                                                    AS identification_issue_dt
    , CAST(CASE
                WHEN pro.identity_type IN (0, 1) THEN pro.identity_issue_place
                WHEN pro.identity_type = 2 THEN pro.passport_issue_place
           END AS string)                                                  AS identification_issue_place
FROM pro
/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FIMS.INVESTOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date                User                Description
*
*--------------------------------------------------------------------*
*/
-- TẠM THỜI LẤY ROW_NUM ĐỂ DEDUP DO DỮ LIỆU SAI

WITH inve_ranked AS (
    SELECT
        id
        , transactioncode
        , iddate
        , idadd
        , businessnumber
        , idno
        , ROW_NUMBER() OVER (
            PARTITION BY transactioncode
            ORDER BY id DESC
        ) AS rn
    FROM ods.uat_FIMS_ods.investor
),

inve AS (
    SELECT
        transactioncode
        , iddate
        , idadd
        , businessnumber
        , idno
    FROM inve_ranked
    WHERE rn = 1
),

unpvt AS (
    SELECT *
    FROM inve
    UNPIVOT (
        identification_nbr
        FOR identification_tp_code IN (
            businessnumber AS BUSINESS_LICENSE,
            idno AS IDENTIFICATION
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_INVESTOR', "unpvt.transactioncode") }} AS ip_id
    , CAST(unpvt.transactioncode AS string) AS ip_code
    , CAST('FIMS_INVESTOR' AS string) AS src_stm_code
    , CAST(unpvt.identification_tp_code AS string) AS identification_tp_code
    , CAST(unpvt.identification_nbr AS string) AS identification_nbr
    , CAST(unpvt.iddate AS date) AS identification_issue_dt
    , CAST(unpvt.idadd AS string) AS identification_issue_place
FROM unpvt
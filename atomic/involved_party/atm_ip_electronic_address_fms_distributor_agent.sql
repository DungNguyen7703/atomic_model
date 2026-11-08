/*
*--------------------------------------------------------------------*
* Program code: atm_ip_electronic_address
* Program name: Atomic Involved Party Electronic Address FMS.DISTRIBUTOR_AGENT
* Created by: claude
* Created date: 2026-10-07
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		claude				Khởi tạo theo LLD DISTRIBUTOR_AGENT_IP_Electronic_Address
*--------------------------------------------------------------------*
*/

WITH di_ag AS (
    SELECT
        id
        , phone
        , fax
    FROM {{ ref('ods_fms_distributor_agent') }}
),

unpvt AS (
    SELECT *
    FROM di_ag
    UNPIVOT (
        electronic_adr_val
        FOR electronic_adr_tp_code IN (
            phone AS PHONE,
            fax AS FAX
        )
    )
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_DISTRIBUTOR_AGENT', "unpvt.id") }} AS ip_id
    , CAST(unpvt.id AS string)                                               AS ip_code
    , CAST('FMS_DISTRIBUTOR_AGENT' AS string)                                AS src_stm_code
    , CAST(unpvt.electronic_adr_tp_code AS string)                           AS electronic_adr_tp_code
    , CAST(unpvt.electronic_adr_val AS string)                               AS electronic_adr_val
FROM unpvt

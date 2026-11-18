/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification IDS.COMPANY_PROFILES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH co_pr AS (
    SELECT
        id
        , business_reg_no
    FROM {{ ref('ods_ids_company_profiles') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "co_pr.id") }} AS ip_id
    , CAST(co_pr.id AS string)                                              AS ip_code
    , CAST('IDS_COMPANY_PROFILES' AS string)                                AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)                     AS identification_tp_code
    , CAST(co_pr.business_reg_no AS string)                                 AS identification_nbr
    , CAST(NULL AS date)                                                    AS identification_issue_dt
    , CAST(NULL AS string)                                                  AS identification_issue_place
FROM co_pr
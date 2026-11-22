/*
*--------------------------------------------------------------------*
* Program code: atm_pc_foreign_ownership_limit
* Program name: Atomic Pc Foreign Ownership Limit
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , company_profile_id
        , max_owner_rate
        , from_date
        , to_date
    FROM {{ ref('ods_ids_foreign_owner_limit') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_FOREIGN_OWNER_LIMIT', "id") }}                AS pc_foreign_ownership_limit_id
    , CAST(id AS string)                                                                AS pc_foreign_ownership_limit_code
    , CAST('IDS_FOREIGN_OWNER_LIMIT' AS string)                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "company_profile_id") }} AS pc_id
    , CAST(company_profile_id AS string)                                                AS pc_code
    , CAST(max_owner_rate AS decimal(5,2))                                              AS maximum_foreign_ownership_rate_percentage
    , CAST(from_date AS date)                                                           AS effective_from_dt
    , CAST(to_date AS date)                                                             AS effective_to_dt
FROM src

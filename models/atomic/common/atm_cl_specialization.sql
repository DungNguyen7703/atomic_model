/*
*--------------------------------------------------------------------*
* Program code: atm_cl_specialization
* Program name: Atomic Classification Specialization
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH spec AS (
    SELECT
        id
        , specialization_code
        , specialization_name
        , reference
        , is_active
        , is_original_data
        , mcdt_code
    FROM {{ ref('ods_nhnck_specializations') }}
)

SELECT
    {{ generate_surrogate_key_bigint('NHNCK_SPECIALIZATIONS', "spec.specialization_code") }} AS cl_specialization_id
    , CAST(spec.specialization_code AS string)                                               AS cl_specialization_code
    , CAST('NHNCK_SPECIALIZATIONS' AS string)                                                AS src_stm_code
    , CAST(spec.specialization_name AS string)                                               AS cl_specialization_nm
    , CAST(spec.reference AS string)                                                         AS legal_reference
    , CAST(spec.is_active AS string)                                                         AS active_ind
    , CAST(spec.is_original_data AS string)                                                  AS original_data_ind
    , CAST(spec.mcdt_code AS string)                                                         AS public_service_portal_code
FROM spec
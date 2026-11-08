/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area
* Program name: Atomic Geographic Area ECAT.REGION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH regi AS (
    SELECT
        code
        , name
        , country_id
        , active
        , deleted
        , effective_start_date
        , effective_end_date
        , version
        , active_reason
        , deleted_reason
        , created_at
        , updated_at
        , created_by_id
        , created_by_name
        , updated_by_id
        , updated_by_name
        , ROW_NUMBER() OVER (
            PARTITION BY code 
            ORDER BY created_at DESC) AS rn
    FROM {{ ref('ods_ecat_region') }}
)

, regi_dedup AS (
    SELECT *
    FROM regi
    WHERE rn = 1
      AND active = 1
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_REGION', "regi_dedup.code") }}                AS geographic_area_id
    , CAST('ECAT_REGION' AS string)                                                      AS src_stm_code
    , CAST('REGION' AS string)                                                           AS geographic_area_tp_code
    , CAST(regi_dedup.code AS string)                                                    AS geographic_area_code
    , CAST(regi_dedup.name AS string)                                                    AS geographic_area_nm
    , CAST(NULL AS string)                                                               AS geographic_area_english_nm
    , {{ generate_surrogate_key_bigint('ECAT_REGION', "regi_dedup.country_id") }}        AS parent_geographic_area_id
    , CAST(regi_dedup.country_id AS string)                                              AS parent_geographic_area_code
    , CAST(NULL AS int)                                                                  AS effective_ind
    , CAST(regi_dedup.active AS int)                                                     AS active_ind
    , CAST(regi_dedup.deleted AS int)                                                    AS deleted_ind
    , CAST(regi_dedup.effective_start_date AS timestamp)                                 AS effective_start_dt
    , CAST(regi_dedup.effective_end_date AS timestamp)                                   AS effective_end_dt
    , CAST(regi_dedup.version AS int)                                                    AS version_nbr
    , CAST(NULL AS string)                                                               AS display_label
    , CAST(regi_dedup.active_reason AS string)                                           AS active_reason
    , CAST(regi_dedup.deleted_reason AS string)                                          AS deleted_reason
    , CAST(regi_dedup.created_at AS timestamp)                                           AS created_tms
    , CAST(regi_dedup.updated_at AS timestamp)                                           AS updated_tms
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "regi_dedup.created_by_id") }} AS created_by_staff_id
    , CAST(regi_dedup.created_by_id AS string)                                           AS created_by_staff_code
    , CAST(regi_dedup.created_by_name AS string)                                         AS created_by_staff_nm
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "regi_dedup.updated_by_id") }} AS updated_by_staff_id
    , CAST(regi_dedup.updated_by_id AS string)                                           AS updated_by_staff_code
    , CAST(regi_dedup.updated_by_name AS string)                                         AS updated_by_staff_nm
    , CAST(NULL AS string)                                                               AS geographic_area_category_code
FROM regi_dedup
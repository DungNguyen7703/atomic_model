/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area
* Program name: Atomic Geographic Area ECAT.PROVINCE_NEW
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pr_ne AS (
    SELECT
        code
        , name_vn
        , name_en
        , region_id
        , effective
        , active
        , deleted
        , effective_start_date
        , effective_end_date
        , version
        , display_label
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
    FROM {{ ref('ods_ecat_province_new') }}
)

, pr_ne_dedup AS (
    SELECT *
    FROM pr_ne
    WHERE rn = 1
      AND active = 1
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_PROVINCE', "pr_ne_dedup.code") }}              AS geographic_area_id
    , CAST('ECAT_PROVINCE' AS string)                                                     AS src_stm_code
    , CAST('PROVINCE' AS string)                                                          AS geographic_area_tp_code
    , CAST(pr_ne_dedup.code AS string)                                                    AS geographic_area_code
    , CAST(pr_ne_dedup.name_vn AS string)                                                 AS geographic_area_nm
    , CAST(pr_ne_dedup.name_en AS string)                                                 AS geographic_area_english_nm
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE', "pr_ne_dedup.region_id") }}       AS parent_geographic_area_id
    , CAST(pr_ne_dedup.region_id AS string)                                               AS parent_geographic_area_code
    , CAST(pr_ne_dedup.effective AS int)                                                  AS effective_ind
    , CAST(pr_ne_dedup.active AS int)                                                     AS active_ind
    , CAST(pr_ne_dedup.deleted AS int)                                                    AS deleted_ind
    , CAST(pr_ne_dedup.effective_start_date AS timestamp)                                 AS effective_start_dt
    , CAST(pr_ne_dedup.effective_end_date AS timestamp)                                   AS effective_end_dt
    , CAST(pr_ne_dedup.version AS int)                                                    AS version_nbr
    , CAST(pr_ne_dedup.display_label AS string)                                           AS display_label
    , CAST(pr_ne_dedup.active_reason AS string)                                           AS active_reason
    , CAST(pr_ne_dedup.deleted_reason AS string)                                          AS deleted_reason
    , CAST(pr_ne_dedup.created_at AS timestamp)                                           AS created_tms
    , CAST(pr_ne_dedup.updated_at AS timestamp)                                           AS updated_tms
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "pr_ne_dedup.created_by_id") }} AS created_by_staff_id
    , CAST(pr_ne_dedup.created_by_id AS string)                                           AS created_by_staff_code
    , CAST(pr_ne_dedup.created_by_name AS string)                                         AS created_by_staff_nm
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "pr_ne_dedup.updated_by_id") }} AS updated_by_staff_id
    , CAST(pr_ne_dedup.updated_by_id AS string)                                           AS updated_by_staff_code
    , CAST(pr_ne_dedup.updated_by_name AS string)                                         AS updated_by_staff_nm
    , CAST(NULL AS string)                                                                AS geographic_area_category_code
FROM pr_ne_dedup
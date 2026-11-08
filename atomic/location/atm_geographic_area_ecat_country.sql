/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area
* Program name: Atomic Geographic Area ECAT.COUNTRY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH coun AS (
    SELECT
        code
        , name_vn
        , name_en
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
    FROM {{ ref('ods_ecat_country') }}
)

, coun_dedup AS (
    SELECT *
    FROM coun
    WHERE rn = 1
      AND active = 1
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "coun_dedup.code") }}               AS geographic_area_id
    , CAST('ECAT_COUNTRY' AS string)                                                     AS src_stm_code
    , CAST('COUNTRY' AS string)                                                          AS geographic_area_tp_code
    , CAST(coun_dedup.code AS string)                                                    AS geographic_area_code
    , CAST(coun_dedup.name_vn AS string)                                                 AS geographic_area_nm
    , CAST(coun_dedup.name_en AS string)                                                 AS geographic_area_english_nm
    , CAST(null AS string)                                                               AS parent_geographic_area_id
    , CAST(null AS string)                                                               AS parent_geographic_area_code
    , CAST(coun_dedup.effective AS int)                                                  AS effective_ind
    , CAST(coun_dedup.active AS int)                                                     AS active_ind
    , CAST(coun_dedup.deleted AS int)                                                    AS deleted_ind
    , CAST(coun_dedup.effective_start_date AS timestamp)                                 AS effective_start_dt
    , CAST(coun_dedup.effective_end_date AS timestamp)                                   AS effective_end_dt
    , CAST(coun_dedup.version AS int)                                                    AS version_nbr
    , CAST(coun_dedup.display_label AS string)                                           AS display_label
    , CAST(coun_dedup.active_reason AS string)                                           AS active_reason
    , CAST(coun_dedup.deleted_reason AS string)                                          AS deleted_reason
    , CAST(coun_dedup.created_at AS timestamp)                                           AS created_tms
    , CAST(coun_dedup.updated_at AS timestamp)                                           AS updated_tms
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "coun_dedup.created_by_id") }} AS created_by_staff_id
    , CAST(coun_dedup.created_by_id AS string)                                           AS created_by_staff_code
    , CAST(coun_dedup.created_by_name AS string)                                         AS created_by_staff_nm
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "coun_dedup.updated_by_id") }} AS updated_by_staff_id
    , CAST(coun_dedup.updated_by_id AS string)                                           AS updated_by_staff_code
    , CAST(coun_dedup.updated_by_name AS string)                                         AS updated_by_staff_nm
    , CAST(NULL AS string)                                                               AS geographic_area_category_code
FROM coun_dedup
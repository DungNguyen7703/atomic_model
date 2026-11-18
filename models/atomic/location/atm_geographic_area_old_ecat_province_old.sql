/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area_old
* Program name: Atomic Geographic Area Old ECAT.PROVINCE_OLD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pr_ol AS (
    SELECT
        code
        , name_vn
        , name_en
        , region_id
        , province_new_id
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
    FROM {{ ref('ods_ecat_province_old') }}
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_PROVINCE_OLD', "pr_ol.code") }}              AS geographic_area_old_id
    , CAST('ECAT_PROVINCE_OLD' AS string)                                               AS src_stm_code
    , CAST(null AS string)                                                              AS geographic_area_old_tp_code
    , CAST(pr_ol.code AS string)                                                        AS geographic_area_old_code
    , CAST(pr_ol.name_vn AS string)                                                     AS geographic_area_old_nm
    , CAST(null AS string)                                                              AS parent_geographic_area_old_id
    , CAST(null AS string)                                                              AS parent_geographic_area_old_code
    , CAST(pr_ol.effective AS int)                                                      AS effective_ind
    , CAST(pr_ol.active AS int)                                                         AS active_ind
    , CAST(pr_ol.deleted AS int)                                                        AS deleted_ind
    , CAST(pr_ol.effective_start_date AS timestamp)                                     AS effective_start_dt
    , CAST(pr_ol.effective_end_date AS timestamp)                                       AS effective_end_dt
    , CAST(pr_ol.version AS int)                                                        AS version_nbr
    , CAST(pr_ol.display_label AS string)                                               AS display_label
    , CAST(pr_ol.active_reason AS string)                                               AS active_reason
    , CAST(pr_ol.deleted_reason AS string)                                              AS deleted_reason
    , CAST(pr_ol.created_at AS timestamp)                                               AS created_tms
    , CAST(pr_ol.updated_at AS timestamp)                                               AS updated_tms
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "pr_ol.created_by_id") }}     AS created_by_staff_id
    , CAST(pr_ol.created_by_id AS string)                                               AS created_by_staff_code
    , CAST(pr_ol.created_by_name AS string)                                             AS created_by_staff_nm
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "pr_ol.updated_by_id") }}     AS updated_by_staff_id
    , CAST(pr_ol.updated_by_id AS string)                                               AS updated_by_staff_code
    , CAST(pr_ol.updated_by_name AS string)                                             AS updated_by_staff_nm
    , CAST(pr_ol.name_en AS string)                                                     AS geographic_area_old_english_nm
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_OLD', "pr_ol.region_id") }}       AS region_geographic_area_id
    , CAST(pr_ol.region_id AS string)                                                   AS region_geographic_area_code
    , {{ generate_surrogate_key_bigint('ECAT_PROVINCE_OLD', "pr_ol.province_new_id") }} AS successor_geographic_area_id
    , CAST(pr_ol.province_new_id AS string)                                             AS successor_geographic_area_code
    , CAST(NULL AS string)                                                              AS geographic_area_old_category_code
FROM pr_ol
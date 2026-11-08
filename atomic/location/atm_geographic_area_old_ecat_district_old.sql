/*
*--------------------------------------------------------------------*
* Program code: atm_geographic_area_old
* Program name: Atomic Geographic Area Old ECAT.DISTRICT_OLD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH di_ol AS (
    SELECT
        code
        , name
        , province_old_id
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
    FROM {{ ref('ods_ecat_district_old') }}
)

SELECT
    {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "di_ol.code") }}              AS geographic_area_old_id
    , CAST('ECAT_DISTRICT_OLD' AS string)                                               AS src_stm_code
    , CAST(null AS string)                                                              AS geographic_area_old_tp_code
    , CAST(di_ol.code AS string)                                                        AS geographic_area_old_code
    , CAST(di_ol.name AS string)                                                        AS geographic_area_old_nm
    , {{ generate_surrogate_key_bigint('ECAT_DISTRICT_OLD', "di_ol.province_old_id") }} AS parent_geographic_area_old_id
    , CAST(di_ol.province_old_id AS string)                                             AS parent_geographic_area_old_code
    , CAST(di_ol.effective AS int)                                                      AS effective_ind
    , CAST(di_ol.active AS int)                                                         AS active_ind
    , CAST(di_ol.deleted AS int)                                                        AS deleted_ind
    , CAST(di_ol.effective_start_date AS timestamp)                                     AS effective_start_dt
    , CAST(di_ol.effective_end_date AS timestamp)                                       AS effective_end_dt
    , CAST(di_ol.version AS int)                                                        AS version_nbr
    , CAST(di_ol.display_label AS string)                                               AS display_label
    , CAST(di_ol.active_reason AS string)                                               AS active_reason
    , CAST(di_ol.deleted_reason AS string)                                              AS deleted_reason
    , CAST(di_ol.created_at AS timestamp)                                               AS created_tms
    , CAST(di_ol.updated_at AS timestamp)                                               AS updated_tms
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "di_ol.created_by_id") }}     AS created_by_staff_id
    , CAST(di_ol.created_by_id AS string)                                               AS created_by_staff_code
    , CAST(di_ol.created_by_name AS string)                                             AS created_by_staff_nm
    , {{ generate_surrogate_key_bigint('ECAT_UBCK_STAFF', "di_ol.updated_by_id") }}     AS updated_by_staff_id
    , CAST(di_ol.updated_by_id AS string)                                               AS updated_by_staff_code
    , CAST(di_ol.updated_by_name AS string)                                             AS updated_by_staff_nm
    , CAST(NULL AS string)                                                              AS geographic_area_old_english_nm
    , CAST(NULL AS string)                                                              AS region_geographic_area_id
    , CAST(NULL AS string)                                                              AS region_geographic_area_code
    , CAST(NULL AS string)                                                              AS successor_geographic_area_id
    , CAST(NULL AS string)                                                              AS successor_geographic_area_code
    , CAST(NULL AS string)                                                              AS geographic_area_old_category_code
FROM di_ol
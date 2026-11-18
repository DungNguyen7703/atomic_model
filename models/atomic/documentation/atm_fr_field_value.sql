/*
*--------------------------------------------------------------------*
* Program code: atm_fr_field_value
* Program name: Atomic Financial Report Field Value
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Theo design dm_atm_fr_field_value-IDS.DATA_VALUES (Upsert, source IDS_DATA_VALUES). Ma hoa khoa: hash IDS_COMPANY_DATA / IDS_FORM_FIELDS / IDS_FIELDS / IDS_DATA_VALUES.
*--------------------------------------------------------------------*
*/

WITH dv AS (
    SELECT
        id
        , field_name_vi
        , field_name_en
        , text_value
        , date_value
        , number_value
        , company_data_id
        , parent_id
        , form_field_id
        , field_parent_id
        , data_type
    FROM {{ ref('ods_ids_data_values') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_DATA_VALUES', "dv.id") }}                       AS fr_field_val_id
    , CAST(dv.id AS string)                                                               AS fr_field_val_code
    , CAST('IDS_DATA_VALUES' AS string)                                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_DATA', "dv.company_data_id") }}       AS pc_rpt_submission_id
    , CAST(dv.company_data_id AS string)                                                  AS pc_rpt_submission_code
    , {{ generate_surrogate_key_bigint('IDS_FORM_FIELDS', "dv.form_field_id") }}          AS fr_x_fr_field_rltnp_id
    , CAST(dv.form_field_id AS string)                                                    AS fr_x_fr_field_rltnp_code
    , {{ generate_surrogate_key_bigint('IDS_FIELDS', "dv.field_parent_id") }}             AS parent_fr_field_id
    , CAST(dv.field_parent_id AS string)                                                  AS parent_fr_field_code
    , {{ generate_surrogate_key_bigint('IDS_DATA_VALUES', "dv.parent_id") }}              AS parent_fr_field_val_id
    , CAST(dv.parent_id AS string)                                                        AS parent_fr_field_val_code
    , CAST(dv.field_name_vi AS string)                                                    AS field_nm
    , CAST(dv.field_name_en AS string)                                                    AS field_english_nm
    , CAST(dv.text_value AS string)                                                       AS text_val
    , CAST(dv.date_value AS date)                                                         AS dt_val
    , CAST(dv.number_value AS decimal(23,2))                                              AS nbr_val
    , CAST(dv.data_type AS string)                                                        AS field_data_tp_code
FROM dv

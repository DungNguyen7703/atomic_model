/*
*--------------------------------------------------------------------*
* Program code: atm_fr_field
* Program name: Atomic Fr Field
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
        , field_name_vi
        , field_name_en
        , data_type
        , repeatable_flg
        , form_type
        , parent_id
        , lookup_group
    FROM {{ ref('ods_ids_fields') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_FIELDS', "id") }}          AS fr_field_id
    , CAST(id AS string)                                             AS fr_field_code
    , CAST('IDS_FIELDS' AS string)                                   AS src_stm_code
    , CAST(field_name_vi AS string)                                  AS fr_field_nm
    , CAST(field_name_en AS string)                                  AS fr_field_english_nm
    , CAST(data_type AS string)                                      AS field_data_tp_code
    , CAST(repeatable_flg AS int)                                    AS repeatable_ind
    , CAST(form_type AS string)                                      AS field_form_tp_code
    , {{ generate_surrogate_key_bigint('IDS_FIELDS', "parent_id") }} AS parent_fr_field_id
    , CAST(parent_id AS string)                                      AS parent_fr_field_code
    , CAST(lookup_group AS string)                                   AS lookup_group_code
FROM src

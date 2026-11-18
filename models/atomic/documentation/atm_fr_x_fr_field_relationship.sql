/*
*--------------------------------------------------------------------*
* Program code: atm_fr_x_fr_field_relationship
* Program name: Atomic Financial Report X Financial Report Field Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Theo design dm_atm_fr_x_fr_field_relationship-IDS.FORM_FIELDS (SCD2, source IDS_FORM_FIELDS). fr_id/fr_code qua crosswalk FORM_FIELDS.FORM_ID = FORMS.ID -> FORM_CD (ods_ids_forms).
*--------------------------------------------------------------------*
*/

WITH ff AS (
    SELECT
        id
        , field_id
        , field_parent_id
        , form_id
        , data_type
        , field_order
        , parent_id
        , field_format
    FROM {{ ref('ods_ids_form_fields') }}
),

form AS (
    SELECT
        id
        , form_cd
    FROM {{ ref('ods_ids_forms') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_FORM_FIELDS', "ff.id") }}                       AS fr_x_fr_field_rltnp_id
    , CAST(ff.id AS string)                                                               AS fr_x_fr_field_rltnp_code
    , CAST('IDS_FORM_FIELDS' AS string)                                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_FORMS', "form.form_cd") }}                    AS fr_id
    , CAST(form.form_cd AS string)                                                        AS fr_code
    , {{ generate_surrogate_key_bigint('IDS_FIELDS', "ff.field_id") }}                    AS fr_field_id
    , CAST(ff.field_id AS string)                                                         AS fr_field_code
    , {{ generate_surrogate_key_bigint('IDS_FIELDS', "ff.field_parent_id") }}             AS parent_fr_field_id
    , CAST(ff.field_parent_id AS string)                                                  AS parent_fr_field_code
    , {{ generate_surrogate_key_bigint('IDS_FORM_FIELDS', "ff.parent_id") }}              AS parent_fr_x_fr_field_rltnp_id
    , CAST(ff.parent_id AS string)                                                        AS parent_fr_x_fr_field_rltnp_code
    , CAST(ff.data_type AS string)                                                        AS field_data_tp_code
    , CAST(ff.field_order AS int)                                                         AS field_display_order
    , CAST(ff.field_format AS string)                                                     AS field_format
FROM ff
    LEFT JOIN form ON ff.form_id = form.id

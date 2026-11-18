/*
*--------------------------------------------------------------------*
* Program code: atm_ufr_value
* Program name: Atomic Unstructured Financial Report Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Created model for SCD1/Upsert and aligned with LLD lld_IDS_REP_DATA.yaml
*--------------------------------------------------------------------*
*/

WITH rep_data AS (
    SELECT
        id
        , company_profile_id
        , legal_entity_id
        , company_data_id
        , rep_form_id
        , rep_row_id
        , rep_col_id
        , data_value
        , text_value
        , rep_row_index
        , rep_col_index
        , col_data_type
        , row_data_type
    FROM {{ ref('ods_ids_rep_data') }}
),

rep_form AS (
    SELECT
        id
    FROM {{ ref('ods_ids_rep_forms') }}
),

rep_row AS (
    SELECT
        id
    FROM {{ ref('ods_ids_rep_row') }}
),

rep_col AS (
    SELECT
        id
    FROM {{ ref('ods_ids_rep_column') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_REP_DATA', "rep_data.id") }}                       AS ufr_val_id
    , CAST(rep_data.id AS string)                                                            AS ufr_val_code
    , CAST('IDS_REP_DATA' AS string)                                                         AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "rep_data.company_profile_id") }} AS pc_id
    , CAST(rep_data.company_profile_id AS string)                                            AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "rep_data.legal_entity_id") }}   AS legal_entity_id
    , CAST(rep_data.legal_entity_id AS string)                                               AS legal_entity_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_DATA', "rep_data.company_data_id") }}     AS pc_rpt_submission_id
    , CAST(rep_data.company_data_id AS string)                                               AS pc_rpt_submission_code
    , {{ generate_surrogate_key_bigint('IDS_REP_FORMS', "rep_data.rep_form_id") }}           AS ufr_id
    , CAST(rep_form.id AS string)                                                            AS ufr_code
    , {{ generate_surrogate_key_bigint('IDS_REP_ROW', "rep_data.rep_row_id") }}              AS ufr_row_id
    , CAST(rep_row.id AS string)                                                             AS ufr_row_code
    , {{ generate_surrogate_key_bigint('IDS_REP_COLUMN', "rep_data.rep_col_id") }}           AS ufr_column_id
    , CAST(rep_col.id AS string)                                                             AS ufr_column_code
    , CAST(rep_data.data_value AS decimal(23,2))                                             AS data_val
    , CAST(rep_data.text_value AS string)                                                    AS text_val
    , CAST(rep_data.rep_row_index AS int)                                                    AS row_index
    , CAST(rep_data.rep_col_index AS int)                                                    AS column_index
    , CAST(rep_data.col_data_type AS string)                                                 AS column_data_tp_code
    , CAST(rep_data.row_data_type AS string)                                                 AS row_data_tp_code
FROM rep_data
    LEFT JOIN rep_form ON rep_data.rep_form_id = rep_form.id
    LEFT JOIN rep_row ON rep_data.rep_row_id = rep_row.id
    LEFT JOIN rep_col ON rep_data.rep_col_id = rep_col.id

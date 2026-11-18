/*
*--------------------------------------------------------------------*
* Program code: stg_ids_rep_data
* Program name: Staging IDS.REP_DATA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-23		antigravity			Created model for Staging IDS.REP_DATA
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                   AS id
    , CAST(company_profile_id AS int)   AS company_profile_id
    , CAST(legal_entity_id AS int)      AS legal_entity_id
    , CAST(company_data_id AS int)      AS company_data_id
    , CAST(rep_form_id AS int)          AS rep_form_id
    , CAST(rep_row_id AS int)           AS rep_row_id
    , CAST(rep_col_id AS int)           AS rep_col_id
    , CAST(data_value AS double)        AS data_value
    , CAST(text_value AS string)        AS text_value
    , CAST(rep_row_index AS int)        AS rep_row_index
    , CAST(rep_col_index AS int)        AS rep_col_index
    , CAST(col_data_type AS string)     AS col_data_type
    , CAST(row_data_type AS string)     AS row_data_type
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
FROM {{ source('source_ids', 'raw_rep_data') }}

/*
*--------------------------------------------------------------------*
* Program code: ods_ids_rep_data
* Program name: ODS IDS.REP_DATA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-23		antigravity			Created model for ODS IDS.REP_DATA
*--------------------------------------------------------------------*
*/

WITH src AS (
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
        , created_by
        , created_date
        , updated_by
        , updated_date
    FROM {{ ref('stg_ids_rep_data') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

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
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM src

/*
*--------------------------------------------------------------------*
* Program code: atm_fir_structure
* Program name: Atomic Foreign Investor Report Structure
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fi_st AS (
    SELECT
        indicator_uid
        , sheet_id
        , rpt_id
        , sheet_row
        , sheet_col
        , format_data_type
        , row_path
        , column_path
        , section_id
        , section_type
        , is_dynamic_slot
        , is_group_last_band
        , is_total_row
        , is_ordinal_col
        , item_id
        , sort_order
        , is_excluded_by_config
        , override_source
    FROM {{ source('source_fims_bcd', 'raw_fir_structure') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FIMS_FIR_STRUCTURE', "concat_ws('-', fi_st.sheet_id, fi_st.indicator_uid)") }} AS fir_structure_id
    , CAST(concat_ws('-', fi_st.sheet_id, fi_st.indicator_uid) AS string)                                            AS fir_structure_code
    , CAST('FIMS_FIR_STRUCTURE' AS string)                                                                           AS src_stm_code
    , CAST(fi_st.indicator_uid AS string)                                                                            AS structure_code
    , {{ generate_surrogate_key_bigint('FIMS_FOREIGN_INVESTOR_REPORT', "fi_st.sheet_id") }}                          AS fir_id
    , CAST(fi_st.sheet_id AS string)                                                                                 AS fir_code
    , CAST(fi_st.rpt_id AS string)                                                                                   AS rpt_id
    , CAST(fi_st.sheet_row AS int)                                                                                   AS row_index
    , CAST(fi_st.sheet_col AS int)                                                                                   AS column_index
    , CAST(fi_st.format_data_type AS string)                                                                         AS data_tp
    , CAST(fi_st.row_path AS string)                                                                                 AS row_path
    , CAST(fi_st.column_path AS string)                                                                              AS column_path
    , CAST(fi_st.section_id AS string)                                                                               AS section_id
    , CAST(fi_st.section_type AS string)                                                                             AS section_tp_code
    , CAST(fi_st.is_dynamic_slot AS int)                                                                             AS dynamic_ind
    , CAST(fi_st.is_group_last_band AS int)                                                                          AS last_band_ind
    , CAST(fi_st.is_total_row AS int)                                                                                AS total_row_ind
    , CAST(fi_st.is_ordinal_col AS int)                                                                              AS ordinal_column_ind
    , CAST(fi_st.item_id AS string)                                                                                  AS data_explorer_id
    , CAST(fi_st.sort_order AS bigint)                                                                               AS sort_order
    , CAST(fi_st.is_excluded_by_config AS int)                                                                       AS excluded_by_config_ind
    , CAST(fi_st.override_source AS string)                                                                          AS override_src
FROM fi_st
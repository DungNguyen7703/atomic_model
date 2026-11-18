/*
*--------------------------------------------------------------------*
* Program code: atm_fr_column
* Program name: Atomic Financial Report Column
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Refactor to SCD2 and align with LLD lld_IDS_RCOL.yaml
*--------------------------------------------------------------------*
*/

WITH rc AS (
    SELECT
        id
        , col_cd
        , col_name_vi
        , col_name_en
        , col_index
        , report_catalog_id
        , col_type_cd
        , col_formula
        , report_year
        , rc_type_cd
        , description
        , col_desc
        , formula_desc
    FROM {{ ref('ods_ids_rcol') }}
),

re_ca AS (
    SELECT
        id
    FROM {{ ref('ods_ids_report_catalog') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_RCOL', "rc.id") }}                            AS fr_column_id
    , CAST(rc.id AS string)                                                             AS fr_column_code
    , CAST(rc.col_cd AS string)                                                         AS column_code
    , CAST('IDS_RCOL' AS string)                                                        AS src_stm_code
    , CAST(rc.col_name_vi AS string)                                                    AS fr_column_nm
    , CAST(rc.col_name_en AS string)                                                    AS fr_column_english_nm
    , CAST(rc.col_index AS int)                                                         AS column_index
    , {{ generate_surrogate_key_bigint('IDS_REPORT_CATALOG', "rc.report_catalog_id") }} AS fr_catalog_id
    , CAST(re_ca.id AS string)                                                          AS fr_catalog_code
    , CAST(rc.col_type_cd AS string)                                                    AS column_tp_code
    , CAST(rc.col_formula AS string)                                                    AS column_formula
    , CAST(rc.report_year AS string)                                                    AS rpt_year
    , CAST(rc.rc_type_cd AS string)                                                     AS rpt_catalog_tp_code
    , CAST(rc.description AS string)                                                    AS description
    , CAST(rc.col_desc AS string)                                                       AS column_description_reference
    , CAST(rc.formula_desc AS string)                                                   AS formula_description_reference
FROM rc
    LEFT JOIN re_ca ON rc.report_catalog_id = re_ca.id

/*
*--------------------------------------------------------------------*
* Program code: atm_fr_row
* Program name: Atomic Financial Report Row
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Refactor to SCD2 and align with LLD lld_IDS_RROW.yaml
*--------------------------------------------------------------------*
*/

WITH rr AS (
    SELECT
        id
        , row_cd
        , row_name_vi
        , row_name_en
        , row_type_cd
        , row_formula
        , row_index
        , report_catalog_id
        , report_year
        , rc_type_cd
        , description
        , row_desc
        , formula_desc
    FROM {{ ref('ods_ids_rrow') }}
),

re_ca AS (
    SELECT
        id
    FROM {{ ref('ods_ids_report_catalog') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_RROW', "rr.id") }}                            AS fr_row_id
    , CAST(rr.id AS string)                                                             AS fr_row_code
    , CAST(rr.row_cd AS string)                                                         AS row_code
    , CAST('IDS_RROW' AS string)                                                        AS src_stm_code
    , CAST(rr.row_name_vi AS string)                                                    AS fr_row_nm
    , CAST(rr.row_name_en AS string)                                                    AS fr_row_english_nm
    , CAST(rr.row_type_cd AS string)                                                    AS row_tp_code
    , CAST(rr.row_formula AS string)                                                    AS row_formula
    , CAST(rr.row_index AS int)                                                         AS row_index
    , {{ generate_surrogate_key_bigint('IDS_REPORT_CATALOG', "rr.report_catalog_id") }} AS fr_catalog_id
    , CAST(re_ca.id AS string)                                                          AS fr_catalog_code
    , CAST(rr.report_year AS string)                                                    AS rpt_year
    , CAST(rr.rc_type_cd AS string)                                                     AS rpt_catalog_tp_code
    , CAST(rr.description AS string)                                                    AS description
    , CAST(rr.row_desc AS string)                                                       AS row_description_reference
    , CAST(rr.formula_desc AS string)                                                   AS formula_description_reference
FROM rr
    LEFT JOIN re_ca ON rr.report_catalog_id = re_ca.id

/*
*--------------------------------------------------------------------*
* Program code: atm_fr_catalog
* Program name: Atomic Financial Report Catalog
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Refactor to SCD2 and align with LLD lld_IDS_REPORT_CATALOG.yaml
*--------------------------------------------------------------------*
*/

WITH re_ca AS (
    SELECT
        id
        , report_cd
        , report_name_vi
        , report_name_en
        , rc_type_cd
        , report_year
        , report_scope_cd
        , enterprise_type_cd
        , consolidated_flg
        , financial_statement_cd
        , reporting_period_cd
        , ref_cd
    FROM {{ ref('ods_ids_report_catalog') }}
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_REPORT_CATALOG', "re_ca.id") }} AS fr_catalog_id
    , CAST(re_ca.id AS string)                                            AS fr_catalog_code
    , CAST('IDS_REPORT_CATALOG' AS string)                                AS src_stm_code
    , CAST(re_ca.report_cd AS string)                                     AS rpt_code
    , CAST(re_ca.report_name_vi AS string)                                AS fr_catalog_nm
    , CAST(re_ca.report_name_en AS string)                                AS fr_catalog_english_nm
    , CAST(re_ca.rc_type_cd AS string)                                    AS rpt_catalog_tp_code
    , CAST(re_ca.report_year AS string)                                   AS fr_year
    , CAST(re_ca.report_scope_cd AS string)                               AS fr_scope_tp_code
    , CAST(re_ca.enterprise_type_cd AS string)                            AS enterprise_tp_code
    , CAST(re_ca.consolidated_flg AS int)                                 AS consolidated_ind
    , CAST(re_ca.financial_statement_cd AS string)                        AS financial_statement_tp_code
    , CAST(re_ca.reporting_period_cd AS string)                           AS reporting_period_tp_code
    , CAST(re_ca.ref_cd AS string)                                        AS financial_statement_component_tp_code
FROM re_ca

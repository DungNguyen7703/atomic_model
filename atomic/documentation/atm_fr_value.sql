/*
*--------------------------------------------------------------------*
* Program code: atm_fr_value
* Program name: Atomic Financial Report Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-22		antigravity			Refactor to SCD1/Upsert and align with LLD lld_IDS_DATA.yaml
* 2026-10-22		tuan.nguyenvanb		[DOI TEN theo design 2026-10-21] data_val -> cell_val (vi tri cot khong doi; GIU decimal(38,8), design ghi decimal(23,2)
*									nhung thu hep kieu co the mat do chinh xac - can Data Modeler xac nhan). Bang vat ly can RENAME COLUMN truoc khi chay.
*--------------------------------------------------------------------*
*/

WITH data AS (
    SELECT
        id
        , report_catalog_id
        , company_profile_id
        , row_cd
        , col_cd
        , data_value
        , report_year
        , report_quarter
        , cell_enabled_flg
        , rc_type
        , ROW_NUMBER() OVER (
            PARTITION BY
                report_catalog_id
                , report_year
                , report_quarter
                , rc_type
                , row_cd
                , col_cd
                , company_profile_id
            ORDER BY
                updated_date DESC
                , created_date DESC
                , id DESC
        ) AS rid
    FROM {{ ref('ods_ids_data') }}
),

dedup_data AS (
    SELECT
        id
        , report_catalog_id
        , company_profile_id
        , row_cd
        , col_cd
        , data_value
        , report_year
        , report_quarter
        , cell_enabled_flg
        , rc_type
    FROM data 
    WHERE rid = 1
),

re_ca AS (
    SELECT
        id
    FROM {{ ref('ods_ids_report_catalog') }}
)

SELECT 
    {{ generate_surrogate_key_bigint('IDS_DATA', "data.id") }}                               AS fr_val_id
    , CAST(data.id AS string)                                                                AS fr_val_code
    , CAST('IDS_DATA' AS string)                                                             AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_REPORT_CATALOG', "data.report_catalog_id") }}    AS fr_catalog_id
    , CAST(re_ca.id AS string)                                                               AS fr_catalog_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "data.company_profile_id") }} AS pc_id
    , CAST(data.company_profile_id AS string)                                                AS pc_code
    , CAST(data.row_cd AS string)                                                            AS row_code
    , CAST(data.col_cd AS string)                                                            AS column_code
    , CAST(data.data_value AS decimal(38,8))                                                 AS cell_val
    , CAST(data.report_year AS int)                                                          AS rpt_year
    , CAST(data.report_quarter AS int)                                                       AS rpt_quarter
    , CAST(data.cell_enabled_flg AS int)                                                     AS cell_enabled_ind
    , CAST(data.rc_type AS string)                                                           AS rpt_catalog_tp_code
FROM dedup_data data
    LEFT JOIN re_ca ON data.report_catalog_id = re_ca.id

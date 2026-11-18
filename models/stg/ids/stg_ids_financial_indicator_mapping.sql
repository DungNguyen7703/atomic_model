/*
*--------------------------------------------------------------------*
* Program code: stg_ids_financial_indicator_mapping
* Program name: Staging IDS.FINANCIAL_INDICATOR_MAPPING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo GMS_IDS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))          AS id
    , CAST(report_year AS int)           AS report_year
    , CAST(report_cd AS string)          AS report_cd
    , CAST(row_desc AS string)           AS row_desc
    , CAST(indicator_desc_vi AS string)  AS indicator_desc_vi
    , CAST(target_column AS string)      AS target_column
    , CAST(prev_target_column AS string) AS prev_target_column
    , CAST(note AS string)               AS note
    , CAST(active_flg AS int)            AS active_flg
    , CAST(created_by AS string)         AS created_by
    , CAST(created_date AS timestamp)    AS created_date
    , CAST(updated_by AS string)         AS updated_by
    , CAST(updated_date AS timestamp)    AS updated_date
FROM {{ source('source_ids', 'raw_financial_indicator_mapping') }}
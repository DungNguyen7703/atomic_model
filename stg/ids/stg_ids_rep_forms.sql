/*
*--------------------------------------------------------------------*
* Program code: stg_ids_rep_forms
* Program name: Staging IDS.REP_FORMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(report_cd AS string)         AS report_cd
    , CAST(report_name_vi AS string)    AS report_name_vi
    , CAST(report_name_en AS string)    AS report_name_en
    , CAST(rp_report_type_cd AS string) AS rp_report_type_cd
    , CAST(published_flg AS int)        AS published_flg
    , CAST(report_link AS string)       AS report_link
    , CAST(created_by AS string)        AS created_by
    , CAST(created_date AS date)        AS created_date
    , CAST(updated_by AS string)        AS updated_by
    , CAST(updated_date AS date)        AS updated_date
    , CAST(delete_flg AS int)           AS delete_flg
    , CAST(system_cd AS string)         AS system_cd
FROM {{ source('source_ids', 'raw_rep_forms') }}
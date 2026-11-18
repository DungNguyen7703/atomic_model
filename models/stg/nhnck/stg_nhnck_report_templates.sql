/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_report_templates
* Program name: Staging NHNCK.REPORT_TEMPLATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (1 cot); kieu date sang timestamp (1 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(module_id AS string)     AS module_id
    , CAST(report_code AS string)   AS report_code
    , CAST(report_name AS string)   AS report_name
    , CAST(template_json AS string) AS template_json
    , CAST(query_config AS string)  AS query_config
    , CAST(status AS bigint)        AS status
    , CAST(created_at AS timestamp) AS created_at
    , CAST(created_by AS string)    AS created_by
FROM {{ source('source_nhnck', 'raw_report_templates') }}

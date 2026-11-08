/*
*--------------------------------------------------------------------*
* Program code: ods_ids_data
* Program name: ODS IDS.DATA
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , report_catalog_id
        , data_value
        , report_year
        , report_quarter
        , cell_enabled_flg
        , rc_type
        , row_cd
        , col_cd
        , created_by
        , created_date
        , updated_by
        , updated_date
        , company_profile_id
    FROM {{ ref('stg_ids_data') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    id
    , report_catalog_id
    , data_value
    , report_year
    , report_quarter
    , cell_enabled_flg
    , rc_type
    , row_cd
    , col_cd
    , created_by
    , created_date
    , updated_by
    , updated_date
    , company_profile_id
FROM src
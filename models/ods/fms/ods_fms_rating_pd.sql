/*
*--------------------------------------------------------------------*
* Program code: ods_fms_rating_pd
* Program name: ODS FMS.RATING_PD
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , report_year
    , period
    , record_status
    , update_data_rating
    , rating_finalized
FROM {{ ref('stg_fms_rating_pd') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
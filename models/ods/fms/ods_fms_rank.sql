/*
*--------------------------------------------------------------------*
* Program code: ods_fms_rank
* Program name: ODS FMS.RANK
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
    , sec_id
    , rt_pd_id
    , total_score
    , rank_index
    , rank_type
FROM {{ ref('stg_fms_rank') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
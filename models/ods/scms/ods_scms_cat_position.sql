/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_position
* Program name: ODS SCMS.CAT_POSITION
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
    , position_group
    , position_code
    , position_name
    , note
    , created_by
    , created_at
    , record_status
    , representative
    , board_member
    , branch_director
    , ecatalog_id
FROM {{ ref('stg_scms_cat_position') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
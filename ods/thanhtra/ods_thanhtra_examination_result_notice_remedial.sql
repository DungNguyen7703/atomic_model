/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_examination_result_notice_remedial
* Program name: ODS THANHTRA.EXAMINATION_RESULT_NOTICE_REMEDIAL
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
    , examination_result_notice_id
    , description
    , sort_order
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
FROM {{ ref('stg_thanhtra_examination_result_notice_remedial') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0
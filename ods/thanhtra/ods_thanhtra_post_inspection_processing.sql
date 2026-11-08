/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_post_inspection_processing
* Program name: ODS THANHTRA.POST_INSPECTION_PROCESSING
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
    , inspection_conclusion_id
    , requirement_type
    , responsible_party
    , due_date
    , status
    , implementation_notes
    , last_updated_date
    , monitoring_officer_id
    , monitoring_officer_name
    , created_at
    , created_by
    , last_modified_at
    , last_modified_by
    , version
    , deleted
    , requirement_summary
    , result_summary
FROM {{ ref('stg_thanhtra_post_inspection_processing') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0
/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_inspection_conclusion
* Program name: ODS THANHTRA.INSPECTION_CONCLUSION
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
    , inspection_team_id
    , conclusion_number
    , issued_date
    , announced_date
    , target_type
    , target_reference_id
    , target_name
    , content
    , government_inspector_sent_date
    , recommendation
    , execution_status
    , execution_description
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , transferred
FROM {{ ref('stg_thanhtra_inspection_conclusion') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0
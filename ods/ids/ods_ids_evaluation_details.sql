/*
*--------------------------------------------------------------------*
* Program code: ods_ids_evaluation_details
* Program name: ODS IDS.EVALUATION_DETAILS
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
    , evaluation_id
    , criterion_id
    , result
    , score
    , evaluate
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_evaluation_details') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
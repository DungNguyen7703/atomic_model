/*
*--------------------------------------------------------------------*
* Program code: ods_ids_evaluations
* Program name: ODS IDS.EVALUATIONS
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
    , company_id
    , period_id
    , total_score
    , evaluation_date
    , type
    , status
    , approved_by
    , approved_date
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_evaluations') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
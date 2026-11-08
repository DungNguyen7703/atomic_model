/*
*--------------------------------------------------------------------*
* Program code: ods_ids_evaluation_periods
* Program name: ODS IDS.EVALUATION_PERIODS
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
    , year
    , month
    , description
    , status
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_evaluation_periods') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
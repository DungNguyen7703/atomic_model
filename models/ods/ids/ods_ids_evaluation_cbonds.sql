/*
*--------------------------------------------------------------------*
* Program code: ods_ids_evaluation_cbonds
* Program name: ODS IDS.EVALUATION_CBONDS
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
    , business_reg_no
    , equity_ticker
    , company_id
    , name
    , ranking
    , year
    , month
    , per_tp_db
    , price_tp_lh
    , created_by
    , created_date
    , updated_by
    , updated_date
FROM {{ ref('stg_ids_evaluation_cbonds') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
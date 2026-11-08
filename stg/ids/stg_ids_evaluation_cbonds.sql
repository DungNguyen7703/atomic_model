/*
*--------------------------------------------------------------------*
* Program code: stg_ids_evaluation_cbonds
* Program name: Staging IDS.EVALUATION_CBONDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(business_reg_no AS string) AS business_reg_no
    , CAST(equity_ticker AS string)   AS equity_ticker
    , CAST(company_id AS int)         AS company_id
    , CAST(name AS string)            AS name
    , CAST(ranking AS string)         AS ranking
    , CAST(year AS int)               AS year
    , CAST(month AS int)              AS month
    , CAST(per_tp_db AS int)          AS per_tp_db
    , CAST(price_tp_lh AS int)        AS price_tp_lh
    , CAST(created_by AS string)      AS created_by
    , CAST(created_date AS date)      AS created_date
    , CAST(updated_by AS string)      AS updated_by
    , CAST(updated_date AS date)      AS updated_date
FROM {{ source('source_ids', 'raw_evaluation_cbonds') }}
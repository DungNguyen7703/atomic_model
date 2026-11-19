/*
*--------------------------------------------------------------------*
* Program code: ods_fms_mb_change
* Program name: ODS FMS.MB_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*--------------------------------------------------------------------*
*/

SELECT
    id
    , date_created
    , created_by
    , date_modified
    , modify_by
    , mbf_id
    , tx_date
    , tx_num
    , aoorp
    , bus_date
    , prepercent
    , aft_percent
    , pre_qtty
    , aft_qtty
    , precapital
    , aft_capital
FROM {{ ref('stg_fms_mb_change') }}
WHERE date_created >= TO_TIMESTAMP('{{ var("etl_date") }}')
  AND date_created < TO_TIMESTAMP('{{ var("etl_date") }}') + INTERVAL 1 DAY
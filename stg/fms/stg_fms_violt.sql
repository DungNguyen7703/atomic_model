/*
*--------------------------------------------------------------------*
* Program code: stg_fms_violt
* Program name: Staging FMS.VIOLT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                              AS id
    , HEX(user_id)                       AS user_id
    , HEX(pr_wid)                        AS pr_wid
    , HEX(cdt_wid)                       AS cdt_wid
    , CAST(system_object AS bigint)      AS system_object
    , HEX(sec_id)                        AS sec_id
    , HEX(fud_id)                        AS fud_id
    , HEX(bkm_id)                        AS bkm_id
    , HEX(fr_br_id)                      AS fr_br_id
    , CAST(report_year AS bigint)        AS report_year
    , CAST(item_value AS decimal(38,0))  AS item_value
    , CAST(date_created AS date)         AS date_created
    , CAST(period_type AS bigint)        AS period_type
    , CAST(period_value AS string)       AS period_value
    , CAST(period_type_other AS bigint)  AS period_type_other
    , CAST(period_value_other AS string) AS period_value_other
    , CAST(value_other AS decimal(18,2)) AS value_other
    , CAST(record_status AS int)         AS record_status
    , HEX(run_batch_id)                  AS run_batch_id
    , CAST(recovery_status AS bigint)    AS recovery_status
    , HEX(distributor_id)                AS distributor_id
    , HEX(transfer_agent_id)             AS transfer_agent_id
    , HEX(pension_agent_id)              AS pension_agent_id
    , HEX(pension_provider_id)           AS pension_provider_id
    , HEX(other_agent_id)                AS other_agent_id
    , HEX(pension_fund_id)               AS pension_fund_id
FROM {{ source('source_fms', 'raw_violt') }}
WHERE date_format(date_created, 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
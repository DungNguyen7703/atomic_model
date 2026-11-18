/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_account_opening_closing_status
* Program name: ODS VSDC.ACCOUNT_OPENING_CLOSING_STATUS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(depository_member AS string)                    AS depository_member
    , CAST(begin_period_dom_indiv_accounts AS bigint)     AS begin_period_dom_indiv_accounts
    , CAST(begin_period_dom_inst_accounts AS bigint)      AS begin_period_dom_inst_accounts
    , CAST(begin_period_for_indiv_accounts AS bigint)     AS begin_period_for_indiv_accounts
    , CAST(begin_period_for_inst_accounts AS bigint)      AS begin_period_for_inst_accounts
    , CAST(begin_period_total_accounts AS bigint)         AS begin_period_total_accounts
    , CAST(opened_dom_indiv_accounts AS bigint)           AS opened_dom_indiv_accounts
    , CAST(opened_dom_inst_accounts AS bigint)            AS opened_dom_inst_accounts
    , CAST(opened_for_indiv_accounts AS bigint)           AS opened_for_indiv_accounts
    , CAST(opened_for_inst_accounts AS bigint)            AS opened_for_inst_accounts
    , CAST(closed_dom_indiv_accounts AS bigint)           AS closed_dom_indiv_accounts
    , CAST(closed_dom_inst_accounts AS bigint)            AS closed_dom_inst_accounts
    , CAST(closed_for_indiv_accounts AS bigint)           AS closed_for_indiv_accounts
    , CAST(closed_for_inst_accounts AS bigint)            AS closed_for_inst_accounts
    , CAST(end_period_dom_indiv_accounts AS bigint)       AS end_period_dom_indiv_accounts
    , CAST(end_period_dom_inst_accounts AS bigint)        AS end_period_dom_inst_accounts
    , CAST(end_period_for_indiv_accounts AS bigint)       AS end_period_for_indiv_accounts
    , CAST(end_period_for_inst_accounts AS bigint)        AS end_period_for_inst_accounts
    , CAST(total_accounts AS bigint)                      AS total_accounts
    , CAST(notes AS string)                               AS notes
    , CAST(ds_snpst_dt AS date)                           AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_account_opening_closing_status') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

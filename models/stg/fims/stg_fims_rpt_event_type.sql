/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_event_type
* Program name: Staging FIMS.RPT_EVENT_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                           AS id
    , CAST(event_code AS string)                 AS event_code
    , CAST(event_name AS string)                 AS event_name
    , CAST(note AS string)                       AS note
    , CAST(system_object AS bigint)              AS system_object
    , CAST(event_category AS int)                AS event_category
    , CAST(obligation_type AS int)               AS obligation_type
    , CAST(requires_license AS int)              AS requires_license
    , CAST(deadline_calculation_method AS int)   AS deadline_calculation_method
    , CAST(catalog_active AS int)                AS catalog_active
    , CAST(deleted AS int)                       AS deleted
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(created_by AS string)                 AS created_by
    , CAST(last_modified_by AS string)           AS last_modified_by
    , CAST(legal_basis AS string)                AS legal_basis
    , CAST(self_set_report_period AS int)        AS self_set_report_period
    , CAST(report_net_asset_change AS int)       AS report_net_asset_change
    , CAST(fund_type_id AS bigint)               AS fund_type_id
    , CAST(agent_type_id AS bigint)              AS agent_type_id
    , CAST(rpt_template_report_id AS string)     AS rpt_template_report_id
    , CAST(rpt_template_disclosure_id AS string) AS rpt_template_disclosure_id
    , CAST(rpt_template_dossier_id AS string)    AS rpt_template_dossier_id
    , CAST(licensed_activity AS int)             AS licensed_activity
    , CAST(event_timing_before_after AS int)     AS event_timing_before_after
    , CAST(event_timing_days AS bigint)          AS event_timing_days
    , CAST(event_timing_unit AS int)             AS event_timing_unit
FROM {{ source('source_fims', 'raw_rpt_event_type') }}
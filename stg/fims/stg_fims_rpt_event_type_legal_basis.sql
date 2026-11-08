/*
*--------------------------------------------------------------------*
* Program code: stg_fims_rpt_event_type_legal_basis
* Program name: Staging FIMS.RPT_EVENT_TYPE_LEGAL_BASIS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(rpt_event_type_id AS bigint) AS rpt_event_type_id
    , CAST(sort_order AS bigint)        AS sort_order
    , CAST(content AS string)           AS content
FROM {{ source('source_fims', 'raw_rpt_event_type_legal_basis') }}
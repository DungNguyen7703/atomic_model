/*
*--------------------------------------------------------------------*
* Program code: stg_fms_announce
* Program name: Staging FMS.ANNOUNCE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    HEX(id)                                AS id
    , CAST(date_created AS date)           AS date_created
    , CAST(created_by AS string)           AS created_by
    , CAST(date_modified AS date)          AS date_modified
    , CAST(modify_by AS string)            AS modify_by
    , HEX(sec_id)                          AS sec_id
    , HEX(fund_id)                         AS fund_id
    , HEX(tl_pro_id)                       AS tl_pro_id
    , CAST(announce_type AS bigint)        AS announce_type
    , CAST(report_type AS int)             AS report_type
    , CAST(report_year AS bigint)          AS report_year
    , CAST(period_type AS bigint)          AS period_type
    , CAST(period_type_value AS string)    AS period_type_value
    , CAST(title AS string)                AS title
    , CAST(body AS string)                 AS body
    , CAST(note AS string)                 AS note
    , CAST(announce_date AS date)          AS announce_date
    , CAST(file_data AS string)            AS file_data
    , HEX(user_id)                         AS user_id
    , CAST(record_status AS decimal(38,0)) AS record_status
    , CAST(send_date AS date)              AS send_date
    , CAST(deadline_send AS date)          AS deadline_send
    , HEX(fr_br_id)                        AS fr_br_id
    , HEX(stf_fb_id)                       AS stf_fb_id
    , HEX(pension_fund_id)                 AS pension_fund_id
    , HEX(event_type_id)                   AS event_type_id
    , CAST(title_en AS string)             AS title_en
    , CAST(body_en AS string)              AS body_en
    , CAST(file_data_en AS string)         AS file_data_en
    , CAST(eform_data_json AS string)      AS eform_data_json
FROM {{ source('source_fms', 'raw_announce') }}
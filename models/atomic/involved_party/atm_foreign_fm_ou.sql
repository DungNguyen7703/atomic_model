/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_fm_ou
* Program name: Atomic Foreign Fund Management Organization Unit
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH fo_br AS (
    SELECT
        id,
        status_id,
        nat_id,
        branch_flag,
        item_name,
        en_name,
        short_name,
        start_date,
        end_date,
        parent_name,
        parent_code,
        change_license,
        change_license_date,
        change_note,
        note,
        capital,
        event_type_id
    FROM {{ ref('ods_fms_for_brch') }}
),

stat AS (
    SELECT
        id,
        code
    FROM {{ ref('ods_fms_status') }}
),

nati AS (
    SELECT
        id,
        sname
    FROM {{ ref('ods_fms_national') }}
),

ev_ty AS (
    SELECT
        id,
        event_code
    FROM {{ ref('ods_fms_event_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_FOR_BRCH', "fo_br.id") }}           AS foreign_fm_ou_id,
    CAST(fo_br.id AS string)                                                  AS foreign_fm_ou_code,
    CAST('FMS_FOR_BRCH' AS string)                                            AS src_stm_code,
    {{ generate_surrogate_key_bigint('FMS_STATUS', "stat.code") }}            AS cl_fms_status_id,
    CAST(stat.code AS string)                                                 AS cl_fms_status_code,
    {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }}         AS country_of_registration_id,
    CAST(nati.sname AS string)                                                AS country_of_registration_code,
    CAST(fo_br.branch_flag AS string)                                         AS ou_tp_code,
    CAST(fo_br.item_name AS string)                                           AS foreign_fm_ou_full_nm,
    CAST(fo_br.en_name AS string)                                             AS foreign_fm_ou_english_nm,
    CAST(fo_br.short_name AS string)                                          AS foreign_fm_ou_short_nm,
    CAST(fo_br.start_date AS date)                                            AS effective_start_dt,
    CAST(fo_br.end_date AS date)                                              AS effective_end_dt,
    CAST(fo_br.parent_name AS string)                                         AS parent_ou_nm,
    CAST(fo_br.parent_code AS string)                                         AS parent_ou_code,
    CAST(fo_br.change_license AS string)                                      AS amendment_license_nbr,
    CAST(fo_br.change_license_date AS date)                                   AS amendment_license_dt,
    CAST(fo_br.change_note AS string)                                         AS amendment_note,
    CAST(fo_br.note AS string)                                                AS note,
    CAST(fo_br.capital AS decimal(23,2))                                      AS charter_capital_amt,
    {{ generate_surrogate_key_bigint('FMS_EVENT_TYPE', "ev_ty.event_code") }} AS cl_fms_event_tp_id,
    CAST(ev_ty.event_code AS string)                                          AS cl_fms_event_tp_code
FROM fo_br
LEFT JOIN stat 
    ON fo_br.STATUS_ID = stat.ID
LEFT JOIN nati 
    ON fo_br.NAT_ID = nati.ID
LEFT JOIN ev_ty  
    ON fo_br.EVENT_TYPE_ID = ev_ty.ID
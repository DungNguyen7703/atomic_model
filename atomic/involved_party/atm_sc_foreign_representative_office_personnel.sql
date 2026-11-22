/*
*--------------------------------------------------------------------*
* Program code: atm_sc_foreign_representative_office_personnel
* Program name: Atomic Securities Company Foreign Representative Office Personnel
* Created by: claude
* Created date: 2026-11-13
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-13		claude		[MOI] Tao model theo lld_SCMS_SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL.yaml (13 cot, Fundamental/scd4a); khoi phuc tu git 77a9749^, doi chieu LLD khop thu tu/ten cot
*--------------------------------------------------------------------*
*/

WITH fo_ro_pe AS (
    SELECT
        id
        , sc_firm_foreign_rep_office_id
        , full_name
        , nationality
        , position_json
        , rep_office_representative
        , appointment_date
        , dismissal_date
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_foreign_rep_office_personnel') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL', "fo_ro_pe.id") }}                    AS sc_foreign_representative_office_personnel_id
    , CAST(fo_ro_pe.id AS string)                                                                                      AS sc_foreign_representative_office_personnel_code
    , CAST('SCMS_SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL' AS string)                                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_FOREIGN_REP_OFFICE', "fo_ro_pe.sc_firm_foreign_rep_office_id") }} AS sc_foreign_ou_id
    , CAST(fo_ro_pe.sc_firm_foreign_rep_office_id AS string)                                                           AS sc_foreign_ou_code
    , CAST(fo_ro_pe.full_name AS string)                                                                               AS full_nm
    , CAST(fo_ro_pe.nationality AS string)                                                                             AS nationality
    , CAST(fo_ro_pe.position_json AS string)                                                                           AS position_json
    , CAST(fo_ro_pe.rep_office_representative AS int)                                                                  AS representative_office_representative_ind
    , CAST(fo_ro_pe.appointment_date AS date)                                                                          AS appointment_dt
    , CAST(fo_ro_pe.dismissal_date AS date)                                                                            AS dismissal_dt
    , CAST(fo_ro_pe.attachment_path AS string)                                                                         AS attachment_path
    , CAST(fo_ro_pe.note AS string)                                                                                    AS note
FROM fo_ro_pe
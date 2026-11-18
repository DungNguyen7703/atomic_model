/*
*--------------------------------------------------------------------*
* Program code: atm_sc_senior_personnel
* Program name: Atomic Securities Company Senior Personnel
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_se_pe AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_branch_id
        , sc_firm_transaction_office_id
        , sc_firm_rep_office_id
        , full_name
        , entity_type
        , gender
        , date_of_birth
        , place_of_birth
        , nationality_id
        , personnel_status
        , provisional
        , legal_representative
        , statutory_representative
        , disclosure_person_id_alt
        , department
        , position_id
        , position
        , appointment_date
        , work_start_date
        , dismissal_date
        , resignation_date
        , securities_license
        , shareholder_type
        , contributed_capital
        , ownership_ratio
        , ownership_ratio_date
        , report_content
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_senior_personnel') }}
),

sc_fi_in AS (
    SELECT
        sc_firm_info_id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
),

ca_na AS (
    SELECT
        id
        , nationality_code
    FROM {{ ref('ods_scms_cat_nationality') }}
),

ca_po AS (
    SELECT
        id
        , position_code
    FROM {{ ref('ods_scms_cat_position') }}
),

-- [FIX] POSITION_ID nguon la danh sach (list) ma chuoi CSV (vd '8,1') khi 1
-- nguoi giu nhieu chuc vu dong thoi, khong phai gia tri don nhu ten cot the
-- hien. Explode tung ma chuc vu, map sang CAT_POSITION.POSITION_CODE, roi
-- gom lai thanh mang theo dung id goc de GIU NGUYEN grain 1 nguoi = 1 dong
-- (khong doi unique_key, khong anh huong cac model datamart khac dang dung
-- sc_senior_personnel_id lam khoa 1-1).
sc_fi_se_pe_position_tokens AS (
    SELECT
        sc_fi_se_pe.id AS id
        , trim(pos_tok) AS position_id_token
    FROM sc_fi_se_pe
    LATERAL VIEW OUTER explode(split(CAST(sc_fi_se_pe.position_id AS string), ',')) pt AS pos_tok
),

ca_po_multi AS (
    SELECT
        t.id
        , collect_list(DISTINCT ca_po.position_code) AS cl_sc_position_codes
    FROM sc_fi_se_pe_position_tokens t
    LEFT JOIN ca_po ON CAST(ca_po.id AS string) = t.position_id_token
    GROUP BY t.id
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SENIOR_PERSONNEL', "sc_fi_se_pe.id") }}                                AS sc_senior_personnel_id
    , CAST(sc_fi_se_pe.id AS string)                                                                                      AS sc_senior_personnel_code
    , CAST('SCMS_SC_FIRM_SENIOR_PERSONNEL' AS string)                                                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                                           AS sc_id
    , CAST(sc_fi_in.code AS string)                                                                                       AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_se_pe.sc_firm_branch_id") }}                         AS branch_ou_id
    , CAST(sc_fi_se_pe.sc_firm_branch_id AS string)                                                                       AS branch_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_TRANSACTION_OFFICE', "sc_fi_se_pe.sc_firm_transaction_office_id") }} AS transaction_office_ou_id
    , CAST(sc_fi_se_pe.sc_firm_transaction_office_id AS string)                                                           AS transaction_office_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_REP_OFFICE', "sc_fi_se_pe.sc_firm_rep_office_id") }}                 AS representative_office_ou_id
    , CAST(sc_fi_se_pe.sc_firm_rep_office_id AS string)                                                                   AS representative_office_ou_code
    , CAST(sc_fi_se_pe.full_name AS string)                                                                               AS full_nm
    , CAST(sc_fi_se_pe.entity_type AS string)                                                                             AS entity_tp_code
    , CAST(sc_fi_se_pe.gender AS string)                                                                                  AS gender_code
    , CAST(sc_fi_se_pe.date_of_birth AS date)                                                                             AS dt_of_birth
    , CAST(sc_fi_se_pe.place_of_birth AS string)                                                                          AS place_of_birth
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "ca_na.nationality_code") }}                                       AS nationality_id
    , CAST(ca_na.nationality_code AS string)                                                                              AS nationality_code
    , CAST(sc_fi_se_pe.personnel_status AS string)                                                                        AS personnel_status_code
    , CAST(sc_fi_se_pe.provisional AS int)                                                                                AS provisional_ind
    , CAST(sc_fi_se_pe.legal_representative AS int)                                                                       AS legal_representative_ind
    , CAST(sc_fi_se_pe.statutory_representative AS int)                                                                   AS statutory_representative_ind
    , CAST(sc_fi_se_pe.disclosure_person_id_alt AS int)                                                                   AS disclosure_person_ind
    , CAST(sc_fi_se_pe.department AS string)                                                                              AS department
    , transform(
          ca_po_multi.cl_sc_position_codes,
          code -> {{ generate_surrogate_key_bigint('SCMS_CAT_POSITION', 'code') }}
      )                                                                                                                   AS cl_sc_position_id
    , ca_po_multi.cl_sc_position_codes                                                                                    AS cl_sc_position_code
    , CAST(sc_fi_se_pe.position AS string)                                                                                AS position_nm
    , CAST(sc_fi_se_pe.appointment_date AS date)                                                                          AS appointment_dt
    , CAST(sc_fi_se_pe.work_start_date AS date)                                                                           AS work_start_dt
    , CAST(sc_fi_se_pe.dismissal_date AS date)                                                                            AS dismissal_dt
    , CAST(sc_fi_se_pe.resignation_date AS date)                                                                          AS resignation_dt
    , CAST(sc_fi_se_pe.securities_license AS int)                                                                         AS securities_license_ind
    , CAST(sc_fi_se_pe.shareholder_type AS string)                                                                        AS shareholder_tp_code
    , CAST(sc_fi_se_pe.contributed_capital AS decimal(23,2))                                                              AS contributed_capital_amt
    , CAST(sc_fi_se_pe.ownership_ratio AS decimal(5,2))                                                                   AS ownership_ratio_percentage
    , CAST(sc_fi_se_pe.ownership_ratio_date AS date)                                                                      AS ownership_ratio_dt
    , CAST(sc_fi_se_pe.report_content AS string)                                                                          AS rpt_content
    , CAST(sc_fi_se_pe.attachment_path AS string)                                                                         AS attachment_path
    , CAST(sc_fi_se_pe.note AS string)                                                                                    AS note
FROM sc_fi_se_pe
    LEFT JOIN sc_fi_in ON sc_fi_se_pe.SC_FIRM_INFO_ID = sc_fi_in.SC_FIRM_INFO_ID
    LEFT JOIN ca_na ON sc_fi_se_pe.NATIONALITY_ID = ca_na.ID
    LEFT JOIN ca_po_multi ON sc_fi_se_pe.id = ca_po_multi.id
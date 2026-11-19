/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_insider_related_person
* Program name: Atomic Fmc Insider Related Person
* Created by: tuan.nguyenvanb
* Created date: 2026-11-12
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-12		tuan.nguyenvanb		[MOI] Tao model theo lld_FMS_INSDER_RELA.yaml (Fundamental). UAT chua co model nay.
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , insder_id
        , rela_id
        , item_name
        , id_no
        , id_date
        , id_place
        , address
        , description
        , gp_qd_no
        , approval_date
    FROM {{ ref('ods_fms_insder_rela') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INSDER_RELA', "src.id") }}    AS fmc_insider_related_person_id
    , CAST(src.id AS string)                                              AS fmc_insider_related_person_code
    , CAST('FMS_INSDER_RELA' AS string)                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_INSIDER', "src.insder_id") }} AS fmc_insider_id
    , CAST(src.insder_id AS string)                                       AS fmc_insider_code
    , CAST(src.item_name AS string)                                       AS related_person_full_nm
    , CAST(src.id_no AS string)                                           AS related_person_identification_nbr
    , CAST(src.id_date AS date)                                           AS related_person_identification_issue_dt
    , CAST(src.id_place AS string)                                        AS related_person_identification_issue_place
    , CAST(src.address AS string)                                         AS related_person_adr_val
    , CAST(src.rela_id AS string)                                         AS rltnp_tp_code
    , CAST(src.description AS string)                                     AS description
    , CAST(src.gp_qd_no AS string)                                        AS decision_document_nbr
    , CAST(src.approval_date AS date)                                     AS approval_dt
FROM src

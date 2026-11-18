/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_foreign_investor_360_profile
* Program name: Dtm Opr Foreign Investor 360 Profile
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-29		tuan.nguyenvanb		Bổ sung cột investor_status_code
*									(BA STT 11 dòng 72, datamart_model.yaml)
* 2026-10-07		tuan.nguyenvanb		Đồng bộ LLD + Atomic FIMS UAT 20261006 (O_NDTNN_40):
*									- investor_tp_code/investor_status_code lấy từ
*									  cl_fims_investor_tp_code/cl_fims_status_code
*									- Bổ sung nationality_nm, investor_tp_nm,
*									  investor_status_nm, identification_nbr
* 2026-10-16		nghia.le			identification_nbr đổi từ string sang MẢNG (array<string>) theo DTM 2026-10-15:
*									bỏ lọc BUSINESS_LICENSE, lấy CẢ giấy tờ của NĐTNN (tổ chức có IdNo + BusinessNumber...),
*									gom collect_set theo ip_id để giữ 1 dòng/NĐT (trước đây LEFT JOIN nhân dòng theo số giấy tờ);
*									NĐT không có giấy tờ -> mảng rỗng. Khóa nối Nhóm 13 dùng has().
*--------------------------------------------------------------------*
* Ghi chu:
* - Atomic cl_fims_investor_type / cl_fims_status materialize SCD2 (khong
*   co _hstr): ban ghi hien hanh ds_rcrd_st = 'ACTIVE' AND
*   ds_rcrd_end_dt = to_date('2400-01-01').
*--------------------------------------------------------------------*
*/

WITH fo_in AS (
    SELECT
        foreign_investor_id,
        foreign_investor_code,
        full_nm,
        nationality_id,
        nationality_code,
        cl_fims_investor_tp_id,
        cl_fims_investor_tp_code,
        director_full_nm,
        custodian_bank_id,
        src_stm_code,
        cl_fims_status_id,
        cl_fims_status_code
    FROM {{ ref('atm_foreign_investor') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FIMS_INVESTOR'
),

ge_ar AS (
    SELECT
        geographic_area_id,
        geographic_area_nm
    FROM {{ ref('atm_geographic_area') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_COUNTRY'
),

cl_in_ty AS (
    SELECT
        cl_fims_investor_tp_id,
        cl_fims_investor_tp_nm
    FROM {{ ref('atm_cl_fims_investor_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        --AND ds_rcrd_end_dt = to_date('2400-01-01')
),

cu_ba AS (
    SELECT
        custodian_bank_full_nm,
        custodian_bank_id
    FROM {{ ref('atm_custodian_bank') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

cl_st AS (
    SELECT
        cl_fims_status_id,
        cl_fims_status_nm
    FROM {{ ref('atm_cl_fims_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        --AND ds_rcrd_end_dt = to_date('2400-01-01')
),

ip_al_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FIMS_INVESTOR'
        AND identification_nbr IS NOT NULL
)

SELECT
    CAST(fo_in.foreign_investor_code AS string)    AS investor_code,
    CAST(fo_in.full_nm AS string)                  AS investor_nm,
    CAST(fo_in.nationality_code AS string)         AS nationality_code,
    CAST(ge_ar.geographic_area_nm AS string)       AS nationality_nm,
    CAST(fo_in.cl_fims_investor_tp_code AS string) AS investor_tp_code,
    CAST(cl_in_ty.cl_fims_investor_tp_nm AS string) AS investor_tp_nm,
    CAST(fo_in.director_full_nm AS string)         AS director_nm,
    CAST(cu_ba.custodian_bank_full_nm AS string)   AS custodian_bank_nm,
    CAST(fo_in.src_stm_code AS string)             AS src_stm_code,
    CAST(fo_in.cl_fims_status_code AS string)      AS investor_status_code,
    CAST(cl_st.cl_fims_status_nm AS string)        AS investor_status_nm,
    CAST(ip_al_id.identification_nbr AS string)    AS identification_nbr
FROM fo_in
LEFT JOIN ge_ar
    ON  ge_ar.geographic_area_id = fo_in.nationality_id
LEFT JOIN cl_in_ty
    ON  cl_in_ty.cl_fims_investor_tp_id = fo_in.cl_fims_investor_tp_id
LEFT JOIN cu_ba
    ON  cu_ba.custodian_bank_id = fo_in.custodian_bank_id
LEFT JOIN cl_st
    ON  cl_st.cl_fims_status_id = fo_in.cl_fims_status_id
LEFT JOIN ip_al_id
    ON  ip_al_id.ip_id = fo_in.foreign_investor_id

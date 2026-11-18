/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_related_party_network
* Program name: Dtm Opr Individual Related Party Network
* Created by: tuan.nguyenvanb
* Created date: 2026-10-02
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[SUA] Bo sung self-join theo dung
*                                       LLD: r.sc_senior_personnel_id =
*                                       i.sc_senior_personnel_id AND
*                                       r.sc_insider_related_person_id !=
*                                       i.sc_insider_related_person_id, loai
*                                       tru ban ghi la chinh senior personnel.
* 2026-10-19		claude				[SUA theo LLD moi nhat, BA STT 41,
*                                       O_QLKD_38] Bo self-join va dieu kien
*                                       != id (LLD: "Khong self-join, khong
*                                       dieu kien != id"). Bo sung cot
*                                       relation_start_dt.
* 2026-10-29		tuan.nguyenvanb		[SUA theo dung LLD, ket qua ra soat doi
*                                       chieu Mapping] Bo sung nhanh UNION ALL
*                                       thu 2 con thieu hoan toan: SCMS_SC_FIRM_
*                                       MAJOR_SHAREHOLDER_RELATION (nguoi lien
*                                       quan cua co dong lon), theo dung file LLD
*                                       DTM_QLKD_opr_individual_related_party_
*                                       network_SCMS_SC_FIRM_MAJOR_SHAREHOLDER_
*                                       RELATION.csv va datamart_model.yaml
*                                       (DTM-opr_individual_related_party_network).
*                                       Doi PK tu sc_insider_related_person_code
*                                       (chi dung cho 1 nguon) sang
*                                       related_party_network_id (hash
*                                       src_stm_code + ma quan he), dung macro
*                                       generate_surrogate_key co san. Bo sung 2
*                                       cot con thieu hoan toan o nhanh cu:
*                                       effective_from_dt, effective_to_dt (LLD
*                                       yeu cau nhung code truoc day chua co).
*--------------------------------------------------------------------*
*/

WITH sc_in_re_pe AS (
    SELECT
        sc_insider_related_person_id,
        sc_insider_related_person_code,
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        full_nm,
        rltnp,
        representative_position,
        shares_count,
        ownership_ratio,
        relation_start_dt,
        src_rcrd_isrt_tms,
        src_stm_code
    FROM {{ ref('atm_sc_insider_related_person') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INSIDER_RELATION'
),

sc_se_pe_1 AS (
    SELECT
        sc_senior_personnel_id,
        sc_id,
        full_nm,
        appointment_dt,
        dismissal_dt
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

sp_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

ip_al_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification')}}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_INSIDER_RELATION'
),

rp_ident AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'NATIONAL_ID'
        AND src_stm_code = 'SCMS_SC_FIRM_RELATED_PERSON'
),

sc_re_pe AS (
    SELECT
        sc_related_person_id,
        sc_id,
        cl_sc_position_code
    FROM {{ ref('atm_sc_related_person') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

cl_sc_po_1 AS (
    SELECT
        cl_sc_position_code,
        cl_sc_position_nm
    FROM {{ ref('atm_cl_securities_company_position') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- Nhanh 1: nguoi lien quan cua nhan su cap cao (SCMS_SC_FIRM_INSIDER_RELATION)
insider_relation_branch AS (
    SELECT
        {{ generate_surrogate_key('OPR_IND_RELATED_NETWORK', "concat_ws('-', sc_in_re_pe.src_stm_code, sc_in_re_pe.sc_insider_related_person_code)") }} AS related_party_network_id,
        CAST(sp_id.identification_nbr AS string)         AS individual_identification_nbr,
        CAST(sc_se_pe_1.full_nm AS string)               AS individual_full_nm,
        CAST(sc_in_re_pe.sc_senior_personnel_code AS string)       AS sc_senior_personnel_code,
        CAST(sc_in_re_pe.full_nm AS string)                        AS related_person_full_nm,
        CAST(sc_in_re_pe.rltnp AS string)                          AS rltnp,
        CAST(sc_in_re_pe.representative_position AS string)        AS representative_position,
        CAST(cl_sc_po_1.cl_sc_position_nm AS string)     AS related_person_position_nm,
        CAST(ip_al_id.identification_nbr AS string)      AS identification_nbr,
        CAST(sc_in_re_pe.shares_count AS int)                      AS shares_count,
        CAST(sc_in_re_pe.ownership_ratio AS decimal(5,2))          AS ownership_ratio,
        CAST(sc_in_re_pe.relation_start_dt AS date)                AS relation_start_dt,
        GREATEST(CAST(sc_in_re_pe.src_rcrd_isrt_tms AS date), sc_se_pe_1.appointment_dt) AS effective_from_dt,
        CAST(sc_se_pe_1.dismissal_dt AS date)            AS effective_to_dt,
        CAST(sc_in_re_pe.src_stm_code AS string)                   AS src_stm_code
    FROM sc_in_re_pe
    JOIN sc_se_pe_1
        ON  sc_se_pe_1.sc_senior_personnel_id = sc_in_re_pe.sc_senior_personnel_id
    LEFT JOIN sp_id
        ON  sp_id.ip_id = sc_in_re_pe.sc_senior_personnel_id
    JOIN ip_al_id
        ON  ip_al_id.ip_id = sc_in_re_pe.sc_insider_related_person_id
    LEFT JOIN rp_ident
        ON  UPPER(REGEXP_REPLACE(TRIM(rp_ident.identification_nbr), '[^0-9A-Za-z]', '')) = UPPER(REGEXP_REPLACE(TRIM(ip_al_id.identification_nbr), '[^0-9A-Za-z]', ''))
    LEFT JOIN sc_re_pe
        ON  sc_re_pe.sc_related_person_id = rp_ident.ip_id
        AND sc_re_pe.sc_id = sc_se_pe_1.sc_id
    LEFT JOIN cl_sc_po_1
        ON  cl_sc_po_1.cl_sc_position_code = sc_re_pe.cl_sc_position_code
),

sc_ma_sh_re AS (
    SELECT
        sc_major_shareholder_relation_id,
        sc_major_shareholder_relation_code,
        sc_shareholder_id,
        full_nm,
        rltnp,
        relation_start_dt,
        relation_end_dt,
        ownership_ratio,
        shares_count,
        src_rcrd_isrt_tms,
        src_stm_code
    FROM {{ ref('atm_sc_major_shareholder_relation') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION'
),

sc_sh_ho AS (
    SELECT
        sc_shareholder_id,
        shareholder_nm,
        shareholder_tp_code,
        src_rcrd_isrt_tms
    FROM {{ ref('atm_sc_shareholder') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

sh_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

ma_sh_re_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'NATIONAL_ID'
        AND src_stm_code = 'SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION'
),

-- Nhanh 2: nguoi lien quan cua co dong lon (SCMS_SC_FIRM_MAJOR_SHAREHOLDER_RELATION)
major_shareholder_relation_branch AS (
    SELECT
        {{ generate_surrogate_key('OPR_IND_RELATED_NETWORK', "concat_ws('-', mr.src_stm_code, mr.sc_major_shareholder_relation_code)") }} AS related_party_network_id,
        CAST(sh_id.identification_nbr AS string)         AS individual_identification_nbr,
        CAST(sc_sh_ho.shareholder_nm AS string)          AS individual_full_nm,
        CAST(NULL AS string)                             AS sc_senior_personnel_code,
        CAST(mr.full_nm AS string)                       AS related_person_full_nm,
        CAST(mr.rltnp AS string)                         AS rltnp,
        CAST(NULL AS string)                             AS representative_position,
        CASE
            WHEN sc_sh_ho.shareholder_tp_code IN ('CDL', 'CO_DONG_LON') THEN 'Cổ đông lớn'
            WHEN sc_sh_ho.shareholder_tp_code IN ('CDSL', 'CO_DONG_SANG_LAP') THEN 'Cổ đông sáng lập'
            ELSE 'Khác'
        END                                                AS related_person_position_nm,
        CAST(ma_sh_re_id.identification_nbr AS string)   AS identification_nbr,
        CAST(mr.shares_count AS int)                     AS shares_count,
        CAST(mr.ownership_ratio AS decimal(5,2))         AS ownership_ratio,
        CAST(mr.relation_start_dt AS date)               AS relation_start_dt,
        GREATEST(CAST(mr.src_rcrd_isrt_tms AS date), CAST(sc_sh_ho.src_rcrd_isrt_tms AS date)) AS effective_from_dt,
        CAST(mr.relation_end_dt AS date)                 AS effective_to_dt,
        CAST(mr.src_stm_code AS string)                  AS src_stm_code
    FROM sc_ma_sh_re mr
    JOIN sc_sh_ho
        ON  sc_sh_ho.sc_shareholder_id = mr.sc_shareholder_id
    LEFT JOIN sh_id
        ON  sh_id.ip_id = mr.sc_shareholder_id
    LEFT JOIN ma_sh_re_id
        ON  ma_sh_re_id.ip_id = mr.sc_major_shareholder_relation_id
)

SELECT * FROM insider_relation_branch
UNION ALL
SELECT * FROM major_shareholder_relation_branch

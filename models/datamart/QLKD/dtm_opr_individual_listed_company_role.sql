/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_listed_company_role
* Program name: Dtm Opr Individual Listed Company Role
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-29		tuan.nguyenvanb		[SUA theo dung LLD, ket qua ra soat doi
*                                       chieu Mapping] Viet lai toan bo model:
*                                       noi dung cu chi co 1 nhanh doc tu
*                                       atm_sc_insider_related_person (logic cua
*                                       bang khac - opr_individual_related_party_
*                                       network), khong dung voi thiet ke. Thay
*                                       bang UNION ALL dung 4 nguon theo 4 file LLD
*                                       (DTM_QLKD_opr_individual_listed_company_role_
*                                       FMS_INSIDER/IDS_COMPANY_ENTITY_ROLE/SCMS_SC_
*                                       FIRM_SENIOR_PERSONNEL/SCMS_SC_FIRM_SHAREHOLDER.csv)
*                                       va datamart_model.yaml (DTM-opr_individual_
*                                       listed_company_role). PK doi sang
*                                       listed_company_role_id (hash), dung macro
*                                       generate_surrogate_key co san (dbt/macros/
*                                       mcr_generate_surrogate_key_sha256.sql).
* 2026-11-07		tra.nguyenthu		[FIX] atm_sc_senior_personnel.
*                                       cl_sc_position_code gio la ARRAY<string>
*                                       (1 nguoi co the giu nhieu chuc vu dong
*                                       thoi - xem fix tai atm_sc_senior_personnel.sql,
*                                       05/11). Bo JOIN truc tiep string=array voi
*                                       cl_securities_company_position (gay loi
*                                       DATATYPE_MISMATCH khi chay Airflow). Doi
*                                       sang resolve ten danh muc cho tung phan tu
*                                       mang bang map_from_entries/transform (dong
*                                       bo cach lam tai dtm_opr_securities_company_
*                                       personnel_profile.sql), roi array_join lai
*                                       thanh 1 string cho role_nm dung theo LLD
*                                       (LISTAGG tin ten CAT_POSITION).
*--------------------------------------------------------------------*
*/

WITH fmc_in AS (
    SELECT
        fmc_insider_id,
        fmc_insider_code,
        fmc_insider_full_nm,
        fmc_code,
        fmc_id,
        insider_tp_code,
        held_unit_quantity,
        employment_start_dt,
        src_stm_code,
        ds_rcrd_st
    FROM {{ ref('atm_fmc_insider') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'FMS_INSIDER'
),

fmc_in_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'FMS_INSIDER'
),

fund_mgmt_co AS (
    SELECT
        fmc_id,
        fmc_short_nm
    FROM {{ ref('atm_fund_management_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
),

pc_en_ro AS (
    SELECT
        legal_entity_id,
        pc_id,
        pc_code,
        role_tp_code,
        effective_from_dt,
        effective_to_dt,
        src_stm_code,
        ds_rcrd_st
    FROM {{ ref('atm_pc_entity_role') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'IDS_COMPANY_ENTITY_ROLE'
),

pc_en_ro_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'IDS_IDENTITY'
),

leg_en AS (
    SELECT
        legal_entity_id,
        legal_entity_nm
    FROM {{ ref('atm_legal_entity') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

pub_co AS (
    SELECT
        pc_id,
        equity_ticker_symbol
    FROM {{ ref('atm_public_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

leg_en_po AS (
    SELECT
        legal_entity_id,
        position_code,
        appointment_dt,
        dismissal_dt
    FROM {{ ref('atm_legal_entity_position') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

pc_sh_ho AS (
    SELECT
        legal_entity_id,
        pc_id,
        ownership_quantity,
        ownership_dt,
        data_updated_dt,
        ds_rcrd_st
    FROM {{ ref('atm_pc_shareholding') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

sc_se_pe AS (
    SELECT
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        full_nm,
        sc_code,
        sc_id,
        cl_sc_position_code,
        position_nm,
        appointment_dt,
        dismissal_dt,
        src_stm_code,
        ds_rcrd_st
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

sc_se_pe_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

sc_co_1 AS (
    SELECT
        sc_id,
        sc_short_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

cl_sc_po AS (
    SELECT
        cl_sc_position_code,
        cl_sc_position_nm
    FROM {{ ref('atm_cl_securities_company_position') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- [FIX] cl_sc_position_code o sc_se_pe gio la ARRAY<string> (nhieu chuc vu).
-- Build map code->ten de resolve tung phan tu mang (xem dtm_opr_securities_
-- company_personnel_profile.sql).
cl_sc_po_map AS (
    SELECT map_from_entries(collect_list(struct(cl_sc_position_code, cl_sc_position_nm))) AS code_to_nm
    FROM cl_sc_po
),

sc_sh_ho AS (
    SELECT
        sc_shareholder_id,
        sc_shareholder_code,
        shareholder_nm,
        sc_code,
        sc_id,
        shareholder_tp_code,
        shares_held,
        src_rcrd_isrt_tms,
        src_stm_code,
        ds_rcrd_st
    FROM {{ ref('atm_sc_shareholder') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

sc_sh_ho_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND identification_tp_code = 'IDENTIFICATION'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

sc_co_2 AS (
    SELECT
        sc_id,
        sc_short_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

-- Nhanh 1: FMS_INSIDER - vai tro tai Cong ty Quan ly Quy
fms_insider_branch AS (
    SELECT
        {{ generate_surrogate_key('OPR_IND_LISTED_ROLE', "concat_ws('-', fmc_in.src_stm_code, fmc_in.fmc_insider_code, fmc_in_id.identification_nbr)") }} AS listed_company_role_id,
        CAST(fmc_in_id.identification_nbr AS string)   AS individual_identification_nbr,
        CAST(fmc_in.fmc_insider_full_nm AS string)     AS individual_full_nm,
        CAST(fmc_in.fmc_code AS string)                AS org_code,
        CAST(fund_mgmt_co.fmc_short_nm AS string)       AS org_nm,
        CAST('Công ty Quản lý Quỹ' AS string)           AS org_tp_nm,
        CASE fmc_in.insider_tp_code
            WHEN '1' THEN 'Cổ đông lớn'
            WHEN '2' THEN 'Ban điều hành'
            WHEN '3' THEN 'HĐQT'
        END                                              AS role_nm,
        CAST(fmc_in.held_unit_quantity AS bigint)       AS shares_held_qty,
        CASE WHEN fmc_in.ds_rcrd_st = 'ACTIVE' THEN 'Đang hoạt động' ELSE 'Ngừng hoạt động' END AS status_nm,
        CAST(fmc_in.employment_start_dt AS date)        AS effective_from_dt,
        CAST(NULL AS date)                              AS effective_to_dt,
        CAST(fmc_in.src_stm_code AS string)             AS src_stm_code
    FROM fmc_in
    JOIN fmc_in_id
        ON  fmc_in_id.ip_id = fmc_in.fmc_insider_id
    LEFT JOIN fund_mgmt_co
        ON  fund_mgmt_co.fmc_id = fmc_in.fmc_id
    WHERE fmc_in.insider_tp_code IN ('1', '2', '3')
),

-- Nhanh 2: IDS_COMPANY_ENTITY_ROLE - vai tro tai cong ty dai chung
ids_entity_role_branch AS (
    SELECT
        {{ generate_surrogate_key('OPR_IND_LISTED_ROLE', "concat_ws('-', pc_en_ro.src_stm_code, pc_en_ro.pc_id, pc_en_ro_id.identification_nbr)") }} AS listed_company_role_id,
        CAST(pc_en_ro_id.identification_nbr AS string)  AS individual_identification_nbr,
        CAST(leg_en.legal_entity_nm AS string)          AS individual_full_nm,
        CAST(pc_en_ro.pc_code AS string)                AS org_code,
        CAST(pub_co.equity_ticker_symbol AS string)     AS org_nm,
        CAST('Công ty đại chúng' AS string)             AS org_tp_nm,
        COALESCE(
            (
                SELECT array_join(collect_list(position_code), ', ')
                FROM (
                    SELECT leg_en_po.position_code
                    FROM leg_en_po
                    WHERE leg_en_po.legal_entity_id = pc_en_ro.legal_entity_id
                        AND leg_en_po.appointment_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                        AND (leg_en_po.dismissal_dt IS NULL OR leg_en_po.dismissal_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                    ORDER BY leg_en_po.appointment_dt DESC
                ) ordered_position
            ),
            CASE pc_en_ro.role_tp_code
                WHEN 'NNB' THEN 'Người nội bộ'
                WHEN 'CD' THEN 'Cổ đông'
                ELSE 'Khác'
            END
        )                                                AS role_nm,
        pc_sh_latest.ownership_quantity                 AS shares_held_qty,
        CASE WHEN pc_en_ro.ds_rcrd_st = 'ACTIVE' THEN 'Đang hoạt động' ELSE 'Ngừng hoạt động' END AS status_nm,
        CAST(pc_en_ro.effective_from_dt AS date)        AS effective_from_dt,
        CAST(pc_en_ro.effective_to_dt AS date)          AS effective_to_dt,
        CAST(pc_en_ro.src_stm_code AS string)            AS src_stm_code
    FROM pc_en_ro
    JOIN pc_en_ro_id
        ON  pc_en_ro_id.ip_id = pc_en_ro.legal_entity_id
    LEFT JOIN leg_en
        ON  leg_en.legal_entity_id = pc_en_ro.legal_entity_id
    LEFT JOIN pub_co
        ON  pub_co.pc_id = pc_en_ro.pc_id
    LEFT JOIN (
        SELECT
            legal_entity_id,
            pc_id,
            ownership_quantity,
            COALESCE(ownership_dt, data_updated_dt) AS as_of_dt
        FROM pc_sh_ho sh2
        WHERE sh2.ds_rcrd_st = 'ACTIVE'
            AND COALESCE(sh2.ownership_dt, sh2.data_updated_dt) = (
                SELECT MAX(COALESCE(sh3.ownership_dt, sh3.data_updated_dt))
                FROM pc_sh_ho sh3
                WHERE sh3.legal_entity_id = sh2.legal_entity_id
                    AND sh3.pc_id = sh2.pc_id
                    AND sh3.ds_rcrd_st = 'ACTIVE'
                    AND COALESCE(sh3.ownership_dt, sh3.data_updated_dt) <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            )
    ) pc_sh_latest
        ON  pc_sh_latest.legal_entity_id = pc_en_ro.legal_entity_id
        AND pc_sh_latest.pc_id = pc_en_ro.pc_id
),

-- Nhanh 3: SCMS_SC_FIRM_SENIOR_PERSONNEL - vai tro tai CTCK (nhan su cap cao)
scms_senior_personnel_branch AS (
    SELECT
        {{ generate_surrogate_key('OPR_IND_LISTED_ROLE', "concat_ws('-', sc_se_pe.src_stm_code, sc_se_pe.sc_senior_personnel_code, sc_se_pe_id.identification_nbr)") }} AS listed_company_role_id,
        CAST(sc_se_pe_id.identification_nbr AS string)  AS individual_identification_nbr,
        CAST(sc_se_pe.full_nm AS string)                AS individual_full_nm,
        CAST(sc_se_pe.sc_code AS string)                AS org_code,
        CAST(sc_co_1.sc_short_nm AS string)              AS org_nm,
        CAST('Công ty chứng khoán' AS string)            AS org_tp_nm,
        CASE
            WHEN sc_se_pe.cl_sc_position_code IS NULL OR size(sc_se_pe.cl_sc_position_code) = 0
                THEN sc_se_pe.position_nm
            ELSE array_join(
                transform(
                    sc_se_pe.cl_sc_position_code,
                    code -> COALESCE(element_at(cl_sc_po_map.code_to_nm, code), sc_se_pe.position_nm)
                ),
                ', '
            )
        END                                              AS role_nm,
        CAST(NULL AS bigint)                            AS shares_held_qty,
        CASE WHEN sc_se_pe.ds_rcrd_st = 'ACTIVE' THEN 'Đang hoạt động' ELSE 'Ngừng hoạt động' END AS status_nm,
        CAST(sc_se_pe.appointment_dt AS date)           AS effective_from_dt,
        CAST(sc_se_pe.dismissal_dt AS date)             AS effective_to_dt,
        CAST(sc_se_pe.src_stm_code AS string)           AS src_stm_code
    FROM sc_se_pe
    LEFT JOIN sc_se_pe_id
        ON  sc_se_pe_id.ip_id = sc_se_pe.sc_senior_personnel_id
    LEFT JOIN sc_co_1
        ON  sc_co_1.sc_id = sc_se_pe.sc_id
    CROSS JOIN cl_sc_po_map
    WHERE sc_se_pe_id.identification_nbr IS NOT NULL
),

-- Nhanh 4: SCMS_SC_FIRM_SHAREHOLDER - vai tro co dong tai CTCK
scms_shareholder_branch AS (
    SELECT
        {{ generate_surrogate_key('OPR_IND_LISTED_ROLE', "concat_ws('-', sc_sh_ho.src_stm_code, sc_sh_ho.sc_shareholder_code, sc_sh_ho_id.identification_nbr)") }} AS listed_company_role_id,
        CAST(sc_sh_ho_id.identification_nbr AS string)  AS individual_identification_nbr,
        CAST(sc_sh_ho.shareholder_nm AS string)         AS individual_full_nm,
        CAST(sc_sh_ho.sc_code AS string)                AS org_code,
        CAST(sc_co_2.sc_short_nm AS string)              AS org_nm,
        CAST('Công ty chứng khoán' AS string)            AS org_tp_nm,
        CASE
            WHEN sc_sh_ho.shareholder_tp_code IN ('CDL', 'CO_DONG_LON') THEN 'Cổ đông lớn'
            WHEN sc_sh_ho.shareholder_tp_code IN ('CDSL', 'CO_DONG_SANG_LAP') THEN 'Cổ đông sáng lập'
            ELSE 'Khác'
        END                                              AS role_nm,
        CAST(sc_sh_ho.shares_held AS bigint)             AS shares_held_qty,
        CASE WHEN sc_sh_ho.ds_rcrd_st = 'ACTIVE' THEN 'Đang hoạt động' ELSE 'Ngừng hoạt động' END AS status_nm,
        CAST(sc_sh_ho.src_rcrd_isrt_tms AS date)    AS effective_from_dt,
        CAST(NULL AS date)                              AS effective_to_dt,
        CAST(sc_sh_ho.src_stm_code AS string)           AS src_stm_code
    FROM sc_sh_ho
    JOIN sc_sh_ho_id
        ON  sc_sh_ho_id.ip_id = sc_sh_ho.sc_shareholder_id
    LEFT JOIN sc_co_2
        ON  sc_co_2.sc_id = sc_sh_ho.sc_id
)

SELECT * FROM fms_insider_branch
UNION ALL
SELECT * FROM ids_entity_role_branch
UNION ALL
SELECT * FROM scms_senior_personnel_branch
UNION ALL
SELECT * FROM scms_shareholder_branch

/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_personnel_profile
* Program name: Dtm Opr Securities Company Personnel Profile
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-28		tuan.nguyenvanb		[SUA theo dung LLD] Bo sung cot
*                                       cl_sc_position_code con thieu (LLD
*                                       dong 6, nguon sc_senior_personnel.
*                                       cl_sc_position_code, direct). Sua
*                                       position_nm theo dung cong thuc LLD
*                                       dong 7: LEFT JOIN danh muc
*                                       atm_cl_securities_company_position
*                                       ON cl_sc_position_code, lay
*                                       COALESCE(cl_sc_position_nm nguon danh
*                                       muc, position_nm nhap tay) thay vi
*                                       lay thang position_nm nhu truoc.
* 2026-11-05		tra.nguyenthu		[FIX] atm_sc_senior_personnel.
*                                       cl_sc_position_code gio la ARRAY<string>
*                                       (1 nguoi co the giu nhieu chuc vu dong
*                                       thoi - xem fix tai atm_sc_senior_personnel.sql).
*                                       Doi CAST string -> giu nguyen kieu array;
*                                       JOIN danh muc doi sang resolve TUNG phan
*                                       tu trong mang (transform) thay vi join
*                                       1-1 string=string.
* 2026-11-05		tra.nguyenthu		[BO SUNG] Khoi phuc cot cl_sc_position_id
*                                       (FK toi danh muc cl_securities_company_
*                                       position, theo dung LLD) dang ARRAY<string>,
*                                       dong bo theo index voi cl_sc_position_code.
*                                       Truyen thang tu Atomic, khong bien doi them.
*--------------------------------------------------------------------*
*/

WITH sc_se_pe AS (
    SELECT
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        sc_code,
        full_nm,
        department,
        cl_sc_position_code,
        position_nm,
        work_start_dt,
        dismissal_dt,
        personnel_status_code,
        src_stm_code
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

ip_el_adr AS (
    SELECT
        ip_id,
        MAX(CASE WHEN electronic_adr_tp_code = 'EMAIL' THEN electronic_adr_val END) AS email,
        MAX(CASE WHEN electronic_adr_tp_code = 'PHONE' THEN electronic_adr_val END) AS phone
    FROM {{ ref('atm_ip_electronic_address') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND electronic_adr_tp_code IN ('EMAIL', 'PHONE')
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
    GROUP BY ip_id
),

cl_sc_position AS (
    SELECT
        cl_sc_position_code,
        cl_sc_position_nm
    FROM {{ ref('atm_cl_securities_company_position') }}
),

-- [FIX] cl_sc_position_code gio la ARRAY<string> (nhieu chuc vu). Resolve
-- ten danh muc cho TUNG phan tu cua mang bang 1 ban do code->ten (map), roi
-- dung transform() de tra ve mang ten tuong ung, giu nguyen grain 1 dong/nguoi.
cl_sc_position_map AS (
    SELECT map_from_entries(collect_list(struct(cl_sc_position_code, cl_sc_position_nm))) AS code_to_nm
    FROM cl_sc_position
)

SELECT
    CAST(sc_se_pe.sc_senior_personnel_code AS string) AS sc_senior_personnel_code,
    CAST(sc_se_pe.sc_code AS string)                  AS sc_code,
    CAST(sc_se_pe.full_nm AS string)                  AS full_nm,
    CAST(sc_se_pe.department AS string)               AS department,
    sc_se_pe.cl_sc_position_code                      AS cl_sc_position_code,
    CASE
        WHEN sc_se_pe.cl_sc_position_code IS NULL OR size(sc_se_pe.cl_sc_position_code) = 0
            THEN array(sc_se_pe.position_nm)
        ELSE transform(
            sc_se_pe.cl_sc_position_code,
            code -> COALESCE(element_at(cl_sc_position_map.code_to_nm, code), sc_se_pe.position_nm)
        )
    END                                                AS position_nm,
    CAST(ip_el_adr.email AS string)                   AS email,
    CAST(ip_el_adr.phone AS string)                   AS phone,
    CAST(sc_se_pe.work_start_dt AS date)              AS work_start_dt,
    CAST(sc_se_pe.dismissal_dt AS date)               AS dismissal_dt,
    CAST(sc_se_pe.personnel_status_code AS string)    AS personnel_status_code,
    CAST(sc_se_pe.src_stm_code AS string)             AS src_stm_code
FROM sc_se_pe
LEFT JOIN ip_el_adr
    ON  ip_el_adr.ip_id = sc_se_pe.sc_senior_personnel_id
CROSS JOIN cl_sc_position_map

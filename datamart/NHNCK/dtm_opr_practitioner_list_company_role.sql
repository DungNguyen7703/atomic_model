/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_list_company_role
* Program name: Dtm Opr Practitioner List Company Role
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-12		Dai					Grain (practitioner_code, securities_company_code) theo LLD.
* 2026-09-11		nam.tranhoai		Driving đổi sang dtm_securities_practitioner_dim (chỉ NHN có Certificate_Record);
*										join nhnck_id qua securities_practitioner_dim_id (= sp_id).
* 2026-10-22		duc.luxuan			BA update Nhóm 7 (panel TÀI KHOẢN): nạp 4 cột VSDC (trước để NULL) từ
*										atm_investment_account + atm_major_shareholder_ownership; bỏ lọc
*										individual_indicator (SCMS shareholder) và listed_indicator (SCMS firm) theo BA.
* 2026-11-03		claude				Đồng bộ LLD 2026-11-02 (đổi driving table): driving = atm_sp_organization_employment_report.
* 2026-11-05		claude				Đồng bộ LLD 2026-11-03 (O_NHNCK_43..46): đổi driving lần nữa theo SQL BA Nhóm 7 dòng 61:
*										driving = atm_sc_shareholder (SCMS.SC_FIRM_SHAREHOLDER), cổ đông cá nhân (individual_ind = 1)
*										của DN niêm yết (securities_company.listed_ind = 1, shares_held / sc_short_nm NOT NULL).
*										NHN nối với cổ đông qua số giấy tờ định danh (ip_alternative_identification SCMS <-> NHNCK).
*										PK (practitioner_code, sc_shareholder_code). Thêm sc_shareholder_code,
*										securities_company_code, securities_company_short_nm, representative_position;
*										shares_held = sc_shareholder.shares_held (bigint). Bỏ organization_employment_rpt_code,
*										securities_organization_reference_code, practitioner_workplace_at_rpt,
*										practitioner_position_at_rpt và 4 cột VSDC (account_nbr, account_holder_nm,
*										main_held_securities_code, vsdc_held_securities_vol) — chuyển sang
*										dtm_opr_practitioner_account_holding. practice_status_code/nm: NHN-level, tính theo báo cáo
*										tổ chức mới nhất (lr) tại etl_date, lặp trên mọi dòng cổ đông của NHN.
*--------------------------------------------------------------------*
* [LƯU Ý] BA dòng 72 mô tả 'Mã CTCK' là CTCK mà NHN mở tài khoản, nhưng SQL BA lấy SC_FIRM_INFO.CODE qua
* cổ đông -> theo SQL BA (O_NHNCK_43). INNER JOIN các bước nối NHN/DN theo SQL BA: cổ đông không nối được
* NHN hoặc DN không niêm yết bị loại.
*--------------------------------------------------------------------*
*/

WITH sc_shareholder AS (
    SELECT
        sc_shareholder_id,
        sc_shareholder_code,
        sc_id,
        representative_position,
        shares_held,
        src_stm_code
    FROM {{ ref('atm_sc_shareholder') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
        AND individual_ind = 1
        AND shares_held IS NOT NULL
),

securities_company AS (
    SELECT
        sc_id,
        sc_code,
        sc_short_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND listed_ind = 1
        AND sc_short_nm IS NOT NULL
),

scms_shareholder_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

nhnck_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

sp AS (
    SELECT
        securities_practitioner_dim_id,
        practitioner_code,
        practice_status_code
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

-- Báo cáo tổ chức mới nhất / NHN (dùng dẫn xuất trạng thái hành nghề NHN-level)
lr AS (
    SELECT
        sp_id,
        hire_dt,
        termination_dt
    FROM (
        SELECT
            sp_id,
            hire_dt,
            termination_dt,
            ROW_NUMBER() OVER (
                PARTITION BY sp_id
                ORDER BY data_dt DESC NULLS LAST, termination_dt DESC NULLS FIRST, hire_dt DESC NULLS LAST
            ) AS rn
        FROM {{ ref('atm_sp_organization_employment_report') }}
        WHERE src_stm_code = 'NHNCK_ORGANIZATION_REPORTS'
    ) x
    WHERE rn = 1
)

SELECT
    CAST(sp.practitioner_code AS string)                                        AS practitioner_code,
    CAST(sc_shareholder.sc_shareholder_code AS string)                          AS sc_shareholder_code,
    CAST(securities_company.sc_code AS string)                                  AS securities_company_code,
    CAST(securities_company.sc_short_nm AS string)                              AS securities_company_short_nm,
    CAST(sc_shareholder.representative_position AS string)                      AS representative_position,
    CAST(CASE
            WHEN sp.practice_status_code = '2' THEN '2'
            WHEN sp.practice_status_code = '3' THEN '3'
            WHEN sp.practice_status_code = '0'
                 OR (lr.hire_dt IS NULL AND lr.termination_dt IS NULL) THEN '0'
            WHEN sp.practice_status_code = '1'
                 OR (lr.hire_dt < to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                     AND (lr.termination_dt IS NULL
                          OR lr.termination_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))) THEN '1'
            WHEN sp.practice_status_code = '4'
                 OR (sp.practice_status_code IS NULL
                     AND (lr.hire_dt >= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                          OR lr.termination_dt IS NOT NULL)) THEN '4'
            ELSE '9'
         END AS string)                                                         AS practice_status_code,
    CAST(CASE
            WHEN sp.practice_status_code = '2' THEN 'Thu hồi có cấp lại'
            WHEN sp.practice_status_code = '3' THEN 'Thu hồi không cấp lại'
            WHEN sp.practice_status_code = '0'
                 OR (lr.hire_dt IS NULL AND lr.termination_dt IS NULL) THEN 'Chưa hành nghề'
            WHEN sp.practice_status_code = '1'
                 OR (lr.hire_dt < to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                     AND (lr.termination_dt IS NULL
                          OR lr.termination_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))) THEN 'Đang hoạt động'
            WHEN sp.practice_status_code = '4'
                 OR (sp.practice_status_code IS NULL
                     AND (lr.hire_dt >= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                          OR lr.termination_dt IS NOT NULL)) THEN 'Đã nghỉ'
            ELSE 'Trạng thái hành nghề khác'
         END AS string)                                                         AS practice_status_nm,
    CAST(sc_shareholder.shares_held AS bigint)                                  AS shares_held,
    CAST(sc_shareholder.src_stm_code AS string)                                 AS src_stm_code
FROM sc_shareholder
INNER JOIN scms_shareholder_id
    ON  scms_shareholder_id.ip_id = sc_shareholder.sc_shareholder_id
INNER JOIN nhnck_id
    ON  nhnck_id.identification_nbr = scms_shareholder_id.identification_nbr
INNER JOIN sp
    ON  sp.securities_practitioner_dim_id = nhnck_id.ip_id
INNER JOIN securities_company
    ON  securities_company.sc_id = sc_shareholder.sc_id
LEFT JOIN lr
    ON  lr.sp_id = nhnck_id.ip_id

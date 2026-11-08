/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_employee_investor_account_list
* Program name: Dtm Opr Fund Management Company Employee Investor Account List
* Created by:
* Created date: 2026-10-29
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-29		claude (sync)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_management_company_employee_investor_account_list_FMS_TL_PROFILES.csv
*                                       (commit cac5e35e, Nhóm 28, O_QLQ_55). Grain: 1 nhân viên CTQLQ × 1 tài khoản GDCK VSDC, current-state,
*                                       dựng lại TOÀN BỘ mỗi lần chạy (scd4a, unique_key fmc_employee_code + investor_account_nbr).
*                                       Cầu nối CCCD: fmc_employee -> ip_alternative_identification (FMS_TL_PROFILES, IDENTIFICATION)
*                                       -> atm_open_investor_account ∪ atm_updated_investor_account theo identification_nbr.
*                                       Cận trên :etl_date theo open_dt/update_dt (bản ghi không có ngày vẫn nạp), không lọc = etl_date.
*                                       atm_open/updated_investor_account là incremental append (không có _hstr) -> đọc mọi partition.
*                                       Khử trùng theo PK bằng GROUP BY (LLD ghi UNION toàn cột): nếu 1 cặp nhân viên × tài khoản khớp qua
*                                       2 số giấy tờ khác nhau thì identification_nbr lấy MAX để không nhân đôi PK khi MERGE scd4a
*                                       Audit ds_rcrd_* / ds_etl_pcs_tms của LLD do macro scd4a tự thêm, không SELECT
*--------------------------------------------------------------------*
*/

WITH fmc_employee AS (
    SELECT
        fmc_employee_code,
        fmc_code,
        fmc_employee_full_nm,
        src_stm_code
    FROM {{ ref('atm_fmc_employee') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
),

ip_alternative_identification AS (
    SELECT
        ip_code,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
        AND identification_tp_code = 'IDENTIFICATION'
        AND identification_nbr IS NOT NULL
),

open_investor_account AS (
    SELECT
        investor_account_nbr,
        identification_nbr,
        open_dt
    FROM {{ ref('atm_open_investor_account') }}
    WHERE investor_account_nbr IS NOT NULL
        AND (open_dt IS NULL OR open_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

updated_investor_account AS (
    SELECT
        investor_account_nbr,
        identification_nbr,
        update_dt
    FROM {{ ref('atm_updated_investor_account') }}
    WHERE investor_account_nbr IS NOT NULL
        AND (update_dt IS NULL OR update_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

employee_identification AS (
    SELECT
        fmc_employee.fmc_employee_code,
        fmc_employee.fmc_code,
        fmc_employee.fmc_employee_full_nm,
        fmc_employee.src_stm_code,
        ip_alternative_identification.identification_nbr
    FROM fmc_employee
    INNER JOIN ip_alternative_identification
        ON ip_alternative_identification.ip_code = fmc_employee.fmc_employee_code
),

-- OPEN ∪ UPDATED theo LLD
employee_account AS (
    SELECT
        employee_identification.fmc_employee_code,
        open_investor_account.investor_account_nbr,
        employee_identification.identification_nbr,
        employee_identification.fmc_code,
        employee_identification.fmc_employee_full_nm,
        employee_identification.src_stm_code
    FROM employee_identification
    INNER JOIN open_investor_account
        ON open_investor_account.identification_nbr = employee_identification.identification_nbr
    UNION
    SELECT
        employee_identification.fmc_employee_code,
        updated_investor_account.investor_account_nbr,
        employee_identification.identification_nbr,
        employee_identification.fmc_code,
        employee_identification.fmc_employee_full_nm,
        employee_identification.src_stm_code
    FROM employee_identification
    INNER JOIN updated_investor_account
        ON updated_investor_account.identification_nbr = employee_identification.identification_nbr
),

employee_account_pk AS (
    SELECT
        fmc_employee_code,
        investor_account_nbr,
        MAX(identification_nbr)                                                                 AS identification_nbr,
        MAX(fmc_code)                                                                           AS fmc_code,
        MAX(fmc_employee_full_nm)                                                               AS fmc_employee_full_nm,
        MAX(src_stm_code)                                                                       AS src_stm_code
    FROM employee_account
    GROUP BY fmc_employee_code, investor_account_nbr
),

account_open AS (
    SELECT
        investor_account_nbr,
        MIN(open_dt)                                                                            AS account_open_dt
    FROM open_investor_account
    GROUP BY investor_account_nbr
),

account_update AS (
    SELECT
        investor_account_nbr,
        MAX(update_dt)                                                                          AS account_update_dt
    FROM updated_investor_account
    GROUP BY investor_account_nbr
)

SELECT
    CAST(employee_account_pk.fmc_employee_code AS string)                                     AS fmc_employee_code,
    CAST(employee_account_pk.investor_account_nbr AS string)                                  AS investor_account_nbr,
    CAST(employee_account_pk.identification_nbr AS string)                                    AS identification_nbr,
    CAST(employee_account_pk.fmc_code AS string)                                              AS fmc_code,
    CAST(employee_account_pk.fmc_employee_full_nm AS string)                                  AS fmc_employee_full_nm,
    CAST(account_open.account_open_dt AS date)                                                AS account_open_dt,
    CAST(account_update.account_update_dt AS date)                                            AS account_update_dt,
    CAST(employee_account_pk.src_stm_code AS string)                                          AS src_stm_code
FROM employee_account_pk
LEFT JOIN account_open
    ON account_open.investor_account_nbr = employee_account_pk.investor_account_nbr
LEFT JOIN account_update
    ON account_update.investor_account_nbr = employee_account_pk.investor_account_nbr

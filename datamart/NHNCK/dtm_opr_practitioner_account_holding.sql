/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_account_holding
* Program name: Dtm Opr Practitioner Account Holding
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-05		claude				Tạo mới theo LLD 2026-11-03 (O_NHNCK_43..46): tách phần tài khoản/cổ phiếu VSDC
*										(panel TÀI KHOẢN Nhóm 7, K_NHNCK_87/88/89/103) khỏi opr_practitioner_list_company_role.
*										Driving = atm_open_investor_account (VSDC.OPEN_INVESTORS), tài khoản cá nhân
*										investor_tp_code IN (3, 4). Grain: 1 NHN x 1 tài khoản VSDC x (0..n mã CK cổ đông lớn
*										cùng identification_nbr); không có mã CK -> 1 dòng, mã CK NULL (LEFT JOIN).
*										NHN nối tài khoản qua số giấy tờ định danh (ip_alternative_identification NHNCK).
*										ETL nạp MỌI mã CK, 'tối đa 2 mã CK lớn nhất' xử lý ở Detail Mapping (A31).
*										PK = hash(practitioner_code, open_investor_account_id, COALESCE(major_shareholder_ownership_id,''),
*										src_stm_code).
* 2026-11-06		tuan.nguyenvanb	Bo DISTINCT o CTE open_account, dung ROW_NUMBER PARTITION BY open_investor_account_id
*										ORDER BY open_dt DESC (1 TK = 1 ban ghi): co TK trung cac cot khac nhung khac investor_nm gay dup key.
*--------------------------------------------------------------------*
* [LƯU Ý] major_shareholder_ownership là Fact Snapshot -> lấy snapshot mới nhất <= etl_date.
* open_investor_account là Atomic append theo ngày mở TK -> tích lũy open_dt <= etl_date.
*--------------------------------------------------------------------*
*/

WITH open_account AS (
    SELECT
        open_investor_account_id,
        investor_account_nbr,
        investor_nm,
        identification_nbr,
        src_stm_code
    FROM (
        SELECT
            open_investor_account_id,
            investor_account_nbr,
            investor_nm,
            identification_nbr,
            src_stm_code,
            ROW_NUMBER() OVER (
                PARTITION BY open_investor_account_id, identification_nbr
                ORDER BY open_dt DESC
            ) AS rn
        FROM {{ ref('atm_open_investor_account') }}
        WHERE src_stm_code = 'VSDC_OPEN_INVESTORS'
            AND investor_tp_code IN (3, 4)
            AND open_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND identification_nbr IS NOT NULL
    ) t
    WHERE rn = 1
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
        practitioner_code
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

major_shareholder AS (
    SELECT
        major_shareholder_ownership_id,
        identification_nbr,
        ticker_symbol,
        closing_share_quantity
    FROM (
        SELECT
            major_shareholder_ownership_id,
            identification_nbr,
            ticker_symbol,
            closing_share_quantity,
            ROW_NUMBER() OVER (
                PARTITION BY identification_nbr, ticker_symbol
                ORDER BY opening_balance_dt DESC
            ) AS rn
        FROM {{ ref('atm_major_shareholder_ownership') }}
        WHERE src_stm_code = 'VSDC_MAJOR_SHAREHOLDER'
            AND ds_snpst_dt = (
                SELECT MAX(ds_snpst_dt)
                FROM {{ ref('atm_major_shareholder_ownership') }}
                WHERE src_stm_code = 'VSDC_MAJOR_SHAREHOLDER'
                    AND ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            )
            AND identification_nbr IS NOT NULL
    ) t
    WHERE rn = 1
)

SELECT
    CAST({{ generate_surrogate_key_bigint('VSDC_OPEN_INVESTORS', "concat_ws('-', sp.practitioner_code, open_account.open_investor_account_id, COALESCE(major_shareholder.major_shareholder_ownership_id, ''), open_account.src_stm_code)") }} AS string) AS practitioner_account_holding_id,
    CAST(sp.practitioner_code AS string)                                        AS practitioner_code,
    CAST(open_account.investor_account_nbr AS string)                           AS account_nbr,
    CAST(open_account.investor_nm AS string)                                    AS account_holder_nm,
    CAST(major_shareholder.ticker_symbol AS string)                             AS main_held_securities_code,
    CAST(major_shareholder.closing_share_quantity AS bigint)                    AS vsdc_held_securities_vol,
    CAST(open_account.src_stm_code AS string)                                   AS src_stm_code
FROM open_account
INNER JOIN nhnck_id
    ON  nhnck_id.identification_nbr = open_account.identification_nbr
INNER JOIN sp
    ON  sp.securities_practitioner_dim_id = nhnck_id.ip_id
LEFT JOIN major_shareholder
    ON  major_shareholder.identification_nbr = open_account.identification_nbr

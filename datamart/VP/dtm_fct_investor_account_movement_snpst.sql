/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investor_account_movement_snpst
* Program name: Dtm Fct Investor Account Movement Snapshot
* Created by: huy.pham
* Created date: 2026-11-02
*--------------------------------------------------------------------*
* Modified management
* Date            User            Description
* 2026-11-02      huy.pham        [MOI, theo LLD DTM_VP_fct_investor_account_movement_snpst]
*                                 Fact phát sinh mở/đóng tài khoản NĐT theo ngày × loại NĐT.
*                                 Grain = 1 ngày phát sinh × 1 investor_tp_code VSDC.
*                                 FULL OUTER JOIN open_agg và close_agg theo (event_dt, tp_code).
*                                 investor_tp_code IN ('3','4','5','6','7') else 'NA'.
*                                 ETL dựng lại TOÀN BỘ mỗi lần vì sự kiện có thể khai báo
*                                 lùi ngày (O_VP_46) — MERGE theo PK.
*                                 Open source: atm_investment_account (VSDC_OPEN_INVESTORS,
*                                 event_dt = open_date).
*                                 Close source: atm_closed_investment_account (PENDING — chưa
*                                 có atomic, cần tạo từ VSDC_CLOSED_INVESTORS).
*--------------------------------------------------------------------*
*/

WITH open_agg AS (
    SELECT
        open_dt                                                                     AS event_dt,
        IF(CAST(investor_tp_code AS string) IN ('3','4','5','6','7'),
           CAST(investor_tp_code AS string), 'NA')                                  AS investor_tp_code,
        COUNT(investor_account_nbr)                                                 AS open_account_count
    FROM {{ ref('atm_open_investor_account') }}
    WHERE open_dt IS NOT NULL
        --AND open_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
    GROUP BY
        open_dt,
        IF(CAST(investor_tp_code AS string) IN ('3','4','5','6','7'),
           CAST(investor_tp_code AS string), 'NA')
),

close_agg AS (
    SELECT
        close_dt                                                                    AS event_dt,
        IF(CAST(investor_tp_code AS string) IN ('3','4','5','6','7'),
           CAST(investor_tp_code AS string), 'NA')                                  AS investor_tp_code,
        COUNT(investor_account_nbr)                                                 AS close_account_count
    FROM {{ ref('atm_closed_investor_account') }}
    WHERE close_dt IS NOT NULL
        --AND close_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') (chay daily)
    GROUP BY
        close_dt,
        IF(CAST(investor_tp_code AS string) IN ('3','4','5','6','7'),
           CAST(investor_tp_code AS string), 'NA')
),

combined AS (
    SELECT
        COALESCE(o.event_dt,         c.event_dt)                                    AS event_dt,
        COALESCE(o.investor_tp_code, c.investor_tp_code)                            AS investor_tp_code,
        COALESCE(o.open_account_count,  0)                                          AS open_account_count,
        COALESCE(c.close_account_count, 0)                                          AS close_account_count
    FROM open_agg  o
    FULL OUTER JOIN close_agg c
        ON  c.event_dt         = o.event_dt
        AND c.investor_tp_code = o.investor_tp_code
)

SELECT
    CAST({{ generate_surrogate_key_bigint('VSDC_INVESTOR_ACCOUNT_MOVEMENT', "CONCAT(date_format(event_dt, 'yyyyMMdd'), '|', investor_tp_code)") }} AS string) AS investor_account_movement_snpst_id,
    CAST(cdr.cdr_dt_dim_id  AS string)                                              AS snpst_dt_dim_id,
    CAST(investor_tp_code   AS string)                                              AS investor_tp_code,
    CAST(open_account_count AS int)                                                 AS open_account_count,
    CAST(close_account_count AS int)                                                AS close_account_count

FROM combined
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cdr
    ON  cdr.cdr_dt = combined.event_dt

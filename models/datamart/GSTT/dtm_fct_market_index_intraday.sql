/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_index_intraday
* Program name: Dtm Fct Market Index Intraday
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-13		tuan.nguyenvanb		Doi ten cot cdr_dt_dim_id -> trade_dt_dim_id (LLD). Can RENAME COLUMN o bang Iceberg + ClickHouse flat.
*                                       [DEV CHOT PHUONG AN B] GIU gom theo phut (LLD v4.47 ghi nguyen mili giay nhung HLD ghi 'theo phut' - cho designer chot).
* 2026-10-12		tuan.nguyenvanb		Chi lay 1 ban ghi / chi so / PHUT (ban tin cuoi cung trong phut theo index_time desc,
*                                       sequence desc) - bieu do chi can diem theo phut, nguon MDDS gui theo mili giay.
*                                       total_val_at_time tinh LAG tren cac diem da gom theo phut. Khong doi cot.
*                                       index_time ghi ra dang HH:mm (cat SUBSTR 1..5), khong con giay/mili giay.
* 2026-10-20		tuan.nguyenvanb		[SUA theo BA] total_val_at_time = total_val cua ban tin cuoi phut (rn_minute = 1), lay 1-1, KHONG tru LAG
*                                       (truoc day = total_val - LAG(total_val)). Khong doi ten/kieu/vi tri cot, khong can ALTER. Can cap nhat LLD.
*--------------------------------------------------------------------*
*/

WITH ma_in_sn_raw AS (
    SELECT
        index_time,
        market_index_val,
        total_val,
        market_code,
        market_id,
        trading_dt,
        sequence
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

-- 1 ban ghi / chi so / phut: ban tin cuoi cung trong phut (giong BA: index_time desc, sequence desc)
ma_in_sn AS (
    SELECT
        index_time,
        market_index_val,
        total_val,
        market_code,
        market_id,
        trading_dt
    FROM (
        SELECT
            ma_in_sn_raw.*,
            ROW_NUMBER() OVER (
                PARTITION BY market_id, market_code, trading_dt, SUBSTR(index_time, 1, 5)
                ORDER BY index_time DESC, sequence DESC
            ) AS rn_minute
        FROM ma_in_sn_raw
    ) x
    WHERE rn_minute = 1
),

ma_in_di AS (
    SELECT
        market_index_dim_id,
        market_id,
        market_code
    FROM {{ ref('dtm_market_index_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    CAST(ma_in_di.market_index_dim_id AS string)                             AS market_index_dim_id,
    CAST(date_format(ma_in_sn.trading_dt, 'yyyyMMdd') AS string)                                   AS trade_dt_dim_id,
    CAST(SUBSTR(ma_in_sn.index_time, 1, 5) AS string)                        AS index_time,   -- [2026-10-12] chi lay den PHUT (HH:mm)
    CAST(ma_in_sn.market_index_val AS decimal(23,2))                         AS market_index_val_at_time,
    ma_in_sn.total_val AS total_val_at_time   -- [2026-10-20 BA] lay 1-1 total_val cua ban tin cuoi phut, khong tru LAG
FROM ma_in_sn
LEFT JOIN ma_in_di
    ON  ma_in_di.market_id = ma_in_sn.market_id
    AND ma_in_di.market_code = ma_in_sn.market_code
WHERE ma_in_sn.trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')

-- [FIRST-TIME] ft_atm_index_constituent_snapshot: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_index_constituent_snapshot (config ft_target='index_constituent_snapshot', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_index_constituent_snapshot
* Program name: Atomic Index Constituent Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-22		tuan.nguyenvanb		[DONG BO DESIGN 2026-10-21] symbol->ticker_symbol; total_match_vol int->bigint; them stock_nbr (STOCKNO, string) va
*									constituent_weight_percentage (WEIGHTED, decimal(5,2)) o CUOI SELECT (truoc ds_snpst_dt). Bang vat ly: RENAME/ALTER TYPE +
*									ADD COLUMN ... AFTER total_match_vol (xem scratch/alter_atomic_rename_20261022.sql) TRUOC khi chay.
*--------------------------------------------------------------------*
*/

{{ config(incremental_strategy='append') }}   -- [FIRST-TIME 2026-10-09] append + ds_snpst_dt = ngay giao dich tung dong (giu nguyen tac 1 partition = 1 ngay nhu daily; snapshot se gan ds_snpst_dt = etl_date cho ca nam)
WITH ja_cs AS (
    SELECT
        id
        , indexcode
        , indexid
        , symbol
        , tradingdate
        , adddate
        , floorcode
        , totalqtty
        , stockno
        , weighted
    FROM {{ ft_ref('ft_ods_mdds_jad_csidxinfor') }}
    -- [BACKFILL-UAT-ORIG] WHERE TRADINGDATE BETWEEN to_date('{{ var("backfill_from", var("etl_date")) }}', 'yyyy-MM-dd') AND to_date('{{ var("backfill_to", var("etl_date")) }}', 'yyyy-MM-dd')
    -- 2026-10-08 tuan.nguyenvanb: [BACKFILL-UAT-NEW] TAM THOI bo WHERE theo ngay (nguon MDDS da dump du) de nap 1 nam trong 1 lan chay.   -- [BACKFILL-UAT-NEW]
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_CSIDXINFOR', "ja_cs.id") }} AS index_constituent_snpst_id
    , CAST(ja_cs.id AS string)                                             AS index_constituent_snpst_code
    , CAST('MDDS_JAD_CSIDXINFOR' AS string)                                AS src_stm_code
    , CAST(ja_cs.indexcode AS string)                                      AS index_code
    , CAST(ja_cs.indexid AS string)                                        AS index_id
    , CAST(ja_cs.symbol AS string)                                         AS ticker_symbol
    , CAST(ja_cs.tradingdate AS date)                                      AS trading_dt
    , CAST(ja_cs.adddate AS date)                                          AS add_dt
    , CAST(ja_cs.floorcode AS string)                                      AS floor_code
    , CAST(ja_cs.totalqtty AS bigint)                                         AS total_match_vol
    , CAST(ja_cs.stockno AS string)                                        AS stock_nbr
    , CAST(ja_cs.weighted AS decimal(5,2))                                 AS constituent_weight_percentage
    , CAST(ja_cs.tradingdate AS date)                             AS ds_snpst_dt   -- [FIRST-TIME 2026-10-09] = ngay giao dich (daily: = etl_date = trading_dt)
FROM ja_cs
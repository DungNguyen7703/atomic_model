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
    FROM {{ ref('ods_mdds_jad_csidxinfor') }}
    WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_CSIDXINFOR', "id") }} AS index_constituent_snpst_id
    , CAST(id AS string)                                             AS index_constituent_snpst_code
    , CAST('MDDS_JAD_CSIDXINFOR' AS string)                          AS src_stm_code
    , CAST(indexcode AS string)                                      AS index_code
    , CAST(indexid AS string)                                        AS index_id
    , CAST(symbol AS string)                                         AS ticker_symbol
    , CAST(tradingdate AS date)                                      AS trading_dt
    , CAST(adddate AS date)                                          AS add_dt
    , CAST(floorcode AS string)                                      AS floor_code
    , CAST(totalqtty AS bigint)                                      AS total_match_vol
    , CAST(stockno AS string)                                        AS stock_nbr
    , CAST(weighted AS decimal(5,2))                                 AS constituent_weight_percentage
FROM ja_cs
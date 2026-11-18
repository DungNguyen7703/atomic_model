/*
*--------------------------------------------------------------------*
* Program code: dtm_market_index_dim
* Program name: Dtm Market Index Dim
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-08		tuan.nguyenvanb		[FIX] Thieu filter ds_snpst_dt/trading_dt = etl_date -
*                                       CTE doc toan bo lich su atm_market_index_snapshot
*                                       (khong chi ngay dang chay), dedupe row_number() chi
*                                       trong tung trading_dt (khong dedupe giua cac ngay) ->
*                                       khi backfill nhieu ngay lien tiep, source co >1
*                                       trading_dt cho cung market_id/market_code -> sinh
*                                       >1 dong cung market_index_dim_id (surrogate key chi
*                                       tinh tu market_id|market_code, khong co ngay) ->
*                                       MERGE_CARDINALITY_VIOLATION. Them filter theo etl_date.
* 2026-09-15		tuan.nguyenvanb		[LLD] Bo sung Index Name - da co san tren LLD/Master
*                                       Registry tu truoc (dung cho GSTT) nhung chua lan toa
*                                       vao model nay - nay dong bo, lay truc tiep tu
*                                       atm_market_index_snapshot.index_nm (khong can join
*                                       them, cung nguon).
* 2026-10-17		tuan.nguyenvanb		[FIX] Loai dong rac market_id/market_code NULL (atomic market_index_snapshot co 1 dong/ngay khong co ma) -> truoc day sinh dong ACTIVE voi market_index_dim_id NULL moi ngay.
*--------------------------------------------------------------------*
*/

WITH ma_in_sn_all AS (
    SELECT
        market_id,
        market_code,
        index_nm,
        index_tp_code,
        tsc_product_group_id,
        market_status_code,
        src_stm_code,
        trading_dt,
        row_number() over (partition by market_id, market_code order by index_time desc) as rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND market_id IS NOT NULL
        AND market_code IS NOT NULL
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),
ma_in_sn AS (
    SELECT
        market_id,
        market_code,
        index_nm,
        index_tp_code,
        tsc_product_group_id,
        market_status_code,
        src_stm_code
    FROM ma_in_sn_all
    WHERE rn = 1
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_MARKETINFOR', "CONCAT(market_id, '|', market_code)") }} AS string)    AS market_index_dim_id,
    CAST(market_id AS string)                                            AS market_id,
    CAST(market_code AS string)                                          AS market_code,
    CAST(index_nm AS string)                                             AS index_nm,
    CAST(index_tp_code AS string)                                        AS index_tp_code,
    CAST(tsc_product_group_id AS string)                                 AS tsc_product_group_id,
    CAST(market_status_code AS string)                                   AS market_status_code,
    CAST(src_stm_code AS string)                                         AS src_stm_code
FROM ma_in_sn

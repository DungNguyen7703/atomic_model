-- [FIRST-TIME] ft_dtm_market_index_dim: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_market_index_dim (config ft_target='market_index_dim', macro macros/first_time).
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
* 2026-10-09		tuan.nguyenvanb		[BACKFILL-UAT-NEW] BAN FIRST-TIME (nap 1 nam trong 1 lan chay, etl_date co dinh): bo loc
*                                       trading_dt = etl_date (dim chi giu chi so co dong dung ngay etl_date -> flat QLKD ra
*                                       market_code NULL o cac chi so khong co dong ngay do). Doc toan bo lich su, lay dong MOI NHAT
*                                       moi (market_id, market_code) theo trading_dt DESC, index_time DESC. Dong goc giu comment
*                                       BACKFILL-UAT-ORIG. [BACKFILL-UAT-NEW]
* 2026-10-17		tuan.nguyenvanb		[FIRST-TIME] ft_hstr_by_day: snapshot TUNG NGAY (1 ban ghi/chi so/ngay theo trading_dt), them cot ds_snpst_dt cuoi.
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
        row_number() over (partition by market_id, market_code, trading_dt order by index_time desc, sequence desc) as rn   -- [FIRST-TIME 2026-10-17] 1 ban ghi / chi so / NGAY (ft_hstr_by_day)
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND market_id IS NOT NULL
        AND market_code IS NOT NULL
        -- [BACKFILL-UAT-ORIG] AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),
ma_in_sn AS (
    SELECT
        market_id,
        market_code,
        index_nm,
        index_tp_code,
        tsc_product_group_id,
        market_status_code,
        src_stm_code,
        trading_dt
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
    CAST(src_stm_code AS string)                                         AS src_stm_code,
    CAST(trading_dt AS date)                                             AS ds_snpst_dt   -- [FIRST-TIME 2026-10-17] ngay snapshot (ft_hstr_by_day)
FROM ma_in_sn

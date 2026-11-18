-- [FIRST-TIME] ft_dtm_index_constituent_dim: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_index_constituent_dim (config ft_target='index_constituent_dim', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_index_constituent_dim
* Program name: Dtm Index Constituent Dim
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-14		tuan.nguyenvanb		[SUA THEO HLD v4.13 + LLD cap nhat] Doi grain tu
*                                       1 dong/(index_code, symbol) sang 1 dong/index_code -
*                                       bo cot symbol/floor_code/add_dt (chuyen sang Fact
*                                       Index Constituent Snapshot moi, dtm_fct_index_
*                                       constituent_snpst). PK doi tu hash(index_code|symbol)
*                                       sang hash(index_code) - dedupe qua ROW_NUMBER vi
*                                       atm_index_constituent_snapshot van co the co nhieu
*                                       dong/index_code (nhieu symbol thanh vien).
* 2026-09-15		tuan.nguyenvanb		[LLD v4.20] Bo sung Index Name - Index Constituent
*                                       Snapshot khong co attribute ten chi so, LEFT JOIN
*                                       sang atm_market_index_snapshot theo Market Code =
*                                       Index Code (quyet dinh Data Modeler, khong CASE WHEN).
* 2026-10-17		tuan.nguyenvanb		[FIRST-TIME] ft_hstr_by_day: snapshot TUNG NGAY (1 dong/chi so/ngay, bo loc etl_date), them cot ds_snpst_dt cuoi.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu atomic: index_constituent_snapshot.symbol->ticker_symbol. Khong doi cot/kieu.
*--------------------------------------------------------------------*
*/

WITH in_co_sn_all AS (
    SELECT
        index_code,
        index_id,
        src_stm_code,
        ds_snpst_dt,
        row_number() over (partition by index_code, ds_snpst_dt order by ticker_symbol) as rn   -- [FIRST-TIME 2026-10-17] 1 dong / chi so / NGAY
    FROM {{ ft_ref('ft_atm_index_constituent_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_CSIDXINFOR'   -- [FIRST-TIME 2026-10-17] ft_hstr_by_day: TOAN BO lich su, khong loc etl_date
),

in_co_sn AS (
    SELECT index_code, index_id, src_stm_code, ds_snpst_dt
    FROM in_co_sn_all
    WHERE rn = 1
),

ma_in_sn_all AS (
    SELECT
        market_code,
        index_nm,
        ds_snpst_dt,
        row_number() over (partition by market_code, ds_snpst_dt order by index_time desc, sequence desc) as rn   -- [FIRST-TIME 2026-10-17] 1 dong / market_code / NGAY
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    WHERE src_stm_code = 'MDDS_JAD_MARKETINFOR'   -- [FIRST-TIME 2026-10-17] ft_hstr_by_day: TOAN BO lich su, khong loc etl_date
),

ma_in_sn AS (
    SELECT market_code, index_nm, ds_snpst_dt
    FROM ma_in_sn_all
    WHERE rn = 1
)

SELECT
    CAST({{ generate_surrogate_key_bigint('MDDS_JAD_CSIDXINFOR', 'index_code') }} AS string) AS index_constituent_dim_id,
    CAST(in_co_sn.index_code AS string)                             AS index_code,
    CAST(in_co_sn.index_id AS string)                               AS index_id,
    CAST(ma_in_sn.index_nm AS string)                               AS index_nm,
    CAST(in_co_sn.src_stm_code AS string)                           AS src_stm_code,
    CAST(in_co_sn.ds_snpst_dt AS date)                              AS ds_snpst_dt   -- [FIRST-TIME 2026-10-17] ngay snapshot (ft_hstr_by_day)
FROM in_co_sn
LEFT JOIN ma_in_sn
    ON ma_in_sn.market_code = in_co_sn.index_code
    AND ma_in_sn.ds_snpst_dt = in_co_sn.ds_snpst_dt

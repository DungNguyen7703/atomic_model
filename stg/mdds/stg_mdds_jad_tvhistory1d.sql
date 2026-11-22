/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tvhistory1d
* Program name: Staging MDDS.JAD_TVHISTORY1D
* Created by: tuan.nguyenvanb
* Created date: 2026-09-30
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-30		tuan.nguyenvanb		Tao moi - phuc vu atm_market_price_snapshot (nhanh
*                                       nen ngay), theo BRD brd_MDDS_JAD_TRADINGVIEWHISTORY1DAY
*                                       (TRADINGDATE dinh dang dd/MM/yyyy).
* 2026-11-10		tuan.nguyenvanb		Dong bo theo DDL prod (drive-download ddl): yml append/tradingdate -> append/none; kieu du lieu 2 cot; them cot data_dt; sap xep lai thu tu cot theo DDL.
* 2026-11-10		tuan.nguyenvanb		Bang append: chuan hoa dieu kien WHERE theo etl_date (TIMESTAMP/INTERVAL 1 DAY).
* 2026-11-10		tuan.nguyenvanb		Dong bo theo DDL final (drive-download 2026-11-10): partition_by None -> data_dt.
* 2026-11-12		tuan.nguyenvanb		Doi ten model stg_mdds_jad_tradingviewhistory1day -> stg_mdds_jad_tvhistory1d theo BRD/DDL (alias jad_tvhistory1d giu nguyen).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                                AS id
    , CAST(close AS double)                           AS close
    , CAST(high AS double)                            AS high
    , CAST(low AS double)                             AS low
    , CAST(open AS double)                            AS open
    , CAST(symbol AS string)                          AS symbol
    , CAST(tradingdate AS string)                     AS tradingdate
    , CAST(volume AS decimal(19,0))                   AS volume
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')  AS data_dt
FROM {{ source('source_mdds', 'raw_jad_tradingviewhistory1day') }}
WHERE tradingdate = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'dd/MM/yyyy')
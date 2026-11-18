{{
    config(
        materialized = 'view',
        schema = var('stg_mdds_schema'),
        alias = 'jad_tradingviewhistory1day_to_oracle_v',
        post_hook = [
            "INSERT INTO {{ var('src_mdds_schema') }}.JAD_TVHISTORY1D_UAT (id, symbol, tradingdate, open, high, low, close, volume) SELECT /*+ REPARTITION(256) */ * FROM {{ this }}"
        ],
        tags = ['layer_staging', 'domain_mdds', 'push_to_oracle']
    )
}}

/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_tradingviewhistory1day_to_oracle
* Program name: Day MDDS.JAD_TRADINGVIEWHISTORY1DAY tu staging UAT (Iceberg) vao Oracle oracle_viettel_2.UBCK_PROD.JAD_TVHISTORY1D_UAT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Chieu nguoc voi stg_mdds_jad_tradingviewhistory1day: doc FULL staging.uat_MDDS_stg.jad_tradingviewhistory1day (khong loc etl_date) -> INSERT vao Oracle UBCK_PROD.. tradingdate doi lai dd/MM/yyyy (varchar2). Hint REPARTITION(8) de ghi JDBC song song 8 ket noi. Khong gom ds_etl_pcs_tms. Bang Oracle UBCK_PROD phai TRUNCATE truoc khi chay lai (hook chi INSERT).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , symbol
    , date_format(tradingdate, 'dd/MM/yyyy') AS tradingdate
    , open
    , high
    , low
    , close
    , volume
FROM {{ source('source_mdds_uat_stg', 'raw_jad_tradingviewhistory1day') }}

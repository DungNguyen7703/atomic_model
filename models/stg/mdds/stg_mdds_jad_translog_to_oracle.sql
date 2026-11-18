{{
    config(
        materialized = 'view',
        schema = var('stg_mdds_schema'),
        alias = 'jad_translog_to_oracle_v',
        post_hook = [
            "INSERT INTO {{ var('src_mdds_schema') }}.JAD_TRANSLOG_UAT (kid, sequencemsg, tradingdate, symbol, formattedtime, lastcolor, formattedmatchprice, changecolor, formattedvol, formattedaccvol, formattedaccval, totalbuyvol, totalsellvol, boardid, formattedchangevalue) SELECT /*+ REPARTITION(256) */ * FROM {{ this }}"
        ],
        tags = ['layer_staging', 'domain_mdds', 'push_to_oracle']
    )
}}

/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_translog_to_oracle
* Program name: Day MDDS.JAD_TRANSLOG tu staging UAT (Iceberg) vao Oracle oracle_viettel_2.UBCK_PROD.JAD_TRANSLOG_UAT
* Created by: tuan.nguyenvanb
* Created date: 2026-11-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-14		tuan.nguyenvanb		[MOI] Chieu nguoc voi stg_mdds_jad_translog: doc FULL staging.uat_MDDS_stg.jad_translog (khong loc etl_date) -> INSERT vao Oracle UBCK_PROD.. tradingdate doi lai dd/MM/yyyy (varchar2). Hint REPARTITION(8) de ghi JDBC song song 8 ket noi. Khong gom ds_etl_pcs_tms. Bang Oracle UBCK_PROD phai TRUNCATE truoc khi chay lai (hook chi INSERT).
*--------------------------------------------------------------------*
*/

SELECT
    kid
    , sequencemsg
    , date_format(tradingdate, 'dd/MM/yyyy') AS tradingdate
    , symbol
    , formattedtime
    , lastcolor
    , formattedmatchprice
    , changecolor
    , formattedvol
    , formattedaccvol
    , formattedaccval
    , totalbuyvol
    , totalsellvol
    , boardid
    , formattedchangevalue
FROM {{ source('source_mdds_uat_stg', 'raw_jad_translog') }}

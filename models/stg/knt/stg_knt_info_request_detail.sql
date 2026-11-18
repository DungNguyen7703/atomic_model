/*
*--------------------------------------------------------------------*
* Program code: stg_knt_info_request_detail
* Program name: Staging KNT.INFO_REQUEST_DETAIL
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
* 2026-11-08		tuan.nguyenvanb		Dong bo theo KNT_ddl_prod.sql, brd_KNT.yaml va khao sat du lieu nguon prod: kieu int sang bigint (2 cot); them cot data_dt; yml snapshot/ds_snpst_dt -> append/data_dt theo BRD.
* 2026-11-08		tuan.nguyenvanb		Theo design: bang Append khong partition (macro INSERT OVERWRITE = truncate insert): yml append, bo partition_by data_dt; giu cot data_dt.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                 AS id
    , CAST(msg_packet_id AS bigint)      AS msg_packet_id
    , CAST(request_name AS string)       AS request_name
    , CAST(status_description AS string) AS status_description
    , CAST(status AS int)                AS status
    , CAST(tax_code AS string)           AS tax_code
    , to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AS data_dt
FROM {{ source('source_knt', 'raw_info_request_detail') }}
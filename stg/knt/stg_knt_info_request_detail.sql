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
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(msg_packet_id AS int)         AS msg_packet_id
    , CAST(request_name AS string)       AS request_name
    , CAST(status_description AS string) AS status_description
    , CAST(status AS int)                AS status
    , CAST(tax_code AS string)           AS tax_code
FROM {{ source('source_knt', 'raw_info_request_detail') }}
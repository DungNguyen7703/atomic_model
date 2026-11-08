/*
*--------------------------------------------------------------------*
* Program code: stg_knt_msg_packet_config
* Program name: Staging KNT.MSG_PACKET_CONFIG
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(function_name AS string)    AS function_name
    , CAST(org_unit_code AS string)    AS org_unit_code
    , CAST(system_code AS string)      AS system_code
    , CAST(data_direction AS int)      AS data_direction
    , CAST(transfer_method AS int)     AS transfer_method
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(last_modified_by AS string) AS last_modified_by
FROM {{ source('source_knt', 'raw_msg_packet_config') }}
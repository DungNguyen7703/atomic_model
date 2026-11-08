/*
*--------------------------------------------------------------------*
* Program code: stg_knt_msg_packet_content
* Program name: Staging KNT.MSG_PACKET_CONTENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo KNT_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(msg_packet_id AS decimal(19,0)) AS msg_packet_id
    , CAST(xml_input AS string)            AS xml_input
    , CAST(xml_out AS string)              AS xml_out
    , CAST(json_out AS string)             AS json_out
    , CAST(response_tct_xml AS string)     AS response_tct_xml
    , CAST(response_mof_xml AS string)     AS response_mof_xml
    , CAST(msg_error AS string)            AS msg_error
FROM {{ source('source_knt', 'raw_msg_packet_content') }}
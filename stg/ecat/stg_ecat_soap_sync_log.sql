/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_soap_sync_log
* Program name: Staging ECAT.SOAP_SYNC_LOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)              AS id
    , CAST(msg_id AS string)        AS msg_id
    , CAST(msg_ref_id AS string)    AS msg_ref_id
    , CAST(tran_code AS string)     AS tran_code
    , CAST(tran_name AS string)     AS tran_name
    , CAST(tran_num AS int)         AS tran_num
    , CAST(status AS string)        AS status
    , CAST(error_number AS string)  AS error_number
    , CAST(error_message AS string) AS error_message
    , CAST(sent_at AS timestamp)    AS sent_at
    , CAST(created_at AS timestamp) AS created_at
    , CAST(header_xml AS string)    AS header_xml
    , CAST(body_xml AS string)      AS body_xml
    , CAST(receiver_code AS string) AS receiver_code
    , CAST(receiver_name AS string) AS receiver_name
    , CAST(original_code AS string) AS original_code
    , CAST(original_name AS string) AS original_name
FROM {{ source('source_ecat', 'raw_soap_sync_log') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
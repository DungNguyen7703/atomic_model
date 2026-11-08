/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_soap_incoming_log
* Program name: Staging ECAT.SOAP_INCOMING_LOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)               AS id
    , CAST(msg_id AS string)         AS msg_id
    , CAST(msg_ref_id AS string)     AS msg_ref_id
    , CAST(sender_code AS string)    AS sender_code
    , CAST(tran_code AS string)      AS tran_code
    , CAST(tran_name AS string)      AS tran_name
    , CAST(tran_num AS int)          AS tran_num
    , CAST(message_type AS string)   AS message_type
    , CAST(header_xml AS string)     AS header_xml
    , CAST(body_xml AS string)       AS body_xml
    , CAST(status AS string)         AS status
    , CAST(error_message AS string)  AS error_message
    , CAST(received_at AS timestamp) AS received_at
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(changed_count AS bigint)  AS changed_count
    , CAST(receiver_code AS string)  AS receiver_code
    , CAST(receiver_name AS string)  AS receiver_name
    , CAST(original_code AS string)  AS original_code
    , CAST(original_name AS string)  AS original_name
FROM {{ source('source_ecat', 'raw_soap_incoming_log') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
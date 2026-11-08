/*
*--------------------------------------------------------------------*
* Program code: stg_ecat_soap_reconcile_data_mapping
* Program name: Staging ECAT.SOAP_RECONCILE_DATA_MAPPING
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                       AS id
    , CAST(reconcile_msg_id AS string)       AS reconcile_msg_id
    , CAST(reconcile_msg_ref_id AS string)   AS reconcile_msg_ref_id
    , CAST(data_change_msg_id AS string)     AS data_change_msg_id
    , CAST(data_change_msg_ref_id AS string) AS data_change_msg_ref_id
    , CAST(tran_num AS int)                  AS tran_num
    , CAST(tran_code AS string)              AS tran_code
    , CAST(tran_name AS string)              AS tran_name
    , CAST(send_date AS timestamp)           AS send_date
    , CAST(created_at AS timestamp)          AS created_at
FROM {{ source('source_ecat', 'raw_soap_reconcile_data_mapping') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
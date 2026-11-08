/*
*--------------------------------------------------------------------*
* Program code: ods_scms_lnk_transaction_office_service
* Program name: ODS SCMS.LNK_TRANSACTION_OFFICE_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , sc_firm_transaction_office_id
    , service_id
    , created_at
    , record_status
FROM {{ ref('stg_scms_lnk_transaction_office_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') 
  AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
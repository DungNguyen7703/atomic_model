/*
*--------------------------------------------------------------------*
* Program code: atm_sc_ou_x_cl_sc_firm_service_relationship
* Program name: Atomic Securities Company Organization Unit X Classification Securities Company Firm Service Relationship
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ln_tr_of_se AS (
    SELECT
        sc_firm_transaction_office_id
        , service_id
        , record_status
    FROM {{ ref('ods_scms_lnk_transaction_office_service') }}
    WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') 
    AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
    and record_status = 1
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_LNK_TRANSACTION_OFFICE_SERVICE', "ln_tr_of_se.sc_firm_transaction_office_id") }} AS sc_ou_id
    , CAST(ln_tr_of_se.sc_firm_transaction_office_id AS string)                                                             AS sc_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_LNK_TRANSACTION_OFFICE_SERVICE', "ln_tr_of_se.service_id") }}                  AS cl_sc_firm_service_id
    , CAST(ln_tr_of_se.service_id AS string)                                                                                AS cl_sc_firm_service_code
    , CAST('SCMS_LNK_TRANSACTION_OFFICE_SERVICE' AS string)                                                                 AS src_stm_code
FROM ln_tr_of_se
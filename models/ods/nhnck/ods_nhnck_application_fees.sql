/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_application_fees
* Program name: ODS NHNCK.APPLICATION_FEES
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
    , application_id
    , professional_id
    , fee_type
    , content
    , note
    , status
    , request_date
    , payment_date
    , expiry_date
    , fee
    , file_path
    , created_by
    , created_at
    , updated_by
    , updated_at
FROM {{ ref('stg_nhnck_application_fees') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
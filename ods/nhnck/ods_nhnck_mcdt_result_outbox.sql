/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_mcdt_result_outbox
* Program name: ODS NHNCK.MCDT_RESULT_OUTBOX
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD NHNCK (STG da co).
*--------------------------------------------------------------------*
*/

SELECT
    id
    , application_id
    , sender_identity
    , status
    , attempts
    , next_retry_at
    , last_error
    , created_at
    , updated_at
FROM {{ ref('stg_nhnck_mcdt_result_outbox') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_updated_investors
* Program name: ODS VSDC.UPDATED_INVESTORS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Lay 1-1 bang VSDC updated_investors tu source_vsdc (cung khung ods_vsdc_open_investors). STG ve ~1 lan/thang,
*                                       moi ds_snpst_dt chua nhieu update_date. Partition ODS = (ds_snpst_dt, update_date); append = INSERT OVERWRITE dong theo
*                                       (ds_snpst_dt, update_date) nen dump khac khong bi ghi de. KHONG loc theo etl_date: nap cac dump STG chua co + dump moi nhat.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(customer_name AS string)          AS customer_name
    , CAST(investor_type AS string)        AS investor_type
    , CAST(trading_account_no AS string)   AS trading_account_no
    , CAST(address AS string)              AS address
    , CAST(id_number AS string)            AS id_number
    , CAST(issue_date AS date)             AS issue_date
    , CAST(issue_place AS string)          AS issue_place
    , CAST(update_date AS date)            AS update_date
    , CAST(nationality AS string)          AS nationality
    , CAST(phone_number AS string)         AS phone_number
    , CAST(email AS string)                AS email
    , CAST(notes AS string)                AS notes
FROM {{ source('source_vsdc', 'raw_updated_investors') }}
WHERE update_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

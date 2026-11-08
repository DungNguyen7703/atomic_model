/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_open_investors
* Program name: ODS VSDC.OPEN_INVESTORS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-15
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		tuan.nguyenvanb		[MOI] Lay 1-1 bang VSDC open_investors (BM 5, thong tin va danh tinh NDT
*                                       mo tai khoan) tu source_vsdc. Phuc vu phan loai ca nhan va to chuc
*                                       trong nuoc cua GSTT (investor_type 3 hoac 5). Bang nguon co the trung
*                                       so tai khoan, ODS giu nguyen khong dedupe.
* 2026-10-16		tuan.nguyenvanb		So nhan du lieu ~1 lan/tuan, KHONG loc theo etl_date: lay cac ds_snpst_dt co o STG ma ODS
*                                       chua co + ghi de lai ngay moi nhat cua STG (idempotent, tranh rong -> macro append
*                                       xoa partition etl_date).
* 2026-10-25		tuan.nguyenvanb		[SUA] STG ve ~1 lan/thang, moi ds_snpst_dt chua nhieu open_date. Doi partition ODS ds_snpst_dt -> (ds_snpst_dt, open_date):
*                                       1 dump (ngay keo ve) rai ra nhieu partition open_date; append = INSERT OVERWRITE dong theo (ds_snpst_dt, open_date) nen dump khac khong bi ghi de.
*                                       CAN tao lai bang ODS theo partition open_date (xem scratch/ods_atm_open_investors_repartition_20261025.sql).
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
    , CAST(open_date AS date)              AS open_date
    , CAST(nationality AS string)          AS nationality
    , CAST(phone_number AS string)         AS phone_number
    , CAST(email AS string)                AS email
FROM {{ source('source_vsdc', 'raw_open_investors') }}
WHERE open_date = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
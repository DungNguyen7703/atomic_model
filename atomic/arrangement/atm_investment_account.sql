/*
*--------------------------------------------------------------------*
* Program code: atm_investment_account
* Program name: Atomic Investment Account
* Created by: tuan.nguyenvanb
* Created date: 2026-10-15
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-15		tuan.nguyenvanb		[MOI] Atomic Investment Account tu VSDC open_investors, map 1-1.
*                                       investor_type map nguyen gia tri sang investment_account_tp_code
*                                       (3 ca nhan trong nuoc, 5 to chuc trong nuoc). open_date map sang
*                                       event_dt theo LLD GSTT v4.49 (chon ban ghi moi nhat theo event_dt
*                                       cua tung so tai khoan, viec dedupe lam o tang mart). Atomic giu nguyen
*                                       ban ghi nguon, tich luy theo ds_snpst_dt.
* 2026-10-16		tuan.nguyenvanb		KHONG loc theo etl_date (so nhan ~1 lan/tuan): lay cac ds_snpst_dt co o ODS ma atomic
*                                       chua co + ghi de lai ngay moi nhat cua ODS. Tam map 1-1 tu ODS (LLD atomic chua
*                                       chot); dedupe theo BA (so TK, open_date desc) lam o tang mart.
*--------------------------------------------------------------------*
*/

-- [2026-10-16] Ngay can nap: ngay ODS co ma atomic chua co, cong ngay moi nhat cua ODS (luon ghi de lai)
WITH new_dt AS (
    SELECT s.ds_snpst_dt
    FROM (
        SELECT DISTINCT ds_snpst_dt FROM {{ ref('ods_vsdc_open_investors') }}
    ) s
    LEFT ANTI JOIN (
        SELECT DISTINCT ds_snpst_dt FROM {{ this }}
    ) t ON t.ds_snpst_dt = s.ds_snpst_dt
    UNION
    SELECT MAX(ds_snpst_dt) AS ds_snpst_dt FROM {{ ref('ods_vsdc_open_investors') }}
),

op_in AS (
    SELECT
        customer_name
        , investor_type
        , trading_account_no
        , address
        , id_number
        , issue_date
        , issue_place
        , open_date
        , nationality
        , phone_number
        , email
        , ds_snpst_dt
    FROM {{ ref('ods_vsdc_open_investors') }}
    WHERE ds_snpst_dt IN (SELECT ds_snpst_dt FROM new_dt)
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_OPEN_INVESTORS', "concat_ws('-', op_in.trading_account_no, cast(op_in.open_date as string))") }} AS investment_account_id
    , CAST('VSDC_OPEN_INVESTORS' AS string)            AS src_stm_code
    , CAST(op_in.trading_account_no AS string)         AS investment_account_nbr
    , CAST(op_in.customer_name AS string)              AS investor_nm
    , CAST(op_in.investor_type AS string)              AS investment_account_tp_code
    , CAST(op_in.address AS string)                    AS address
    , CAST(op_in.id_number AS string)                  AS identification_nbr
    , CAST(op_in.issue_date AS date)                   AS issue_dt
    , CAST(op_in.issue_place AS string)                AS issue_place
    , CAST(op_in.open_date AS date)                    AS event_dt
    , CAST(op_in.nationality AS string)                AS nationality_nm
    , CAST(op_in.phone_number AS string)               AS phone_nbr
    , CAST(op_in.email AS string)                      AS email_address
    , CAST(op_in.ds_snpst_dt AS date)                  AS ds_snpst_dt
FROM op_in

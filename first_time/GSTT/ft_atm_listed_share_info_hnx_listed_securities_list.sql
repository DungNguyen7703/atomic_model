-- [FIRST-TIME] ft_atm_listed_share_info_hnx_listed_securities_list: ban ephemeral cua atm_listed_share_info_hnx_listed_securities_list cho bo first-time.
/*
*--------------------------------------------------------------------*
* Program code: atm_listed_share_info_hnx_listed_securities_list
* Program name: Atomic Listed Share Info – HNX.LISTED_SECURITIES_LIST
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)
WITH lst_sec AS (
    SELECT
        ticker_symbol
        , issuer_name
        , listed_shares
        , outstanding_shares
        , reference_price
        , ds_snpst_dt
    FROM {{ ft_ref('ft_ods_hnx_listed_securities_list') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('HNX_LISTED_SECURITIES_LIST', "lst_sec.ticker_symbol") }} AS listed_share_info_id
    , CAST(lst_sec.ticker_symbol AS string)            AS ticker_symbol
    , CAST('HNX_LISTED_SECURITIES_LIST' AS string)     AS src_stm_code
    , CAST(NULL AS string)                             AS isin_code
    , CAST(NULL AS bigint)                             AS total_issued_share_quantity
    , CAST(NULL AS bigint)                             AS treasury_share_quantity
    , CAST(lst_sec.outstanding_shares AS bigint)       AS outstanding_share_quantity
    , CAST(NULL AS bigint)                             AS free_float_share_quantity
    , CAST(NULL AS bigint)                             AS restricted_share_quantity
    , CAST(NULL AS bigint)                             AS voting_share_quantity
    , CAST(lst_sec.issuer_name AS string)              AS issuer_name
    , CAST(lst_sec.listed_shares AS bigint)            AS listed_share_quantity
    , CAST(lst_sec.reference_price AS decimal(23,2))   AS reference_price
    , CAST(NULL AS date)                               AS transaction_date
    , CAST(lst_sec.ds_snpst_dt AS date) AS ds_snpst_dt  -- [BACKFILL-UAT-NEW] cot ds_snpst_dt (first-time)
FROM lst_sec

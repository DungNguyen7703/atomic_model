/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_banks
* Program name: Staging NHNCK.BANKS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot); kieu date sang timestamp (2 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(bank_code AS string)         AS bank_code
    , CAST(bank_name AS string)         AS bank_name
    , CAST(short_name AS string)        AS short_name
    , CAST(bank_key AS string)          AS bank_key
    , CAST(english_bank_name AS string) AS english_bank_name
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(updated_at AS timestamp)     AS updated_at
    , CAST(created_by AS bigint)        AS created_by
    , CAST(updated_by AS bigint)        AS updated_by
FROM {{ source('source_nhnck', 'raw_banks') }}
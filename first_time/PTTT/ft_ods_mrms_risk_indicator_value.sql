-- [FIRST-TIME] ft_ods_mrms_risk_indicator_value: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_mrms_risk_indicator_value (config ft_target='risk_indicator_value', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_mrms_risk_indicator_value
* Program name: ODS MRMS.RISK_INDICATOR_VALUE (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		Tao moi: doc stg first-time (ft_ref), giu deleted = 0, khong loc ngay; cung cot/thu tu voi ods daily.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , indicator_id
    , period_type
    , period_value
    , period_year
    , period_date
    , period_label
    , unit_code
    , source_code
    , data_origin
    , created_at
    , updated_at
    , created_by_id
    , updated_by_id
    , created_by_name
    , updated_by_name
    , deleted
    , cumulative_value
    , value
    , data_dt
FROM {{ ft_ref('ft_stg_mrms_risk_indicator_value') }}
WHERE deleted = 0   -- giu loc nghiep vu cua daily; bo loc data_dt = etl_date (first-time lay toan bo stg vua nap)

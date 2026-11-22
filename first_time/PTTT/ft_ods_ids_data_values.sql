-- [FIRST-TIME] ft_ods_ids_data_values: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily ods_ids_data_values (config ft_target='data_values', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: ods_ids_data_values
* Program name: ODS IDS.DATA_VALUES (FIRST-TIME)
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-16		tuan.nguyenvanb		Tao moi: doc stg first-time (ft_ref), khong loc ngay, cung cot/thu tu voi ods daily.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , field_name_vi
    , field_name_en
    , text_value
    , date_value
    , number_value
    , company_data_id
    , parent_id
    , form_id
    , field_id
    , form_field_id
    , field_parent_id
    , data_type
    , required_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , data_dt
FROM {{ ft_ref('ft_stg_ids_data_values') }}
-- [BACKFILL-UAT-ORIG] daily loc data_dt = etl_date; first-time lay toan bo stg vua nap

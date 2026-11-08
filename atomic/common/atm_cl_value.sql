/*
*--------------------------------------------------------------------*
* Program code: atm_cl_value
* Program name: Atomic Classification Value - Multi Source
* Created by: tuan.nguyenvanb
* Created date: 2026-11-06
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-06		tuan.nguyenvanb		[MOI] Model cha gop cac model con theo nguon (UNION ALL), nap bang dung chung cl_value bang scd2 (bang vat ly co ds_rcrd_st, ds_rcrd_eff_dt, ds_rcrd_end_dt; upsert loi UNRESOLVED_COLUMN ds_rcrd_eff_dt).
*									CANH BAO: scd2 KHONG gioi han theo src_stm_code - dong ACTIVE cua nguon khac khong co trong UNION ALL se bi DONG (D). Model giu nguyen (passthrough) cac dong ACTIVE cua nguon khac doc tu bang vat ly qua source('source_atm','raw_classification_value').
*									Them nguon moi: them model con atm_cl_value_<nguon> va them vao UNION ALL ben duoi.
*--------------------------------------------------------------------*
*/

SELECT
    cl_code
    , schema_code
    , schema_nm
    , src_stm_code
    , cl_nm
    , cl_nm_english
    , cl_description
FROM {{ ref('atm_cl_value_ids_lookup_values') }}

UNION ALL

-- Giu nguyen cac dong ACTIVE cua nguon KHAC dang co trong bang dung chung cl_value (TTHC / NHNCK ...): scd2 khong loc theo src_stm_code
-- nen neu thieu doan nay cac dong do bi DONG. Khi mot nguon co model con rieng thi bo nguon do khoi dieu kien loai tru ben duoi va UNION ALL model con.
SELECT
    cl_code
    , schema_code
    , schema_nm
    , src_stm_code
    , cl_nm
    , cl_nm_english
    , cl_description
FROM {{ source('source_atm', 'raw_classification_value') }}
WHERE ds_rcrd_st = 'ACTIVE'
    AND ds_rcrd_end_dt = to_date('2400-01-01')
    AND src_stm_code <> 'IDS_LOOKUP_VALUES'

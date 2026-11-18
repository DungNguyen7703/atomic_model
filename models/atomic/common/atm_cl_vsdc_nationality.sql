/*
*--------------------------------------------------------------------*
* Program code: atm_cl_vsdc_nationality
* Program name: Atomic Classification VSDC Nationality
* Created by: tuan.nguyenvanb
* Created date: 2026-10-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-25		tuan.nguyenvanb		[MOI] Theo lld_VSDC_NATIONALITY.yaml (2026-10-19). Relative -> upsert (cung kieu atm_cl_nationality). Doc ban moi nhat cua ods_vsdc_nationality (ODS nhan ~1 lan/tuan nen khong loc theo etl_date).
*--------------------------------------------------------------------*
*/

SELECT
    {{ generate_surrogate_key_bigint('VSDC_NATIONALITY', "autoid") }}   AS cl_vsdc_nationality_id
    , CAST(autoid AS string)                                            AS cl_vsdc_nationality_code
    , CAST('VSDC_NATIONALITY' AS string)                                AS src_stm_code
    , CAST(name AS string)                                              AS cl_vsdc_nationality_nm
FROM {{ ref('ods_vsdc_nationality') }}

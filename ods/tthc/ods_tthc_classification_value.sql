

/*
*--------------------------------------------------------------------*
* Program code: ods_tthc_classification_value
* Program name: ODS TTHC.CL_VALUE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT contentitemid AS CLASSIFICATION_CODE, 'TTHC.PROCESSING_STATUS' AS SCHEMA_CODE, 'TTHC - Danh mục trạng thái hồ sơ' AS SCHEMA_NM, displaytext AS CLASSIFICATION_NAME, NULL AS CLASSIFICATION_NAME_ENGLISH, NULL AS CLASSIFICATION_DESCRIPTION
FROM staging.uat_tthc_stg.contentitemindex
WHERE LATEST = 1
  AND PUBLISHED = 1
  AND CONTENTTYPE = 'DanhMucTrangThaiHoSo'
  AND ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

UNION ALL

SELECT contentitemid AS CLASSIFICATION_CODE, 'TTHC.DOCUMENT_TYPE' AS SCHEMA_CODE, 'TTHC - Loại hồ sơ' AS SCHEMA_NM, displaytext AS CLASSIFICATION_NAME, NULL AS CLASSIFICATION_NAME_ENGLISH, NULL AS CLASSIFICATION_DESCRIPTION
FROM staging.uat_tthc_stg.contentitemindex
WHERE LATEST = 1
  AND PUBLISHED = 1
  AND CONTENTTYPE = 'DanhMucTTHC'
  AND ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

UNION ALL

SELECT contentitemid AS CLASSIFICATION_CODE, 'TTHC.PROCESSING_AUTHORITY' AS SCHEMA_CODE, 'TTHC - Cơ quan xử lý' AS SCHEMA_NM, displaytext AS CLASSIFICATION_NAME, NULL AS CLASSIFICATION_NAME_ENGLISH, NULL AS CLASSIFICATION_DESCRIPTION
FROM staging.uat_tthc_stg.contentitemindex
WHERE LATEST = 1
  AND PUBLISHED = 1
  AND CONTENTTYPE = 'CoQuanTiepNhan'
  AND ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_auto_increment_codes
* Program name: Staging NHNCK.AUTO_INCREMENT_CODES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot); them cot data_dt.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(certificate_id AS bigint) AS certificate_id
    , CAST(code AS string)           AS code
    , CAST(record_type AS bigint)    AS record_type
    , CAST(document_type AS bigint)  AS document_type
    , CAST('{{ var("etl_date") }}' AS date) AS data_dt
FROM {{ source('source_nhnck', 'raw_auto_increment_codes') }}
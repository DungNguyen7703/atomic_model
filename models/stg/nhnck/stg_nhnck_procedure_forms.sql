/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_procedure_forms
* Program name: Staging NHNCK.PROCEDURE_FORMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (4 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)             AS id
    , CAST(procedure_id AS bigint) AS procedure_id
    , CAST(form_id AS bigint)      AS form_id
    , CAST(quantity AS bigint)     AS quantity
FROM {{ source('source_nhnck', 'raw_procedure_forms') }}
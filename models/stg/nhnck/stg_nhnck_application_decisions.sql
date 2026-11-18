/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_decisions
* Program name: Staging NHNCK.APPLICATION_DECISIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (3 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)               AS id
    , CAST(application_id AS bigint) AS application_id
    , CAST(decision_id AS bigint)    AS decision_id
FROM {{ source('source_nhnck', 'raw_application_decisions') }}
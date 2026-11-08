/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_experiences
* Program name: Staging NHNCK.APPLICATION_EXPERIENCES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu int sang bigint (6 cot); kieu date sang timestamp (2 cot); them cot data_dt.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                      AS id
    , CAST(application_id AS bigint)        AS application_id
    , CAST(document_id AS bigint)           AS document_id
    , CAST(work_duration AS bigint)         AS work_duration
    , CAST(organization_id AS bigint)       AS organization_id
    , CAST(organization_name AS string)     AS organization_name
    , CAST(department_name AS string)       AS department_name
    , CAST(insurance_number AS string)      AS insurance_number
    , CAST(labor_contract AS string)        AS labor_contract
    , CAST(director_confirmation AS string) AS director_confirmation
    , CAST(note AS string)                  AS note
    , CAST(total_duration AS bigint)        AS total_duration
    , CAST(start_date AS timestamp)         AS start_date
    , CAST(end_date AS timestamp)           AS end_date
    , CAST(position AS string)              AS position
    , CAST('{{ var("etl_date") }}' AS date) AS data_dt
FROM {{ source('source_nhnck', 'raw_application_experiences') }}
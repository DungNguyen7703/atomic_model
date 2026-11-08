/*
*--------------------------------------------------------------------*
* Program code: ods_nhnck_professional_relationships
* Program name: ODS NHNCK.PROFESSIONAL_RELATIONSHIPS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , professional_id
    , relationship_type
    , full_name
    , birth_year
    , address
    , occupation
    , workplace
    , note
    , created_at
    , country_id
    , identity_id
    , updated_at
    , created_by
    , updated_by
FROM {{ ref('stg_nhnck_professional_relationships') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
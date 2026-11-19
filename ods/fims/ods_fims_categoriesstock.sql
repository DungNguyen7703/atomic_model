/*
*--------------------------------------------------------------------*
* Program code: ods_fims_categoriesstock
* Program name: ODS FIMS.CATEGORIESSTOCK
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-10		tra		Them dieu kien loc ban ghi con hieu luc (theo ods_filters.pdf): deleted = 0
*--------------------------------------------------------------------*
*/

SELECT
    id
    , invesid
    , secid
    , quantity
    , deleted
    , datecreated
    , datemodified
    , createdby
    , modifyby
    , rate
    , issynced
FROM {{ ref('stg_fims_categoriesstock') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
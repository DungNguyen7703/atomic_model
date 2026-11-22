/*
*--------------------------------------------------------------------*
* Program code: ods_fims_rpttemp
* Program name: ODS FIMS.RPTTEMP
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
    , deleted
    , datecreated
    , createdby
    , datemodified
    , modifyby
    , name
    , legalbasis
    , code
    , reporttypeid
    , reportgroup
    , isneedimport
    , isneedpublic
    , systemobjects
    , description
    , filedata
    , status
    , version
    , dateused
    , iseform
    , eformschemajson
    , excelconfigjson
    , sheetsdesignerjson
FROM {{ ref('stg_fims_rpttemp') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
  AND deleted = 0
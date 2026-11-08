/*
*--------------------------------------------------------------------*
* Program code: ods_scms_lnk_sc_firm_foreign_branch_service
* Program name: ODS SCMS.LNK_SC_FIRM_FOREIGN_BRANCH_SERVICE
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
    , sc_firm_foreign_branch_id
    , service_id
    , created_at
FROM {{ ref('stg_scms_lnk_sc_firm_foreign_branch_service') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
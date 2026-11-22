/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_tvhistory1d
* Program name: ODS MDDS.JAD_TVHISTORY1D
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-11-12		ngoc.pham		WHERE loc ngay theo BRD (date_format dd/MM/yyyy); Dong bo schema.yml theo BRD: strategy=append, partition_by=['data_dt']
*--------------------------------------------------------------------*
*/

SELECT
    id
    , close
    , high
    , low
    , open
    , symbol
    , tradingdate
    , volume
    , data_dt
FROM {{ ref('stg_mdds_jad_tvhistory1d') }}
WHERE tradingdate = date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'dd/MM/yyyy')
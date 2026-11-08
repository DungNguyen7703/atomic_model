/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_csidxinfor
* Program name: ODS MDDS.JAD_CSIDXINFOR
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
    , indexcode
    , symbol
    , totalqtty
    , adddate
    , indexid
    , floorcode
    , tradingdate
    , stockno
    , weighted
FROM {{ ref('stg_mdds_jad_csidxinfor') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
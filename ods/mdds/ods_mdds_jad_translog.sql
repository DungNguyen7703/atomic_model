/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_translog
* Program name: ODS MDDS.JAD_TRANSLOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    kid
    , sequencemsg
    , tradingdate
    , symbol
    , formattedtime
    , lastcolor
    , formattedmatchprice
    , changecolor
    , formattedvol
    , formattedaccvol
    , formattedaccval
    , totalbuyvol
    , totalsellvol
    , boardid
    , formattedchangevalue
FROM {{ ref('stg_mdds_jad_translog') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
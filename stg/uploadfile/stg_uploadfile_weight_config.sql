/*
*--------------------------------------------------------------------*
* Program code: stg_uploadfile_weight_config
* Program name: Staging UBCK.WEIGHT_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		nghia.le			[SUA] Them loc record_status = 1 ngay khi keo tu nguon (chuyen tu ODS len): chi lay phien ban dang hieu luc cua UBCK.WEIGHT_CONFIG.
* 2026-11-07		nghia.le			[SUA] Cast id va upload_history_id qua int roi ve string (nguon Oracle NUMBER khong precision -> Spark DECIMAL(38,10) -> cast string thang ra 1.0000000000); giu string dong nhat voi cac job khac.
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(CAST(id AS int) AS string)           AS id
    , CAST(output_indicator_code AS string)   AS output_indicator_code
    , CAST(input_indicator_code AS string)    AS input_indicator_code
    , CAST(input_indicator_name AS string)    AS input_indicator_name
    , CAST(weight AS decimal(38,20))          AS weight
    , CAST(effective_date AS date)            AS effective_date
    , CAST(end_date AS date)                  AS end_date
    , CAST(record_status AS int)              AS record_status
    , CAST(created_at AS date)                AS created_at
    , CAST(createdby AS string)               AS createdby
    , CAST(CAST(upload_history_id AS int) AS string) AS upload_history_id
FROM {{ source('source_uploadfile', 'raw_weight_config') }}
WHERE record_status = 1   -- chi lay phien ban dang hieu luc (phien ban cu record_status = 0 co end_date); khong loc -> atomic giu ca ban cu, mart nhan dong/chon nham

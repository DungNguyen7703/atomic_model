/*
*--------------------------------------------------------------------*
* Program code: stg_uploadfile_threshold_config
* Program name: Staging UBCK.THRESHOLD_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-07		nghia.le			[SUA] Them loc record_status = 1 ngay khi keo tu nguon (chuyen tu ODS len): chi lay phien ban dang hieu luc cua UBCK.THRESHOLD_CONFIG.
* 2026-11-07		nghia.le			[SUA] Cast id va upload_history_id qua int roi ve string (nguon Oracle NUMBER khong precision -> Spark DECIMAL(38,10) -> cast string thang ra 1.0000000000); giu string dong nhat voi cac job khac.
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(CAST(id AS int) AS string)       AS id
    , CAST(indicator_code AS string)      AS indicator_code
    , CAST(indicator_name AS string)      AS indicator_name
    , CAST(value_from AS decimal(18,2))   AS value_from
    , CAST(value_to AS decimal(18,2))     AS value_to
    , CAST(status AS string)              AS status
    , CAST(effective_date AS date)        AS effective_date
    , CAST(end_date AS date)              AS end_date
    , CAST(record_status AS int)          AS record_status
    , CAST(created_at AS date)            AS created_at
    , CAST(createdby AS string)           AS createdby
    , CAST(CAST(upload_history_id AS int) AS string) AS upload_history_id
FROM {{ source('source_uploadfile', 'raw_threshold_config') }}
WHERE record_status = 1   -- chi lay phien ban dang hieu luc (phien ban cu record_status = 0 co end_date); khong loc -> atomic giu ca ban cu, mart nhan dong/chon nham

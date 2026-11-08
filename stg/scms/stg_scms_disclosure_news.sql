/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_news
* Program name: Staging SCMS.DISCLOSURE_NEWS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
* 2026-11-02		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod.sql: kieu int sang bigint (1 cot).
* 2026-11-03		tuan.nguyenvanb		Dong bo theo DDL production SCMS_ddl_prod 1.sql va BRD brd_SCMS.yaml: kieu date sang timestamp (3 cot); WHERE loc theo cot datecreated trong ngay chay (theo BRD filter_logic).
* 2026-11-03		tuan.nguyenvanb		Khoi phuc partition_by (datecreated) cho bang append (INSERT OVERWRITE theo partition de tich luy lich su).
* 2026-11-03		tuan.nguyenvanb		WHERE loc ngay boc date_format(datecreated,'yyyy-MM-dd') de khong day filter xuong Oracle JDBC (loi Missing IN or OUT parameter).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(newsid AS decimal(20,0))  AS newsid
    , CAST(category AS int)          AS category
    , CAST(record_type AS bigint)    AS record_type
    , CAST(secid AS decimal(20,0))   AS secid
    , CAST(title AS string)          AS title
    , CAST(content AS string)        AS content
    , CAST(datecreated AS timestamp) AS datecreated
    , CAST(errlog AS string)         AS errlog
    , CAST(description AS string)    AS description
    , CAST(publishby AS string)      AS publishby
    , CAST(publishdate AS timestamp) AS publishdate
    , CAST(senddate AS timestamp)    AS senddate
    , CAST(record_status AS int)     AS record_status
    , CAST(published_date AS string) AS published_date
FROM {{ source('source_scms', 'raw_disclosure_news') }}
WHERE date_format(datecreated, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(datecreated, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1
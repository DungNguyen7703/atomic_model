WITH d AS (
    SELECT *
    FROM {{ ref('stg_tthc_document') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
),
c AS (
    SELECT *
    FROM {{ ref('stg_tthc_contentitemindex') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND LATEST = 1
      AND PUBLISHED = 1
      AND CONTENTTYPE = 'HoSoTTHC'
),
filtered_applicant AS (
	select CONTENTITEMID, DISPLAYTEXT
	from {{ ref('stg_tthc_contentitemindex') }}
	WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND LATEST = 1
      AND PUBLISHED = 1
      AND (CONTENTTYPE = 'DoiTuongNopHoSo' OR CONTENTTYPE = 'CtdcThongTin')
),
pre_detail as(
SELECT
    get_json_object(
        d.content,
        '$.HoSoTTHC.DoiTuongNopHoSo.ContentItemIds[0]'
    ) AS ap_document_applicant_id,

    get_json_object(
        d.content,
        '$.HoSoTTHC.DoiTuongNopHoSoEmail.Text'
    ) AS email,

    get_json_object(
        d.content,
        '$.HoSoTTHC.SoDienThoai.Text'
    ) AS phone_number
FROM d
INNER JOIN c
    ON d.id = c.documentid
),
-- select distinct pd.ap_document_applicant_id as ap_document_applicant_id, fa.displaytext as display_name, pd.phone_number as phone_number, pd.email as email from pre_detail pd inner join filtered_applicant fa on pd.ap_document_applicant_id = fa.CONTENTITEMID
ranked AS (
    SELECT
        pd.ap_document_applicant_id,
        fa.displaytext                                          AS display_name,
        pd.phone_number,
        pd.email,
        ROW_NUMBER() OVER (
            PARTITION BY pd.ap_document_applicant_id
            ORDER BY pd.ap_document_applicant_id
        )                                                       AS rn
    FROM pre_detail pd
    INNER JOIN filtered_applicant fa
        ON pd.ap_document_applicant_id = fa.CONTENTITEMID
)
SELECT
    ap_document_applicant_id,
    display_name,
    phone_number,
    email
FROM ranked
WHERE rn = 1

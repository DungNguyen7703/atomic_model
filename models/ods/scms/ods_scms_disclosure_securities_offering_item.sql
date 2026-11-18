/*
*--------------------------------------------------------------------*
* Program code: ods_scms_disclosure_securities_offering_item
* Program name: ODS SCMS.DISCLOSURE_SECURITIES_OFFERING - items parsed from result_json
* Grain: 1 row / (id, offering_method, offering_target_code)
* Schema = union of all JSON variants (17 fields); missing key => NULL
* Tất cả field JSON giữ nguyên STRING (raw), ép kiểu ở lớp atomic
* duKien*: result_json first, fallback plan_json (same array position)
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH src AS (
    SELECT
        id
        , sc_firm_info_id
        , ds_snpst_dt
        , result_json
        , plan_json
    FROM {{ ref('stg_scms_disclosure_securities_offering') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

, parsed AS (
    SELECT
        id
        , sc_firm_info_id
        , ds_snpst_dt
        , from_json(result_json,
            'ARRAY<STRUCT<
                doiTuongChaoBan: STRING, loaiChaoBan: STRING, menhGia: STRING,
                soLuongCb: STRING, giaCb: STRING, giaTriCbTheoMenhGia: STRING,
                soLuongNguoiCb: STRING, moTaDoiTuong: STRING, mucDichHoanDoi: STRING,
                duKienTuNgay: STRING, duKienDenNgay: STRING,
                soLuongThucTe: STRING, giaThucTe: STRING, giaTriThucTe: STRING,
                soLuongNguoiThamGia: STRING, slNdtnnThamGia: STRING, giaTriPhatHanhNdtnn: STRING
            >>') AS res_items
        , from_json(plan_json,
            'ARRAY<STRUCT<duKienTuNgay: STRING, duKienDenNgay: STRING>>') AS plan_items
    FROM src
)

SELECT
    p.id
    , p.sc_firm_info_id
    -- kế hoạch chào bán
    , e.item.doiTuongChaoBan                                            AS offering_target_code
    , e.item.loaiChaoBan                                                AS offering_method
    , e.item.menhGia AS par_value
    , e.item.soLuongCb AS planned_quantity
    , e.item.giaCb AS planned_price
    , e.item.giaTriCbTheoMenhGia AS planned_value_at_par
    , e.item.soLuongNguoiCb AS planned_investor_count
    , e.item.moTaDoiTuong                                               AS target_description
    , e.item.mucDichHoanDoi                                             AS exchange_purpose
    -- thời gian dự kiến
    , coalesce(e.item.duKienTuNgay,  CASE WHEN e.pos < size(p.plan_items) THEN p.plan_items[e.pos].duKienTuNgay END) AS expected_start_date
    , coalesce(e.item.duKienDenNgay, CASE WHEN e.pos < size(p.plan_items) THEN p.plan_items[e.pos].duKienDenNgay END) AS expected_end_date
    -- kết quả thực tế
    , e.item.soLuongThucTe AS actual_quantity
    , e.item.giaThucTe AS actual_price
    , e.item.giaTriThucTe AS actual_value
    , e.item.soLuongNguoiThamGia AS participant_count
    , e.item.slNdtnnThamGia AS foreign_investor_participant_count
    , e.item.giaTriPhatHanhNdtnn AS foreign_investor_issued_value
FROM parsed p
LATERAL VIEW posexplode_outer(p.res_items) e AS pos, item

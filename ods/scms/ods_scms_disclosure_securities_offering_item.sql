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
            'ARRAY<STRUCT<
                doiTuongChaoBan: STRING, loaiChaoBan: STRING, menhGia: STRING,
                soLuongCb: STRING, giaCb: STRING, giaTriCbTheoMenhGia: STRING,
                soLuongNguoiCb: STRING, moTaDoiTuong: STRING, mucDichHoanDoi: STRING,
                duKienTuNgay: STRING, duKienDenNgay: STRING
            >>') AS plan_items
    FROM src
)

/* explode thường (không _outer): id không có item nào thì không sinh dòng */
, res AS (
    SELECT p.id, p.sc_firm_info_id, p.ds_snpst_dt, r.itm
    FROM parsed p
    LATERAL VIEW explode(p.res_items) r AS itm
)

, pln AS (
    SELECT p.id, p.sc_firm_info_id, p.ds_snpst_dt, q.itm
    FROM parsed p
    LATERAL VIEW explode(p.plan_items) q AS itm
)

SELECT
    coalesce(res.id, pln.id)                                                  AS id
    , coalesce(res.sc_firm_info_id, pln.sc_firm_info_id)                      AS sc_firm_info_id
    -- kế hoạch chào bán (result_json)
    , coalesce(res.itm.doiTuongChaoBan, pln.itm.doiTuongChaoBan)              AS offering_target_code
    , coalesce(res.itm.loaiChaoBan, pln.itm.loaiChaoBan)                      AS offering_method
    , res.itm.menhGia                                                         AS par_value
    , res.itm.soLuongCb                                                       AS planned_quantity
    , res.itm.giaCb                                                           AS planned_price
    , res.itm.giaTriCbTheoMenhGia                                             AS planned_value_at_par
    , res.itm.soLuongNguoiCb                                                  AS planned_investor_count
    , res.itm.moTaDoiTuong                                                    AS target_description
    , res.itm.mucDichHoanDoi                                                  AS exchange_purpose
    -- thời gian dự kiến: result_json trước, thiếu thì lấy plan_json
    , coalesce(res.itm.duKienTuNgay, pln.itm.duKienTuNgay)                    AS expected_start_date
    , coalesce(res.itm.duKienDenNgay, pln.itm.duKienDenNgay)                  AS expected_end_date
    -- kết quả thực tế (result_json)
    , res.itm.soLuongThucTe                                                   AS actual_quantity
    , res.itm.giaThucTe                                                       AS actual_price
    , res.itm.giaTriThucTe                                                    AS actual_value
    , res.itm.soLuongNguoiThamGia                                             AS participant_count
    , res.itm.slNdtnnThamGia                                                  AS foreign_investor_participant_count
    , res.itm.giaTriPhatHanhNdtnn                                             AS foreign_investor_issued_value
    -- plan_json
    , pln.itm.doiTuongChaoBan                                                 AS plan_offering_target_code
    , pln.itm.loaiChaoBan                                                     AS plan_offering_method
    , pln.itm.menhGia                                                         AS plan_par_value
    , pln.itm.soLuongCb                                                       AS plan_quantity
    , pln.itm.giaCb                                                           AS plan_price
    , pln.itm.giaTriCbTheoMenhGia                                             AS plan_value_at_par
    , pln.itm.soLuongNguoiCb                                                  AS plan_investor_count
    , pln.itm.moTaDoiTuong                                                    AS plan_target_description
    , pln.itm.mucDichHoanDoi                                                  AS plan_exchange_purpose
    , pln.itm.duKienTuNgay                                                    AS plan_expected_start_date
    , pln.itm.duKienDenNgay                                                   AS plan_expected_end_date
FROM res
FULL OUTER JOIN pln
    ON  res.id = pln.id
    AND res.itm.loaiChaoBan <=> pln.itm.loaiChaoBan
    AND res.itm.doiTuongChaoBan <=> pln.itm.doiTuongChaoBan

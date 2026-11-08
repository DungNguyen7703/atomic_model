/*
*--------------------------------------------------------------------*
* Program code: atm_petition
* Program name: Atomic Petition
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-09-29   tuan.nguyenvanb   [FIX - da xac minh bang du lieu that]
*                       Loi "[SCD4A] DUPLICATE KEY DETECTED: 1 key(s) bi
*                       dup", model=petition, etl_date=2026-09-28.
*                       Root cause THAT (da query truc tiep nguon):
*                       SELECT COUNT(*) FROM THANHTRA_UAT.PETITION WHERE
*                       code IS NULL => ra 161 dong. generate_surrogate_
*                       key_bigint('THANHTRA_PETITION', code) khi code=
*                       NULL se hash ve CUNG 1 gia tri cho ca 161 dong =>
*                       gop lai thanh dung "1 key bi dup" nhu log bao.
* 2026-09-29b  tuan.nguyenvanb   [DOI HUONG - theo yeu cau BA] Thay vi loai
*                       161 dong code NULL, doi han sang dung cot `id`
*                       (khoa vat ly cua nguon, luon co gia tri, khong bao
*                       gio NULL/trung) lam co so sinh petition_id, thay
*                       cho `code` (truong nghiep vu, co the rong khi
*                       petition chua duoc gan ma). petition_code van giu
*                       nguyen tu `code` (co the NULL, chi la thuoc tinh
*                       hien thi, khong con la khoa). Nho: original_
*                       petition_id da san dung dung gia tri `id` cua
*                       petition khac (khong phai `code`) nen cong thuc
*                       generate_surrogate_key_bigint cho no GIU NGUYEN
*                       khong doi - tu dong khop voi petition_id moi.
*--------------------------------------------------------------------*
*/

WITH peti AS (
    SELECT
        id
        , code
        , received_date
        , forwarding_unit
        , sender_name
        , sender_address
        , content
        , petition_category
        , related_to_corporate_bond
        , eligible_for_processing
        , within_jurisdiction
        , assigned_officer_id
        , assigned_officer_name
        , duplicate_type
        , original_petition_id
        , submission_number
        , transferred_authority
        , internal_transfer_unit_name
        , archived
        , guidance_document_number
        , guidance_document_date
        , status
        , end_date
        , note
        , target_name
    FROM {{ ref('ods_thanhtra_petition') }}
    WHERE id IS NOT NULL
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PETITION', "peti.id") }}                     AS petition_id
    , CAST(peti.code AS string)                                                             AS petition_code
    , CAST('THANHTRA_PETITION' AS string)                                                   AS src_stm_code
    , CAST(peti.received_date AS date)                                                      AS received_dt
    , CAST(peti.forwarding_unit AS string)                                                  AS forwarding_unit
    , CAST(peti.sender_name AS string)                                                      AS sender_nm
    , CAST(peti.sender_address AS string)                                                   AS sender_adr
    , CAST(peti.content AS string)                                                          AS content
    , CAST(peti.petition_category AS string)                                                AS petition_category_code
    , CAST(peti.related_to_corporate_bond AS string)                                        AS related_to_corporate_bond_indicator
    , CAST(peti.eligible_for_processing AS string)                                          AS eligible_for_processing_indicator
    , CAST(peti.within_jurisdiction AS string)                                              AS within_jurisdiction_indicator
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "peti.assigned_officer_id") }}        AS assigned_officer_id
    , CAST(peti.assigned_officer_name AS string)                                            AS assigned_officer_nm
    , CAST(peti.duplicate_type AS string)                                                   AS duplicate_tp_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PETITION', "peti.original_petition_id") }} AS original_petition_id
    , CAST(peti.original_petition_id AS string)                                             AS original_petition_code
    , CAST(peti.submission_number AS string)                                                AS submission_nbr
    , CAST(peti.transferred_authority AS string)                                            AS transferred_authority
    , CAST(peti.internal_transfer_unit_name AS string)                                      AS internal_transfer_unit_nm
    , CAST(peti.archived AS string)                                                         AS archived_indicator
    , CAST(peti.guidance_document_number AS string)                                         AS guidance_document_nbr
    , CAST(peti.guidance_document_date AS date)                                             AS guidance_document_dt
    , CAST(peti.status AS string)                                                           AS life_cycle_status_code
    , CAST(peti.end_date AS date)                                                           AS end_dt
    , CAST(peti.note AS string)                                                             AS note
    , CAST(peti.target_name AS string)                                                      AS target_nm
FROM peti
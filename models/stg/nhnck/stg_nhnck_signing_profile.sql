/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_signing_profile
* Program name: Staging NHNCK.SIGNING_PROFILE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-11-02		tuan.nguyenvanb		Dong bo SQL theo production (production la ban dung): kieu float sang double (11 cot).
*--------------------------------------------------------------------*
*/

SELECT
    CAST(profile_key AS string)            AS profile_key
    , CAST(display_name AS string)         AS display_name
    , CAST(signature_kind AS string)       AS signature_kind
    , CAST(allow_manual_placement AS int)  AS allow_manual_placement
    , CAST(image_path AS string)           AS image_path
    , CAST(box_width AS double)            AS box_width
    , CAST(box_height AS double)           AS box_height
    , CAST(content_template AS string)     AS content_template
    , CAST(organization AS string)         AS organization
    , CAST(signer_email AS string)         AS signer_email
    , CAST(visual_mode AS string)          AS visual_mode
    , CAST(show_labels AS int)             AS show_labels
    , CAST(show_email AS int)              AS show_email
    , CAST(show_organization AS int)       AS show_organization
    , CAST(show_sign_time AS int)          AS show_sign_time
    , CAST(font_size AS double)            AS font_size
    , CAST(placement_mode AS string)       AS placement_mode
    , CAST(anchor_text AS string)          AS anchor_text
    , CAST(anchor_offset_x AS double)      AS anchor_offset_x
    , CAST(anchor_offset_y AS double)      AS anchor_offset_y
    , CAST(anchor_occurrence AS string)    AS anchor_occurrence
    , CAST(anchor_occurrence_index AS int) AS anchor_occurrence_index
    , CAST(anchor_side AS string)          AS anchor_side
    , CAST(anchor_page AS int)             AS anchor_page
    , CAST(anchor_fallbacks AS string)     AS anchor_fallbacks
    , CAST(extra_info_text AS string)      AS extra_info_text
    , CAST(page_number AS int)             AS page_number
    , CAST(llx AS double)                  AS llx
    , CAST(lly AS double)                  AS lly
    , CAST(corner_margin AS double)        AS corner_margin
    , CAST(corner AS string)               AS corner
    , CAST(hash_algorithm AS string)       AS hash_algorithm
    , CAST(reason AS string)               AS reason
    , CAST(require_registered_cert AS int) AS require_registered_cert
    , CAST(check_revocation AS int)        AS check_revocation
    , CAST(revocation_method AS string)    AS revocation_method
    , CAST(on_check_failure AS string)     AS on_check_failure
    , CAST(crl_urls AS string)             AS crl_urls
    , CAST(stamp_every_page AS int)        AS stamp_every_page
    , CAST(stamp_page_range AS string)     AS stamp_page_range
    , CAST(stamp_width AS double)          AS stamp_width
    , CAST(stamp_height AS double)         AS stamp_height
    , CAST(stamp_corner AS string)         AS stamp_corner
    , CAST(stamp_margin AS double)         AS stamp_margin
    , CAST(active AS int)                  AS active
    , CAST(owner_user_ref AS string)       AS owner_user_ref
FROM {{ source('source_nhnck', 'raw_signing_profile') }}

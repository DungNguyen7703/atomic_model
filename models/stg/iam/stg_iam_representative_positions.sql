/*
*--------------------------------------------------------------------*
* Program code: stg_iam_representative_positions
* Program name: Staging IAM.REPRESENTATIVE_POSITIONS
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Tao STG theo UAT_IAM_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(user_id AS string)     AS user_id
    , CAST(position_id AS string) AS position_id
FROM {{ source('source_iam', 'raw_representative_positions') }}
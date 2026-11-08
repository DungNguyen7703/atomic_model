/*
*--------------------------------------------------------------------*
* Program code: ods_uploadfile_weight_config
* Program name: ODS UBCK.WEIGHT_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-29		tuan.nguyenvanb		[SUA] Them loc record_status = 1 (chi phien ban dang hieu luc cua UBCK.WEIGHT_CONFIG).
* 2026-11-07		nghia.le			[SUA] Bo loc record_status = 1 o ODS; chuyen len stg_uploadfile_weight_config (loc ngay khi keo tu nguon UBCK.WEIGHT_CONFIG).
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , output_indicator_code
    , input_indicator_code
    , input_indicator_name
    , weight
    , effective_date
    , end_date
    , record_status
    , created_at
    , createdby
    , upload_history_id
FROM {{ ref('stg_uploadfile_weight_config') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')

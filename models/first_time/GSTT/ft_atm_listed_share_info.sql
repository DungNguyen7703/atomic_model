-- [FIRST-TIME] ft_atm_listed_share_info: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_listed_share_info (config ft_target='listed_share_info', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_listed_share_info
* Program name: Atomic Listed Share Info – Multi Source
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT * FROM {{ ft_ref('ft_atm_listed_share_info_vsdc_outstanding_shares') }}
UNION ALL
SELECT * FROM {{ ft_ref('ft_atm_listed_share_info_hnx_listed_securities_list') }}
UNION ALL
SELECT * FROM {{ ft_ref('ft_atm_listed_share_info_hose_listed_securities_list') }}

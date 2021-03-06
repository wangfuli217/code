
SELECT VW_ZEB_MERPS_PRCS_ORD_HEADER.PRCS_ORD_NUM ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.PRCS_ORD_TYP ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.PRCS_ORD_DESC ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.ACTUAL_START_DT ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.ACTUAL_FINISH_DT ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.ACTUAL_RELEASE_DT ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.SYSTEM_STATUS ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.QUANTITY_DELIVERED,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.UOM_FOR_QUANTITY_VAL  AS UOM_FOR_QUANTITY_VAL_PARENT,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.ALTERNATE_BOM ,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.MAT_COD  AS MAT_COD_PARENT,
	 VW_ZEB_MERPS_MATERIAL_INFO.MAT_DESC  AS MAT_DESC_PARENT,
	 VW_ZEB_MERPS_MATERIAL_INFO.MAT_TYP  AS MAT_TYP_PARENT,
	 VW_ZEB_MERPS_PRCS_ORD_HEADER.BAT_NUM  AS BAT_NUM_PARENT,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.RESERVATION_ITEM ,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.QUANTITY_WITHDRAWN,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.UOM_FOR_QUANTITY_VAL  AS UOM_FOR_QUANTITY_VAL,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.MFG_STG_OF_PROD ,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.WORK_CNTR_COD ,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.WORK_CNTR_DESC ,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.BOM_ITEM_NUM ,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.MAT_COD  AS MAT_COD,
	 VW_ZEB_MERPS_MATERIAL_INFO1.MAT_DESC ,
	 VW_ZEB_MERPS_MATERIAL_INFO1.MAT_TYP ,
	 VW_ZEB_MERPS_PRCS_ORD_MATERIAL.BAT_NUM  AS BAT_NUM,
	 VW_ZEB_MERPS_MATERIAL_BATCH.VENDOR_BAT_NUM ,
	 VW_ZEB_MERPS_MATERIAL_BATCH.MRP_VENDOR_ID ,
	 VW_ZEB_MERPS_MATERIAL_BATCH.MFG_DT  
 FROM ODS_DIST.VW_ZEB_MERPS_PRCS_ORD_HEADER VW_ZEB_MERPS_PRCS_ORD_HEADER 
	  LEFT JOIN ODS_DIST.VW_ZEB_MERPS_PRCS_ORD_MATERIAL VW_ZEB_MERPS_PRCS_ORD_MATERIAL ON (VW_ZEB_MERPS_PRCS_ORD_HEADER.PLANT_COD = VW_ZEB_MERPS_PRCS_ORD_MATERIAL.PLANT_COD) AND (VW_ZEB_MERPS_PRCS_ORD_HEADER.PRCS_ORD_NUM = VW_ZEB_MERPS_PRCS_ORD_MATERIAL.PRCS_ORD_NUM) 
	  LEFT JOIN ODS_DIST.VW_ZEB_MERPS_MATERIAL_INFO VW_ZEB_MERPS_MATERIAL_INFO ON (VW_ZEB_MERPS_PRCS_ORD_HEADER.PLANT_COD = VW_ZEB_MERPS_MATERIAL_INFO.PLANT_COD) AND (VW_ZEB_MERPS_PRCS_ORD_HEADER.MAT_COD = VW_ZEB_MERPS_MATERIAL_INFO.MAT_COD) 
	  LEFT JOIN ODS_DIST.VW_ZEB_MERPS_MATERIAL_INFO VW_ZEB_MERPS_MATERIAL_INFO1 ON (VW_ZEB_MERPS_PRCS_ORD_MATERIAL.PLANT_COD = VW_ZEB_MERPS_MATERIAL_INFO1.PLANT_COD) AND (VW_ZEB_MERPS_PRCS_ORD_MATERIAL.MAT_COD = VW_ZEB_MERPS_MATERIAL_INFO1.MAT_COD) 
	  LEFT JOIN ODS_DIST.VW_ZEB_MERPS_MATERIAL_BATCH VW_ZEB_MERPS_MATERIAL_BATCH ON (VW_ZEB_MERPS_PRCS_ORD_MATERIAL.PLANT_COD = VW_ZEB_MERPS_MATERIAL_BATCH.PLANT_COD) AND (VW_ZEB_MERPS_PRCS_ORD_MATERIAL.MAT_COD = VW_ZEB_MERPS_MATERIAL_BATCH.MAT_COD) AND (VW_ZEB_MERPS_PRCS_ORD_MATERIAL.BAT_NUM = VW_ZEB_MERPS_MATERIAL_BATCH.BAT_NUM)
 WHERE VW_ZEB_MERPS_PRCS_ORD_HEADER.ACTUAL_START_DT BETWEEN TO_DATE('01MAR09:00:00:00','DDMONYY:HH24:MI:SS') and TO_DATE('31MAR09:00:00:00','DDMONYY:HH24:MI:SS')
 ORDER BY VW_ZEB_MERPS_PRCS_ORD_HEADER.ACTUAL_FINISH_DT , VW_ZEB_MERPS_PRCS_ORD_HEADER.PRCS_ORD_NUM, VW_ZEB_MERPS_PRCS_ORD_MATERIAL.RESERVATION_ITEM




--  @version $Id: //product/DCS/version/10.0.3/DW/sql/xml/arf_dcs_init.xml#2 $$Change: 651448 $
-- This file contains SQL statements which will initialize theDatawarehouse tables.

BEGIN TRANSACTION
INSERT INTO ARF_CATEGORY (ID,NCATEGORY_ID,NAME,NAME_EN,DESCRIPTION,DESCRIPTION_EN,PARENT_CAT_ID,MOST_RECENT,DELETED) VALUES (0,'0','Unspecified','Unspecified', 'Unspecified','Unspecified',0,1,0)
INSERT INTO ARF_PRODUCT (ID,NPRODUCT_ID,NAME,NAME_EN,DESCRIPTION,DESCRIPTION_EN,PARENT_CAT_ID,MOST_RECENT,DELETED) VALUES (0,'0','Unspecified','Unspecified', 'Unspecified','Unspecified',0,1,0)
INSERT INTO ARF_SKU (ID,NSKU_ID,NAME,NAME_EN,DESCRIPTION,DESCRIPTION_EN,PARENT_PROD_ID,MOST_RECENT,DELETED) VALUES (0,'0','Unspecified','Unspecified', 'Unspecified','Unspecified',0,1,0)
INSERT INTO ARF_PROMOTION (ID,NPROMO_ID,PROMO_NAME,PROMO_NAME_EN,PROMO_DESC,PROMO_DESC_EN,PROMO_TYPE,MOST_RECENT,DELETED) VALUES (0,'0','Unspecified','Unspecified', 'Unspecified','Unspecified','Unspecified',1,0)
INSERT INTO ARF_PROMOGRP(ID, NAME, HASH_VALUE, LENGTH) VALUES (0,'Unspecified','0',0)
INSERT INTO ARF_PROMOGRP_MBRS (PROMOGRP_ID, PROMOTION_ID) VALUES ( 0, 0)
INSERT INTO ARF_SALES_CHANNEL (ID,NCODE,NAME,NAME_EN,DESCRIPTION,DESCRIPTION_EN) VALUES (0,999,'Unspecified','Unspecified', 'Unspecified', 'Unspecified')
INSERT INTO ARF_SALES_CHANNEL (ID,NCODE,NAME,NAME_EN,DESCRIPTION,DESCRIPTION_EN) VALUES (1,0,'Web','Web', 'Web', 'Web')
INSERT INTO ARF_SALES_CHANNEL (ID,NCODE,NAME,NAME_EN,DESCRIPTION,DESCRIPTION_EN) VALUES (2,2,'Contact Center','Contact Center', 'Contact Center', 'Contact Center')

INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (0,'Unspecified','Unspecified','Unspecified', 0)
INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (1,'incorrectItem','Incorrect Item','Incorrect Item', 0)
INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (2,'incorrectSize','Incorrect Size','Incorrect Size', 0)
INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (3,'didNotLike','Did Not Like','Did Not Like', 0)
INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (4,'defective','Defective','Defective', 0)
INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (5,'incorrectColor','Incorrect Color','Incorrect Color', 0)
INSERT INTO ARF_RET_REASON_DISPOSITION (ID,NREASON_ID,DESCRIPTION,DESCRIPTION_EN,DISPOSITION) VALUES (6,'didNotMeetExpectations','Did Not Meet Expectations','Did Not Meet Expectations', 0)

COMMIT
      


go
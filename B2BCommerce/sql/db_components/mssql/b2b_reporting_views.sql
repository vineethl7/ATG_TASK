


--  @version $Id: //product/B2BCommerce/version/10.0.3/templates/B2BCommerce/sql/b2b_reporting_views.xml#3 $$Change: 655658 $
create view drpt_dlr_org
(organization,amount)
as
             select 
	ORG.name as organization, 
	round(sum(AI.amount),2) as amount
from 	
	dcspp_order O,
	dcspp_amount_info AI,
	dps_organization ORG,
	dps_user_org DO
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.price_info = AI.amount_info_id
	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name
         
go

create view drpt_dlr_byr
(organization,buyerid,buyer,amount)
as
             select 
	ORG.name as organization, 
	DU.id as buyerid, 
   	(DU.last_name + ',' + DU.first_name) as buyer,
    	round(sum(AI.amount),2) as amount
from  	
	dcspp_order O,
    	dcspp_amount_info AI,
    	dps_user DU,
    	dps_organization ORG,
    	dps_user_org DO
where              
   	O.profile_id =DU.id
   	and DU.id = DO.user_id
   	and DO.organization = ORG.org_id
   	and O.price_info = AI.amount_info_id
   	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name,
	DU.id,
	(DU.last_name + ',' + DU.first_name)
         
go

create view drpt_dlr_org_parts
(organization,partnumber,amount)
as
             select 
	org.name as organization, 
	s.manuf_part_num as partnumber, 
	round(sum(ai.amount),2) as amount
from  	
	dcspp_order o, 
  	dps_user_org do, 
  	dcspp_item i, 
  	dbc_sku s,
  	dcspp_amount_info ai, 
  	dps_organization org
where 
  	o.profile_id = do.user_id 
  	and o.order_id = i.order_ref 
  	and do.organization=org.org_id 
  	and i.price_info = ai.amount_info_id
  	and i.catalog_ref_id = s.sku_id
  	and o.state = 'NO_PENDING_ACTION'
group by 
	org.name, 
	s.manuf_part_num
         
go

create view drpt_dlr_org_cc_i
(organization,costcenter,amount)
as
             select 
	ORG.name as organization, 
	CC.identifier as costcenter,
	round(sum(CI.amount),2) as amount
from 	
	dcspp_order O,
	dcspp_item I,
	dbcpp_ccitem_rel CI,
	dps_organization ORG,
	dps_user_org DO,
	dbcpp_cost_center CC
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.order_id = I.order_ref
	and CI.commerce_item_id = I.commerce_item_id
	and CI.cost_center_id = CC.cost_center_id	
	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name, 
	CC.identifier
         
go

create view drpt_dlr_org_cc_s
(organization,costcenter,amount)
as
             select 
	ORG.name as organization, 
	CC.identifier as costcenter,
	round(sum(CS.amount),2) as amount
from 	
	dcspp_order O,
	dcspp_ship_group SG,
	dbcpp_ccship_rel CS,
	dps_organization ORG,
	dps_user_org DO,
	dbcpp_cost_center CC
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.order_id = SG.order_ref
	and CS.shipping_group_id = SG.shipping_group_id
	and CS.cost_center_id = CC.cost_center_id
	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name, 
	CC.identifier
         
go

create view drpt_dlr_org_cc_o
(organization,costcenter,amount)
as
             select 
	ORG.name as organization, 
	CC.identifier as costcenter,
	round(sum(CO.amount),2) as amount
from 	
	dcspp_order O,
	dbcpp_ccorder_rel CO,
	dps_organization ORG,
	dps_user_org DO,
	dbcpp_cost_center CC
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.order_id = CO.order_id
	and CO.cost_center_id = CC.cost_center_id
	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name, 
	CC.identifier
         
go

create view drpt_dlr_org_cc
(organization,costcenter,amount)
as
             select 
	O.organization as organization, 
	O.costcenter as costcenter,
	(sum(I.amount) + sum(O.amount)) as amount
from 	
	drpt_dlr_org_cc_i I,
	drpt_dlr_org_cc_o O
where 
	O.organization = I.organization
	and O.costcenter = I.costcenter
group by 
	O.organization, 
	O.costcenter
UNION
select 
	I.organization as organization, 
	I.costcenter as costcenter,
	sum(I.amount) as amount
from 
	drpt_dlr_org_cc_i I
where 
	NOT EXISTS ( 	select 1 
			from drpt_dlr_org_cc_o xx 
			where 
				xx.organization = I.organization
				and xx.costcenter = I.costcenter)
group by 
	I.organization, 
	I.costcenter
UNION
select 
	O.organization as organization, 
	O.costcenter as costcenter,
	sum(O.amount) as amount
from 
	drpt_dlr_org_cc_o O
where 
	NOT EXISTS (	select 1 
			from drpt_dlr_org_cc_i xx
			where 
				xx.organization = O.organization
				and xx.costcenter = O.costcenter)
group by 
	O.organization, 
	O.costcenter
         
go

create view drpt_dlr_parts
(partnumber,amount)
as
             select 
	s.manuf_part_num as partnumber, 
	round(sum(ai.amount),2) as amount
from    
	dcspp_order o,
	dcspp_item i, 
	dbc_sku s,
	dcspp_amount_info ai
where 
  	o.order_id = i.order_ref
  	and o.state='NO_PENDING_ACTION'
  	and i.price_info = ai.amount_info_id
  	and i.catalog_ref_id = s.sku_id
group by 
	s.manuf_part_num
         
go

create view drpt_ordr_by_date
(datesubmitted,orders,totalamount)
as
             select 
	dbo.TRUNC(O.submitted_date, 'DATE') as datesubmitted,
 	count(distinct O.order_id) as orders, 
 	round(sum(ai.amount),2) as totalamount
from 
	dcspp_order O,
     	dcspp_item i, 
     	dcspp_amount_info ai
where 
	O.submitted_date is not null
  	and O.order_id = i.order_ref
  	and i.price_info = ai.amount_info_id
  	and O.state = 'NO_PENDING_ACTION'
group by
	dbo.TRUNC(O.submitted_date, 'DATE')
         
go

create view drpt_ordr_org
(organization,orders)
as
             select 
	ORG.name as organization, 
	count(*) as orders
from 	
	dcspp_order O,
	dps_organization ORG,
	dps_user_org DO
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name
         
go

create view drpt_ordr_buyr
(organization,buyerid,buyer,orders)
as
             select 
	ORG.name as organization, 
	DU.id as buyerid, 
	(DU.last_name + ',' + DU.first_name) as buyer, 
	count(*) as orders
from 	
	dcspp_order O,
	dps_user DU,
	dps_organization ORG,
	dps_user_org DO
where              
	O.profile_id =DU.id
	and DU.id = DO.user_id
	and DO.organization = ORG.org_id
	and O.state = 'NO_PENDING_ACTION'
group by 
	ORG.name, 
	DU.id, 
	(DU.last_name + ',' + DU.first_name)
         
go

create view drpt_ordr_org_cc
(organization,costcenter,orders)
as
             select 
	ORG.name as organization, 
	CC.identifier as costcenter, 
	count(*) as orders
from 	
	dcspp_order O,
	dps_organization ORG,
	dps_user_org DO,
	dbcpp_cost_center CC, 
	dbcpp_order_cc OCC
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.state = 'NO_PENDING_ACTION'
	and O.order_id = OCC.order_id
	and OCC.cost_centers = CC.cost_center_id
group by 
	ORG.name, 
	CC.identifier
         
go

create view drpt_part_purchsed
(partnumber,manufacturer)
as
             select Distinct 
	S.manuf_part_num as partnumber, 
	M.manufacturer_name as manufacturer 
from    
        dcspp_order O,
        dbc_sku S,
        dcspp_item I,
        dbc_product P,
        dbc_manufacturer M
where   
        O.state='NO_PENDING_ACTION'
        and O.order_id = I.order_ref
        and S.sku_id = I.catalog_ref_id
        and I.product_id=P.product_id
        and P.manufacturer=M.manufacturer_id
         
go



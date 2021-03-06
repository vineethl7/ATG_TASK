
-- the source for this section is 
-- das_ddl.sql


-- the source for this section is 
-- id_generator.sql





create table das_id_generator (
	id_space_name	varchar2(60)	not null,
	seed	number(19,0)	not null,
	batch_size	integer	not null,
	prefix	varchar2(10)	null,
	suffix	varchar2(10)	null
,constraint das_id_generator_p primary key (id_space_name));


create table das_secure_id_gen (
	id_space_name	varchar2(60)	not null,
	seed	number(19,0)	not null,
	batch_size	integer	not null,
	ids_per_batch	integer	null,
	prefix	varchar2(10)	null,
	suffix	varchar2(10)	null
,constraint das_secure_id_ge_p primary key (id_space_name));





-- the source for this section is 
-- cluster_name_ddl.sql





create table das_cluster_name (
	cluster_name	varchar2(255)	not null,
	saved_date	number(19)	not null);





-- the source for this section is 
-- dms_limbo_ddl.sql




-- This table is where limbo instance/clients identify themselves. --There should only be one entry in this table for each Dynamo running PatchBay with message delays enabled.

create table dms_limbo (
	limbo_name	varchar2(250)	not null,
	limbo_id	number(19,0)	not null
,constraint limbo_pk primary key (limbo_name));

-- The following four tables comprise the parts of the stored messages.

create table dms_limbo_msg (
	msg_id	number(19,0)	not null,
	limbo_id	number(19,0)	not null,
	delivery_date	number(19,0)	not null,
	delivery_count	number(2,0)	not null,
	msg_src_name	varchar2(250)	not null,
	port_name	varchar2(250)	not null,
	msg_class	varchar2(250)	not null,
	msg_class_type	number(1,0)	not null,
	jms_type	varchar2(250)	null,
	jms_expiration	number(19,0)	null,
	jms_correlationid	varchar2(250)	null
,constraint limbo_msg_pk primary key (msg_id));

create index dms_limbo_read_idx on dms_limbo_msg (limbo_id,delivery_date);
-- If serialized reply-to destinations are known to be small enough, this binary column's size can be reduced for efficiency.  The size here has been chosen to work with local dms and SQL-JMS.

create table dms_limbo_replyto (
	msg_id	number(19,0)	not null,
	jms_replyto	blob	null
,constraint limbo_replyto_pk primary key (msg_id));

-- If serialized message bodies are known to be small enough, this binary column's size can be reduced for efficiency.  The size here has been chosen to work with almost all types of messages but may be larger than necessary.  Actual usage analysis is recommended for finding the optimal binary column size.

create table dms_limbo_body (
	msg_id	number(19,0)	not null,
	msg_body	blob	null
,constraint limbo_body_pk primary key (msg_id));

-- This table represents a map of properties for messages stored above, i.e.  there can be multiple rows in this table for a single row in the preceeding tables.

create table dms_limbo_props (
	msg_id	number(19,0)	not null,
	prop_name	varchar2(250)	not null,
	prop_value	varchar2(250)	not null
,constraint limbo_props_pk primary key (msg_id,prop_name));


create table dms_limbo_ptypes (
	msg_id	number(19,0)	not null,
	prop_name	varchar2(250)	not null,
	prop_type	number(1,0)	not null
,constraint dms_limbo_ptypes_p primary key (msg_id,prop_name));


create table dms_limbo_delay (
	msg_id	number(19,0)	not null,
	delay	number(19,0)	not null,
	max_attempts	number(2,0)	not null,
	failure_port	varchar2(250)	not null,
	jms_timestamp	number(19,0)	null,
	jms_deliverymode	number(10,0)	null,
	jms_priority	number(10,0)	null,
	jms_messageid	varchar2(250)	null,
	jms_redelivered	number(1,0)	null,
	jms_destination	blob	null
,constraint limbo_delay_pk primary key (msg_id));





-- the source for this section is 
-- create_sql_jms_ddl.sql





create table dms_client (
	client_name	varchar2(250)	not null,
	client_id	number(19,0)	null
,constraint dms_client_p primary key (client_name));


create table dms_queue (
	queue_name	varchar2(250)	null,
	queue_id	number(19,0)	not null,
	temp_id	number(19,0)	null
,constraint dms_queue_p primary key (queue_id));


create table dms_queue_recv (
	client_id	number(19,0)	null,
	receiver_id	number(19,0)	not null,
	queue_id	number(19,0)	null
,constraint dms_queue_recv_p primary key (receiver_id));


create table dms_queue_entry (
	queue_id	number(19,0)	not null,
	msg_id	number(19,0)	not null,
	delivery_date	number(19,0)	null,
	handling_client_id	number(19,0)	null,
	read_state	number(19,0)	null
,constraint dms_queue_entry_p primary key (queue_id,msg_id));


create table dms_topic (
	topic_name	varchar2(250)	null,
	topic_id	number(19,0)	not null,
	temp_id	number(19,0)	null
,constraint dms_topic_p primary key (topic_id));


create table dms_topic_sub (
	client_id	number(19,0)	null,
	subscriber_name	varchar2(250)	null,
	subscriber_id	number(19,0)	not null,
	topic_id	number(19,0)	null,
	durable	number(1,0)	null,
	active	number(1,0)	null
,constraint dms_topic_sub_p primary key (subscriber_id));


create table dms_topic_entry (
	subscriber_id	number(19,0)	not null,
	msg_id	number(19,0)	not null,
	delivery_date	number(19,0)	null,
	read_state	number(19,0)	null
,constraint dms_topic_entry_p primary key (subscriber_id,msg_id));

create index dms_topic_msg_idx on dms_topic_entry (msg_id,subscriber_id);
create index dms_topic_read_idx on dms_topic_entry (read_state,delivery_date);

create table dms_msg (
	msg_class	varchar2(250)	null,
	has_properties	number(1,0)	null,
	reference_count	number(10,0)	null,
	msg_id	number(19,0)	not null,
	timestamp	number(19,0)	null,
	correlation_id	varchar2(250)	null,
	reply_to	number(19,0)	null,
	destination	number(19,0)	null,
	delivery_mode	number(1,0)	null,
	redelivered	number(1,0)	null,
	type	varchar2(250)	null,
	expiration	number(19,0)	null,
	priority	number(1,0)	null,
	small_body	blob	null,
	large_body	blob	null
,constraint dms_msg_p primary key (msg_id));


create table dms_msg_properties (
	msg_id	number(19,0)	not null,
	data_type	number(1,0)	null,
	name	varchar2(250)	not null,
	value	varchar2(250)	null
,constraint dms_msg_properti_p primary key (msg_id,name));

create or replace procedure dms_queue_flag
(Pbatch_size    IN NUMBER
,Pread_lock     IN NUMBER
,Pdelivery_date IN NUMBER
,Pclient_id     IN NUMBER
,Pqueue_id      IN NUMBER
,Pupdate_count  OUT NUMBER)
as
             Begin
    UPDATE dms_queue_entry qe
    SET qe.handling_client_id = Pclient_id, 
        qe.read_state = Pread_lock 
    WHERE ROWNUM < Pbatch_size
      AND qe.handling_client_id < 0 
      AND qe.delivery_date < Pdelivery_date 
      AND qe.queue_id = Pqueue_id;
    Pupdate_count := SQL%ROWCOUNT;
  END;
         
/

create or replace procedure dms_topic_flag
(Pbatch_size    IN NUMBER
,Pread_lock     IN NUMBER
,Pdelivery_date IN NUMBER
,Psubscriber_id IN NUMBER
,Pupdate_count  OUT NUMBER)
as
             Begin
    UPDATE dms_topic_entry te 
    SET te.read_state = Pread_lock 
    WHERE ROWNUM < Pbatch_size
      AND te.delivery_date < Pdelivery_date 
      AND te.read_state = 0 
      AND te.subscriber_id = Psubscriber_id;
    Pupdate_count := SQL%ROWCOUNT;
  END; 
         
/



-- the source for this section is 
-- create_staff_ddl.sql




-- SQL for creating the Dynamo Staff Repository for the GSA
-- Primary account table.
--  Type=1 is a login account.  The first_name, last_name, and password         fields are valid for this type of account.
-- Type=2 is a group account.  The description field is valid for        this type of account.
-- Type=4 is a privilege account.  The description field is valid for        this type of account.

create table das_account (
	account_name	varchar2(254)	not null,
	type	integer	not null,
	first_name	varchar2(254)	null,
	last_name	varchar2(254)	null,
	password	varchar2(254)	null,
	description	varchar2(254)	null,
	lastpwdupdate	date	null
,constraint das_account_p primary key (account_name));


create table das_group_assoc (
	account_name	varchar2(254)	not null,
	sequence_num	integer	not null,
	group_name	varchar2(254)	not null
,constraint das_grp_asc_p primary key (account_name,sequence_num));

-- Adding the previous password information

create table das_acct_prevpwd (
	account_name	varchar2(254)	not null,
	seq_num	number(10)	not null,
	prevpwd	varchar2(35)	null
,constraint das_prevpwd_p primary key (account_name,seq_num)
,constraint das_prvpwd_d_f foreign key (account_name) references das_account (account_name));





-- the source for this section is 
-- create_gsa_subscribers_ddl.sql





create table das_gsa_subscriber (
	id	integer	not null,
	address	varchar2(50)	not null,
	port	integer	not null,
	repository	varchar2(256)	not null,
	itemdescriptor	varchar2(256)	not null
,constraint das_gsa_subscrib_p primary key (id));





-- the source for this section is 
-- create_sds.sql





create table das_sds (
	sds_name	varchar2(50)	not null,
	curr_ds_name	varchar2(50)	null,
	dynamo_server	varchar2(80)	null,
	last_modified	date	null
,constraint das_sds_p primary key (sds_name));





-- the source for this section is 
-- integration_data_ddl.sql





create table if_integ_data (
	item_id	varchar2(40)	not null,
	descriptor	varchar2(64)	not null,
	repository	varchar2(255)	not null,
	state	number(10)	not null,
	last_import	date	null,
	version	number(10)	not null
,constraint if_int_data_p primary key (item_id,descriptor,repository));





-- the source for this section is 
-- nucleus_security_ddl.sql





create table das_nucl_sec (
	func_name	varchar2(254)	not null,
	policy	varchar2(254)	not null
,constraint func_name_pk primary key (func_name));


create table das_ns_acls (
	id	varchar2(254)	not null,
	index_num	number(10)	not null,
	acl	varchar2(254)	not null
,constraint id_index_pk primary key (id,index_num));





-- the source for this section is 
-- media_ddl.sql




--     media content repository tables.  

create table media_folder (
	folder_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	date	null,
	description	varchar2(254)	null,
	name	varchar2(254)	not null,
	path	varchar2(254)	not null,
	parent_folder_id	varchar2(40)	null
,constraint md_folder_p primary key (folder_id)
,constraint md_foldparnt_fl_f foreign key (parent_folder_id) references media_folder (folder_id));

create index fldr_mfldrid_idx on media_folder (parent_folder_id);
create index md_fldr_path_idx on media_folder (path);

create table media_base (
	media_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	date	null,
	description	varchar2(254)	null,
	name	varchar2(254)	not null,
	path	varchar2(254)	not null,
	parent_folder_id	varchar2(40)	not null,
	media_type	integer	null
,constraint media_p primary key (media_id)
,constraint medparnt_fl_f foreign key (parent_folder_id) references media_folder (folder_id));

create index med_mfldrid_idx on media_base (parent_folder_id);
create index media_path_idx on media_base (path);
create index media_type_idx on media_base (media_type);

create table media_ext (
	media_id	varchar2(40)	not null,
	url	varchar2(254)	not null
,constraint media_ext_p primary key (media_id)
,constraint medxtmed_d_f foreign key (media_id) references media_base (media_id));


create table media_bin (
	media_id	varchar2(40)	not null,
	length	integer	not null,
	last_modified	date	not null,
	data	blob	not null
,constraint media_bin_p primary key (media_id)
,constraint medbnmed_d_f foreign key (media_id) references media_base (media_id));


create table media_txt (
	media_id	varchar2(40)	not null,
	length	integer	not null,
	last_modified	date	not null,
	data	clob	not null
,constraint media_txt_p primary key (media_id)
,constraint medtxtmed_d_f foreign key (media_id) references media_base (media_id));





-- the source for this section is 
-- deployment_ddl.sql




--     These tables are for the daf deployment system  

create table das_deployment (
	deployment_id	varchar2(40)	not null,
	version	number(10)	not null,
	start_time	date	null,
	end_time	date	null,
	failure_time	date	null,
	status	number(10)	null,
	prev_status	number(10)	null,
	status_detail	varchar2(255)	null,
	current_phase	number(10)	null,
	rep_high_mark	number(10)	null,
	rep_marks_avail	number(10)	null,
	file_high_mark	number(10)	null,
	file_marks_avail	number(10)	null,
	thread_batch_size	number(10)	null,
	failure_count	number(10)	null,
	purge_deploy_data	number(1)	null
,constraint daf_depl_pk primary key (deployment_id));

create index das_dpl_start_idx on das_deployment (start_time);

create table das_depl_progress (
	deployment_id	varchar2(40)	not null,
	version	number(10)	not null,
	work_completed	number(10)	null,
	total_work	number(10)	null
,constraint daf_depl_prg_pk primary key (deployment_id));


create table das_thread_batch (
	thread_batch_id	varchar2(40)	not null,
	version	number(10)	not null,
	deployment	varchar2(40)	null,
	type	number(10)	null,
	owner	varchar2(255)	null,
	thread_name	varchar2(255)	null,
	lower_bound	number(10)	null,
	upper_bound	number(10)	null,
	last_update_time	timestamp	null,
	running	number(1,0)	not null
,constraint das_dpl_tb_pk primary key (thread_batch_id));

create index das_tb_deployment on das_thread_batch (deployment);
create index das_tb_owner on das_thread_batch (owner);
create index das_tb_thread_nam on das_thread_batch (thread_name);

create table das_deploy_data (
	deploy_data_id	varchar2(40)	not null,
	version	number(10)	not null,
	type	number(10)	null,
	source	varchar2(255)	null,
	destination	varchar2(255)	null,
	dest_server	varchar2(255)	null,
	deployment	varchar2(40)	null
,constraint deploy_data_pk primary key (deploy_data_id)
,constraint dd_deployment_fk foreign key (deployment) references das_deployment (deployment_id));

create index dd_deployment_idx on das_deploy_data (deployment);

create table das_deploy_mark (
	marker_id	varchar2(40)	not null,
	version	number(10)	not null,
	type	number(10)	null,
	status	number(10)	null,
	index_number	number(10)	null,
	marker_action	number(10)	null,
	f_src_devline_id	varchar2(40)	null,
	r_src_devline_id	varchar2(40)	null,
	deployment_id	varchar2(40)	null,
	deployment_data	varchar2(40)	null
,constraint marker_pk primary key (marker_id));

create index marker_index_idx on das_deploy_mark (index_number);

create table das_rep_mark (
	rep_marker_id	varchar2(40)	not null,
	item_desc_name	varchar2(255)	null,
	item_id	varchar2(255)	null
,constraint rep_marker_pk primary key (rep_marker_id));


create table das_file_mark (
	file_marker_id	varchar2(40)	not null,
	file_path	varchar2(1000)	null
,constraint file_marker_pk primary key (file_marker_id));


create table das_depl_depldat (
	deployment_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	deployment_data	varchar2(40)	null
,constraint das_dpl_depdat_pk primary key (deployment_id,sequence_num));


create table das_depl_options (
	deployment_id	varchar2(40)	not null,
	tag	varchar2(255)	not null,
	optionValue	varchar2(255)	null
,constraint das_dpl_depopt_pk primary key (deployment_id,tag));


create table das_depl_repmaps (
	deployment_id	varchar2(40)	not null,
	source	varchar2(255)	not null,
	destination	varchar2(255)	null
,constraint das_dpl_repmap_pk primary key (deployment_id,source));


create table das_depl_item_ref (
	item_ref_id	varchar2(40)	not null,
	version	number(10)	not null,
	deployment_id	varchar2(40)	null,
	repository	varchar2(255)	null,
	item_desc_name	varchar2(255)	null,
	item_id	varchar2(255)	null,
	item_index	number(10)	null
,constraint das_dpl_itmref_pk primary key (item_ref_id));

create index das_dpl_itmx_idx on das_depl_item_ref (item_index);
create index das_dpl_dplid_idx on das_depl_item_ref (deployment_id);

create table das_dd_markers (
	deploy_data_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	marker	varchar2(40)	null
,constraint das_dpl_dd_mrk_pk primary key (deploy_data_id,sequence_num)
,constraint marker_fk foreign key (marker) references das_deploy_mark (marker_id));

create index marker_idx on das_dd_markers (marker);

create table das_dep_fail_info (
	id	varchar2(40)	not null,
	deployment_id	varchar2(40)	not null,
	marker_id	varchar2(40)	null,
	severity	varchar2(40)	null,
	failure_message	varchar2(255)	null,
	failure_time	timestamp	null,
	error_code	varchar2(40)	null,
	cause	clob	null);





-- the source for this section is 
-- sitemap_ddl.sql




-- Table for siteindex repository item

create table das_siteindex (
	siteindex_id	varchar2(40)	not null,
	lastmod	date	null,
	filename	varchar2(100)	null,
	xml	clob	null
,constraint siteindex_pk primary key (siteindex_id));

-- Table for sitemap repository item

create table das_sitemap (
	sitemap_id	varchar2(40)	not null,
	lastmod	date	null,
	filename	varchar2(100)	null,
	xml	clob	null
,constraint sitemap_pk primary key (sitemap_id));





-- the source for this section is 
-- seo_ddl.sql




-- Table for seo-tag repository item

create table das_seo_tag (
	seo_tag_id	varchar2(40)	not null,
	display_name	varchar2(100)	null,
	title	varchar2(254)	null,
	description	varchar2(254)	null,
	keywords	varchar2(254)	null,
	content_key	varchar2(100)	null
,constraint das_seo_tag_pk primary key (seo_tag_id));


create table das_seo_sites (
	seo_tag_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint das_seo_site_pk primary key (seo_tag_id,site_id));





-- the source for this section is 
-- site_ddl.sql




-- This file contains create table statements, which will configureyour database for use MultiSite

create table site_template (
	id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	not null,
	item_mapping_id	varchar2(40)	not null
,constraint site_template1_p primary key (id));


create table site_configuration (
	id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	template	varchar2(40)	null,
	production_url	varchar2(254)	null,
	enabled	number(1)	not null,
	site_down_url	varchar2(254)	null,
	open_date	date	null,
	pre_opening_url	varchar2(254)	null,
	closing_date	date	null,
	post_closing_url	varchar2(254)	null,
	modification_time	date	null,
	creation_time	date	null,
	author	varchar2(254)	null,
	last_modified_by	varchar2(254)	null,
	site_icon	varchar2(254)	null,
	favicon	varchar2(254)	null,
	site_priority	number(10)	null,
	context_root	varchar2(254)	null
,constraint site_configurat1_p primary key (id));


create table site_additional_urls (
	id	varchar2(40)	not null,
	additional_production_url	varchar2(254)	null,
	idx	number(10)	not null
,constraint siteadditio_url1_p primary key (id,idx));


create table site_types (
	id	varchar2(40)	not null,
	site_type	varchar2(254)	not null
,constraint site_types1_p primary key (id,site_type));


create table site_group (
	id	varchar2(40)	not null,
	display_name	varchar2(254)	not null
,constraint site_group1_p primary key (id));


create table site_group_sites (
	site_id	varchar2(40)	not null,
	site_group_id	varchar2(40)	not null
,constraint site_group_sites_p primary key (site_id,site_group_id)
,constraint site_group_site1_f foreign key (site_id) references site_configuration (id)
,constraint site_group_site2_f foreign key (site_group_id) references site_group (id));

create index site_group_site1_x on site_group_sites (site_id);
create index site_group_site2_x on site_group_sites (site_group_id);

create table site_group_shareable_types (
	shareable_types	varchar2(254)	not null,
	site_group_id	varchar2(40)	not null
,constraint site_group_share_p primary key (shareable_types,site_group_id)
,constraint site_group_shar1_f foreign key (site_group_id) references site_group (id));

create index site_group_shar1_x on site_group_shareable_types (site_group_id);




-- the source for this section is 
-- dps_ddl.sql


-- the source for this section is 
-- user_ddl.sql




-- This file contains create table statements, which will configure your database for use with the new DPS schema.
-- Add the organization definition.  It's out of place, but since dps_user references it, it's got to be defined up here

create table dps_organization (
	org_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	parent_org	varchar2(40)	null
,constraint dps_organization_p primary key (org_id)
,constraint dps_orgnparnt_rg_f foreign key (parent_org) references dps_organization (org_id));

create index dps_orgparent_org on dps_organization (parent_org);
-- Default Profile User Template
-- Basic user info.  note: the password field size must be at a minimum 35 characters       if DPS stores a hash of the password and not the actual value.

create table dps_user (
	id	varchar2(40)	not null,
	login	varchar2(40)	not null,
	auto_login	number(1,0)	null,
	password	varchar2(35)	null,
	member	number(1,0)	null,
	first_name	varchar2(40)	null,
	middle_name	varchar2(40)	null,
	last_name	varchar2(40)	null,
	user_type	integer	null,
	locale	integer	null,
	lastactivity_date	timestamp	null,
	lastpwdupdate	timestamp	null,
	generatedpwd	number(1)	null,
	registration_date	timestamp	null,
	email	varchar2(255)	null,
	email_status	integer	null,
	receive_email	integer	null,
	last_emailed	timestamp	null,
	gender	integer	null,
	date_of_birth	date	null,
	securityStatus	integer	null,
	description	varchar2(254)	null
,constraint dps_user_p primary key (id)
,constraint dps_user_u unique (login)
,constraint dps_user1_c check (auto_login in (0,1))
,constraint dps_user2_c check (member in (0,1)));


create table dps_contact_info (
	id	varchar2(40)	not null,
	user_id	varchar2(40)	null,
	prefix	varchar2(40)	null,
	first_name	varchar2(100)	null,
	middle_name	varchar2(100)	null,
	last_name	varchar2(100)	null,
	suffix	varchar2(40)	null,
	job_title	varchar2(100)	null,
	company_name	varchar2(40)	null,
	address1	varchar2(50)	null,
	address2	varchar2(50)	null,
	address3	varchar2(50)	null,
	city	varchar2(30)	null,
	state	varchar2(20)	null,
	postal_code	varchar2(10)	null,
	county	varchar2(40)	null,
	country	varchar2(40)	null,
	phone_number	varchar2(30)	null,
	fax_number	varchar2(30)	null
,constraint dps_contact_info_p primary key (id));


create table dps_user_address (
	id	varchar2(40)	not null,
	home_addr_id	varchar2(40)	null,
	billing_addr_id	varchar2(40)	null,
	shipping_addr_id	varchar2(40)	null
,constraint dps_user_address_p primary key (id)
,constraint dps_usrddrssid_f foreign key (id) references dps_user (id));

create index dps_usr_adr_shp_id on dps_user_address (shipping_addr_id);
create index dps_usr_blng_ad_id on dps_user_address (billing_addr_id);
create index dps_usr_home_ad_id on dps_user_address (home_addr_id);

create table dps_other_addr (
	user_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	address_id	varchar2(40)	not null
,constraint dps_other_addr_p primary key (user_id,tag)
,constraint dps_othrddrusr_d_f foreign key (user_id) references dps_user (id));


create table dps_mailing (
	id	varchar2(40)	not null,
	name	varchar2(255)	null,
	subject	varchar2(80)	null,
	uniq_server_id	varchar2(255)	null,
	from_address	varchar2(255)	null,
	replyto	varchar2(255)	null,
	template_URL	varchar2(255)	null,
	alt_template_URL	varchar2(255)	null,
	batch_exec_id	varchar2(40)	null,
	cc	varchar2(4000)	null,
	bcc	varchar2(4000)	null,
	send_as_html	integer	null,
	send_as_text	integer	null,
	params	blob	null,
	start_time	timestamp	null,
	end_time	timestamp	null,
	status	integer	null,
	num_profiles	integer	null,
	num_sent	integer	null,
	num_bounces	integer	null,
	num_soft_bounces	integer	null,
	num_errors	integer	null,
	num_skipped	number(10)	null,
	fill_from_templ	number(1,0)	null,
	is_batched	number(1)	null,
	ignore_fatigue	number(1)	null,
	batch_size	number(10)	null
,constraint dps_mailing_p primary key (id));


create table dps_mail_trackdata (
	mailing_id	varchar2(40)	not null,
	map_key	varchar2(254)	not null,
	map_value	varchar2(254)	null
,constraint dps_mail_trackd_p primary key (mailing_id,map_key)
,constraint dps_mail_trackd_f foreign key (mailing_id) references dps_mailing (id));


create table dps_mail_batch (
	mailing_id	varchar2(40)	not null,
	start_idx	number(10)	not null,
	uniq_server_id	varchar2(254)	null,
	start_time	timestamp	null,
	end_time	timestamp	null,
	status	number(10)	null,
	num_profiles	number(10)	null,
	num_sent	number(10)	null,
	num_bounces	number(10)	null,
	num_errors	number(10)	null,
	num_skipped	number(10)	null,
	is_summarized	number(1)	null
,constraint dps_mail_batch_p primary key (mailing_id,start_idx)
,constraint dps_mailbatch_d_f foreign key (mailing_id) references dps_mailing (id));


create table dps_mail_server (
	uniq_server_id	varchar2(254)	not null,
	last_updated	timestamp	null
,constraint dps_mail_server_p primary key (uniq_server_id));


create table dps_user_mailing (
	mailing_id	varchar2(40)	not null,
	user_id	varchar2(40)	not null,
	idx	integer	not null
,constraint dps_user_mailing_p primary key (mailing_id,user_id)
,constraint dps_usrmmalng_d_f foreign key (mailing_id) references dps_mailing (id)
,constraint dps_usrmlngusr_d_f foreign key (user_id) references dps_user (id));

create index dps_u_mail_uid on dps_user_mailing (user_id);

create table dps_email_address (
	mailing_id	varchar2(40)	not null,
	email_address	varchar2(255)	not null,
	idx	integer	not null
,constraint dps_email_addres_p primary key (mailing_id,idx)
,constraint dps_emldmalng_d_f foreign key (mailing_id) references dps_mailing (id));

-- Organizations/roles

create table dps_role (
	role_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null
,constraint dps_role_p primary key (role_id));

-- Extending the user profile to include references to the roles that are assigned to this user

create table dps_user_roles (
	user_id	varchar2(40)	not null,
	atg_role	varchar2(40)	not null
,constraint dps_user_roles_p primary key (user_id,atg_role)
,constraint dps_usrrlsatg_rl_f foreign key (atg_role) references dps_role (role_id)
,constraint dps_usrrlsusr_d_f foreign key (user_id) references dps_user (id));

create index dps_usr_roles_id on dps_user_roles (atg_role);

create table dps_org_role (
	org_id	varchar2(40)	not null,
	atg_role	varchar2(40)	not null
,constraint dps_org_role_p primary key (org_id,atg_role)
,constraint dps_orgrlorg_d_f foreign key (org_id) references dps_organization (org_id)
,constraint dps_orgrlatg_rl_f foreign key (atg_role) references dps_role (role_id));

create index dps_org_rolerole on dps_org_role (atg_role);

create table dps_role_rel_org (
	organization	varchar2(40)	not null,
	sequence_num	integer	not null,
	role_id	varchar2(40)	not null
,constraint dps_role_rel_org_p primary key (organization,sequence_num)
,constraint dps_rolrorgnztn_f foreign key (organization) references dps_organization (org_id)
,constraint dps_rolrlrgrol_d_f foreign key (role_id) references dps_role (role_id));

create index dps_role_rel_org on dps_role_rel_org (role_id);

create table dps_relativerole (
	role_id	varchar2(40)	not null,
	dps_function	varchar2(40)	not null,
	relative_to	varchar2(40)	not null
,constraint dps_relativerole_p primary key (role_id)
,constraint dps_reltreltv_t_f foreign key (relative_to) references dps_organization (org_id)
,constraint dps_reltvrlrol_d_f foreign key (role_id) references dps_role (role_id));

create index dps_relativerole on dps_relativerole (relative_to);

create table dps_user_org (
	organization	varchar2(40)	not null,
	user_id	varchar2(40)	not null
,constraint dps_user_org_p primary key (organization,user_id)
,constraint dps_usrrgorgnztn_f foreign key (organization) references dps_organization (org_id)
,constraint dps_usrrgusr_d_f foreign key (user_id) references dps_user (id));

create index dps_usr_orgusr_id on dps_user_org (user_id);

create table dps_user_org_anc (
	user_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	anc_org	varchar2(40)	not null
,constraint dps_user_org_anc_p primary key (user_id,sequence_num)
,constraint dps_usrranc_rg_f foreign key (anc_org) references dps_organization (org_id)
,constraint dps_usrrgncusr_d_f foreign key (user_id) references dps_user (id));

create index dps_usr_org_ancanc on dps_user_org_anc (anc_org);

create table dps_org_chldorg (
	org_id	varchar2(40)	not null,
	child_org_id	varchar2(40)	not null
,constraint dps_org_chldorg_p primary key (org_id,child_org_id)
,constraint dps_orgcchild_rg_f foreign key (child_org_id) references dps_organization (org_id)
,constraint dps_orgcorg_d_f foreign key (org_id) references dps_organization (org_id));

create index dps_org_chldorg_id on dps_org_chldorg (child_org_id);

create table dps_org_ancestors (
	org_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	anc_org	varchar2(40)	not null
,constraint dps_org_ancestor_p primary key (org_id,sequence_num)
,constraint dps_orgnanc_rg_f foreign key (anc_org) references dps_organization (org_id)
,constraint dps_orgnorg_d_f foreign key (org_id) references dps_organization (org_id));

create index dps_org_ancanc_org on dps_org_ancestors (anc_org);
-- Adding the folder information

create table dps_folder (
	folder_id	varchar2(40)	not null,
	type	integer	not null,
	name	varchar2(254)	not null,
	parent	varchar2(40)	null,
	description	varchar2(254)	null
,constraint dps_folder_p primary key (folder_id)
,constraint dps_foldrparnt_f foreign key (parent) references dps_folder (folder_id));

create index dps_folderparent on dps_folder (parent);

create table dps_child_folder (
	folder_id	varchar2(40)	not null,
	child_folder_id	varchar2(40)	not null
,constraint dps_child_folder_p primary key (folder_id,child_folder_id)
,constraint dps_chilchild_fl_f foreign key (child_folder_id) references dps_folder (folder_id)
,constraint dps_chilfoldr_d_f foreign key (folder_id) references dps_folder (folder_id));

create index dps_chld_fldr_fld on dps_child_folder (child_folder_id);

create table dps_rolefold_chld (
	rolefold_id	varchar2(40)	not null,
	role_id	varchar2(40)	not null
,constraint dps_rolefold_chl_p primary key (rolefold_id,role_id)
,constraint dps_rolfrolfld_d_f foreign key (rolefold_id) references dps_folder (folder_id)
,constraint dps_rolfrol_d_f foreign key (role_id) references dps_role (role_id));

create index dps_rolfldchldrole on dps_rolefold_chld (role_id);
-- Adding the previous password information

create table dps_user_prevpwd (
	id	varchar2(40)	not null,
	seq_num	number(10)	not null,
	prevpwd	varchar2(35)	null
,constraint dps_prevpwd_p primary key (id,seq_num)
,constraint dps_prvpwd_d_f foreign key (id) references dps_user (id));





-- the source for this section is 
-- logging_ddl.sql




-- This file contains create table statements needed to configure your database for use with the DPS logging/reporting subsystem.This script will create tables and indexes associated with the newlogging and reporting subsystem. To initialize these tables run thelogging_init.sql script.
-- Tables for storing logging data for reports

create table dps_event_type (
	id	integer	not null,
	name	varchar2(32)	not null
,constraint dps_event_type_p primary key (id)
,constraint dps_event_type_u unique (name));


create table dps_user_event (
	id	number(19,0)	not null,
	timestamp	date	not null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	eventtype	integer	not null,
	profileid	varchar2(25)	null,
	member	number(1,0)	default 0 not null
,constraint dps_user_event_p primary key (id)
,constraint dps_usrvevnttyp_f foreign key (eventtype) references dps_event_type (id)
,constraint dps_user_event_c check (member in (0,1)));

create index dps_user_event_ix on dps_user_event (eventtype);
create index dps_ue_ts on dps_user_event (timestamp);

create table dps_user_event_sum (
	eventtype	integer	not null,
	summarycount	integer	not null,
	fromtime	date	not null,
	totime	date	not null
,constraint dps_usrsuevnttyp_f foreign key (eventtype) references dps_event_type (id));

create index dps_user_ev_sum_ix on dps_user_event_sum (eventtype);
create index dps_ues_ft on dps_user_event_sum (fromtime,totime,eventtype);

create table dps_request (
	id	number(19,0)	not null,
	timestamp	date	not null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	name	varchar2(255)	not null,
	member	number(1,0)	default 0 not null
,constraint dps_request_p primary key (id)
,constraint dps_request_c check (member in (0,1)));

create index dps_r_ts on dps_request (timestamp);

create table dps_reqname_sum (
	name	varchar2(255)	not null,
	member	number(1,0)	default 0 not null,
	summarycount	integer	not null,
	fromtime	date	not null,
	totime	date	not null
,constraint dps_reqname_sum_c check (member in (0,1)));

create index dps_rns_ft on dps_reqname_sum (fromtime,totime);

create table dps_session_sum (
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	member	number(1,0)	default 0 not null,
	summarycount	integer	not null,
	fromtime	date	not null,
	totime	date	not null
,constraint dps_session_sum_c check (member in (0,1)));

create index dps_rss_ft on dps_session_sum (fromtime,totime,sessionid);

create table dps_con_req (
	id	number(19,0)	not null,
	timestamp	date	not null,
	requestid	number(19,0)	null,
	contentid	varchar2(255)	not null
,constraint dps_con_req_p primary key (id));

create index dps_cr_ts on dps_con_req (timestamp);

create table dps_con_req_sum (
	contentid	varchar2(255)	not null,
	member	number(1,0)	default 0 not null,
	summarycount	integer	not null,
	fromtime	date	not null,
	totime	date	not null
,constraint dps_con_req_sum_c check (member in (0,1)));

create index dps_crs_ft on dps_con_req_sum (fromtime,totime);

create table dps_pgrp_req_sum (
	groupname	varchar2(64)	not null,
	contentname	varchar2(255)	not null,
	summarycount	integer	not null,
	fromtime	date	not null,
	totime	date	not null);

create index dps_prs_ft on dps_pgrp_req_sum (fromtime,totime);

create table dps_pgrp_con_sum (
	groupname	varchar2(64)	not null,
	contentname	varchar2(64)	not null,
	summarycount	integer	not null,
	fromtime	date	not null,
	totime	date	not null);

create index dps_pcs_ft on dps_pgrp_con_sum (fromtime,totime);

create table dps_log_id (
	tablename	varchar2(30)	not null,
	nextid	number(19,0)	not null
,constraint dps_log_id_p primary key (tablename));





-- the source for this section is 
-- logging_init.sql




-- This file contains SQL statements which will initialize theDPS logging/reporting tables.
-- Set names of the default user event types, and initialize the log entry id counters

	INSERT INTO dps_event_type (id, name) VALUES (0, 'newsession');
	INSERT INTO dps_event_type (id, name) VALUES (1, 'sessionexpiration');
	INSERT INTO dps_event_type (id, name) VALUES (2, 'login');
	INSERT INTO dps_event_type (id, name) VALUES (3, 'registration');
	INSERT INTO dps_event_type (id, name) VALUES (4, 'logout');
	INSERT INTO dps_log_id (tablename, nextid)
	VALUES ('dps_user_event', 0);
	INSERT INTO dps_log_id (tablename, nextid)
	VALUES ('dps_request', 0);
	INSERT INTO dps_log_id (tablename, nextid)
	VALUES ('dps_con_req', 0);
	COMMIT;
        




-- the source for this section is 
-- personalization_ddl.sql




-- This file contains create table statements needed to configure your database for personzalization assets.This script will create tables and indexes associated with the user segment list manager.

create table dps_seg_list (
	segment_list_id	varchar2(40)	not null,
	display_name	varchar2(256)	null,
	description	varchar2(1024)	null,
	folder_id	varchar2(40)	null
,constraint dps_seg_list_p primary key (segment_list_id));


create table dps_seg_list_name (
	segment_list_id	varchar2(40)	not null,
	seq	number(10)	not null,
	group_name	varchar2(256)	not null
,constraint dps_s_l_n_p primary key (segment_list_id,seq)
,constraint dps_s_l_n_f1 foreign key (segment_list_id) references dps_seg_list (segment_list_id));


create table dps_seg_list_folder (
	folder_id	varchar2(40)	not null,
	display_name	varchar2(256)	null,
	description	varchar2(1024)	null,
	parent_folder_id	varchar2(40)	null
,constraint dps_s_l_f_p primary key (folder_id)
,constraint dps_s_l_f_f1 foreign key (parent_folder_id) references dps_seg_list_folder (folder_id));

create index dps_sgmlstfldr1_x on dps_seg_list_folder (parent_folder_id);




-- the source for this section is 
-- dss_ddl.sql


-- the source for this section is 
-- das_mappers.sql





create table dss_das_event (
	id	varchar2(32)	not null,
	timestamp	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null);


create table dss_das_form (
	id	varchar2(32)	not null,
	clocktime	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	formname	varchar2(254)	null);





-- the source for this section is 
-- dps_mappers.sql





create table dss_dps_event (
	id	varchar2(32)	not null,
	timestamp	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	profileid	varchar2(25)	null,
	scenarioPathInfo	varchar2(254)	null);


create table dss_dps_page_visit (
	id	varchar2(32)	not null,
	timestamp	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	path	varchar2(255)	null,
	profileid	varchar2(25)	null);


create table dss_dps_view_item (
	id	varchar2(32)	not null,
	timestamp	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	repositoryname	varchar2(255)	null,
	folder	varchar2(255)	null,
	itemtype	varchar2(255)	null,
	repositoryid	varchar2(255)	null,
	itemdescriptor	varchar2(255)	null,
	page	varchar2(255)	null,
	profileid	varchar2(25)	null);


create table dss_dps_click (
	id	varchar2(32)	not null,
	timestamp	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	destinationpath	varchar2(255)	null,
	sourcenames	varchar2(255)	null,
	sourcepath	varchar2(255)	null,
	profileid	varchar2(25)	null);


create table dss_dps_referrer (
	id	varchar2(32)	not null,
	timestamp	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	referrerpath	varchar2(255)	null,
	referrersite	varchar2(255)	null,
	referrerpage	varchar2(255)	null,
	profileid	varchar2(25)	null);


create table dss_dps_inbound (
	id	varchar2(32)	not null,
	timestamp	date	null,
	messagesubject	varchar2(255)	null,
	originalsubject	varchar2(255)	null,
	messagefrom	varchar2(64)	null,
	messageto	varchar2(255)	null,
	messagecc	varchar2(255)	null,
	messagereplyto	varchar2(64)	null,
	receiveddate	number(19,0)	null,
	bounced	varchar2(6)	null,
	bounceemailaddr	varchar2(255)	null,
	bouncereplycode	varchar2(10)	null,
	bounceerrormess	varchar2(255)	null,
	bouncestatuscode	varchar2(10)	null);


create table dss_dps_admin_reg (
	id	varchar2(32)	not null,
	clocktime	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	adminprofileid	varchar2(25)	null,
	profileid	varchar2(25)	null);


create table dss_dps_property (
	id	varchar2(32)	not null,
	clocktime	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	propertypath	varchar2(254)	null,
	oldvalue	varchar2(254)	null,
	newvalue	varchar2(254)	null,
	changesign	varchar2(16)	null,
	changeamount	number(19,7)	null,
	changepercentage	number(19,7)	null,
	elementsadded	varchar2(254)	null,
	elementsremoved	varchar2(254)	null,
	profileid	varchar2(25)	null);


create table dss_dps_admin_prop (
	id	varchar2(32)	not null,
	clocktime	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	propertypath	varchar2(254)	null,
	oldvalue	varchar2(254)	null,
	newvalue	varchar2(254)	null,
	changesign	varchar2(16)	null,
	changeamount	number(19,7)	null,
	changepercentage	number(19,7)	null,
	elementsadded	varchar2(254)	null,
	elementsremoved	varchar2(254)	null,
	adminprofileid	varchar2(25)	null,
	profileid	varchar2(25)	null);


create table dss_dps_update (
	id	varchar2(32)	not null,
	clocktime	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	changedproperties	varchar2(4000)	null,
	oldvalues	varchar2(4000)	null,
	newvalues	varchar2(4000)	null,
	profileid	varchar2(25)	null);


create table dss_dps_admin_up (
	id	varchar2(32)	not null,
	clocktime	date	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	changedproperties	varchar2(4000)	null,
	oldvalues	varchar2(4000)	null,
	newvalues	varchar2(4000)	null,
	adminprofileid	varchar2(25)	null,
	profileid	varchar2(25)	null);


create table dps_scenario_value (
	id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	scenario_value	varchar2(100)	null
,constraint dps_scenario_val_p primary key (id,tag)
,constraint dps_scenrvlid_f foreign key (id) references dps_user (id));

create index dps_scenval_id on dps_scenario_value (id);




-- the source for this section is 
-- dss_mappers.sql





create table dss_audit_trail (
	id	varchar2(32)	not null,
	timestamp	date	null,
	label	varchar2(255)	null,
	profileid	varchar2(25)	null,
	segmentName	varchar2(254)	null,
	processName	varchar2(254)	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null);





-- the source for this section is 
-- scenario_ddl.sql





create table dss_coll_scenario (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	modification_time	number(19,0)	null,
	segment_name	varchar2(255)	null,
	creator_id	varchar2(25)	null,
	state	varchar2(16)	null
,constraint dss_coll_scenari_p primary key (id));

-- user_id references the user table but because it is a backwards referencewe cannot have a REFERENCES(dps_user) here.

create table dss_ind_scenario (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	modification_time	number(19,0)	null,
	segment_name	varchar2(255)	null,
	creator_id	varchar2(25)	null,
	state	varchar2(16)	null,
	user_id	varchar2(25)	not null
,constraint dss_ind_scenario_p primary key (id));

create index dss_indscenario1_x on dss_ind_scenario (modification_time);

create table dss_scenario_strs (
	id	varchar2(25)	not null,
	tag	varchar2(25)	not null,
	context_str	varchar2(255)	null
,constraint dss_scenario_str_p primary key (id,tag)
,constraint dss_scenrstrsid_f foreign key (id) references dss_ind_scenario (id));

create index dss_scn_st_idx on dss_scenario_strs (id);

create table dss_scenario_bools (
	id	varchar2(25)	not null,
	tag	varchar2(25)	not null,
	context_bool	number(1,0)	null
,constraint dss_scenario_boo_p primary key (id,tag)
,constraint dss_scenrblsid_f foreign key (id) references dss_ind_scenario (id));

create index dss_scn_bo_idx on dss_scenario_bools (id);

create table dss_scenario_longs (
	id	varchar2(25)	not null,
	tag	varchar2(25)	not null,
	context_long	number(19,0)	null
,constraint dss_scenario_lon_p primary key (id,tag)
,constraint dss_scenrlngsid_f foreign key (id) references dss_ind_scenario (id));

create index dss_scn_lg_idx on dss_scenario_longs (id);

create table dss_scenario_dbls (
	id	varchar2(25)	not null,
	tag	varchar2(25)	not null,
	context_dbl	number(15,4)	null
,constraint dss_scenario_dbl_p primary key (id,tag)
,constraint dss_scenrdblsid_f foreign key (id) references dss_ind_scenario (id));

create index dss_scn_db_idx on dss_scenario_dbls (id);

create table dss_scenario_dates (
	id	varchar2(25)	not null,
	tag	varchar2(25)	not null,
	context_date	date	null
,constraint dss_scenario_dat_p primary key (id,tag)
,constraint dss_scenrdtsid_f foreign key (id) references dss_ind_scenario (id));

create index dss_scn_dt_idx on dss_scenario_dates (id);

create table dps_user_scenario (
	id	varchar2(40)	not null,
	ind_scenario_id	varchar2(25)	not null
,constraint dps_user_scenari_p primary key (ind_scenario_id)
,constraint dps_usrscnrid_f foreign key (id) references dps_user (id)
,constraint dps_usrsind_scnr_f foreign key (ind_scenario_id) references dss_ind_scenario (id));

create index dps_uscn_u_idx on dps_user_scenario (id);

create table dss_scenario_info (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	scenario_status	integer	null,
	modification_time	number(19,0)	null,
	creation_time	number(19,0)	null,
	author	varchar2(254)	null,
	last_modified_by	varchar2(254)	null,
	sdl	blob	null,
	psm_version	number(10)	null
,constraint dss_scenario_inf_p primary key (id));


create table dss_scen_mig_info (
	id	varchar2(25)	not null,
	scenario_info_id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	modification_time	number(19,0)	null,
	psm_version	number(10)	null,
	sdl	blob	null,
	migration_status	number(10)	null
,constraint dss_scenmiginfo_pk primary key (id)
,constraint dss_scenmiginfo_fk foreign key (scenario_info_id) references dss_scenario_info (id));

create index dss_scenmiginfo_id on dss_scen_mig_info (scenario_info_id);

create table dss_mig_info_seg (
	id	varchar2(25)	not null,
	idx	integer	not null,
	segment_name	varchar2(255)	null
,constraint dss_mig_infoseg_pk primary key (id,idx)
,constraint dss_mig_infoseg_fk foreign key (id) references dss_scen_mig_info (id));


create table dss_template_info (
	id	varchar2(25)	not null,
	template_name	varchar2(255)	null,
	modification_time	number(19,0)	null,
	creation_time	number(19,0)	null,
	author	varchar2(254)	null,
	last_modified_by	varchar2(254)	null,
	sdl	blob	null
,constraint dss_template_inf_p primary key (id));


create table dss_coll_trans (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	modification_time	number(19,0)	null,
	server_id	varchar2(40)	null,
	message_bean	blob	null,
	event_type	varchar2(255)	null,
	segment_name	varchar2(255)	null,
	state	varchar2(16)	null,
	coll_scenario_id	varchar2(25)	null,
	step	integer	null,
	current_count	integer	null,
	last_query_id	varchar2(25)	null
,constraint dss_coll_trans_p primary key (id)
,constraint dss_collcoll_scn_f foreign key (coll_scenario_id) references dss_coll_scenario (id));

create index dss_ctrcid_idx on dss_coll_trans (coll_scenario_id);

create table dss_ind_trans (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	modification_time	number(19,0)	null,
	server_id	varchar2(40)	null,
	message_bean	blob	null,
	event_type	varchar2(255)	null,
	segment_name	varchar2(255)	null,
	state	varchar2(16)	null,
	last_query_id	varchar2(25)	null
,constraint dss_ind_trans_p primary key (id));


create table dss_deletion (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	modification_time	number(19,0)	null
,constraint dss_deletion_p primary key (id));


create table dss_server_id (
	server_id	varchar2(40)	not null,
	server_type	integer	not null
,constraint dss_server_id_p primary key (server_id));


create table dss_del_seg_name (
	id	varchar2(25)	not null,
	idx	integer	not null,
	segment_name	varchar2(255)	null
,constraint dss_del_seg_name_p primary key (id,idx));

-- migration_info_id references the migration info table, but we don't have aREFERENCES dss_scen_mig_info(id) here, because we want to be ableto delete the migration info without deleting this row

create table dss_migration (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	old_mod_time	number(19,0)	null,
	new_mod_time	number(19,0)	null,
	migration_info_id	varchar2(25)	null
,constraint dss_migration_pk primary key (id));


create table dss_mig_seg_name (
	id	varchar2(25)	not null,
	idx	number(10)	not null,
	segment_name	varchar2(255)	null
,constraint dss_mig_segname_pk primary key (id,idx)
,constraint dss_mig_segname_fk foreign key (id) references dss_migration (id));


create table dss_xref (
	id	varchar2(25)	not null,
	scenario_name	varchar2(255)	null,
	reference_type	varchar2(30)	null,
	reference_target	varchar2(255)	null
,constraint dss_xref_p primary key (id));

-- user_id references the user table but because it is a backwards referencewe cannot have a REFERENCES(dps_user) here.

create table dss_profile_slot (
	id	varchar2(25)	not null,
	slot_name	varchar2(255)	null,
	item_offset	number(19,0)	null,
	user_id	varchar2(25)	not null
,constraint dss_profile_slot_p primary key (id));


create table dps_user_slot (
	id	varchar2(40)	not null,
	profile_slot_id	varchar2(25)	not null
,constraint dps_user_slot_p primary key (id,profile_slot_id)
,constraint dps_usrsltid_f foreign key (id) references dps_user (id)
,constraint dps_usrsprofl_sl_f foreign key (profile_slot_id) references dss_profile_slot (id));

create index dps_usr_sltprfl_id on dps_user_slot (profile_slot_id);

create table dss_slot_items (
	slot_id	varchar2(25)	not null,
	item_id	varchar2(255)	null,
	idx	integer	not null
,constraint dss_slot_items_p primary key (slot_id,idx)
,constraint dss_slotslot_d_f foreign key (slot_id) references dss_profile_slot (id));


create table dss_slot_priority (
	slot_id	varchar2(25)	not null,
	idx	integer	not null,
	priority	number(19,0)	not null
,constraint dss_slot_priorit_p primary key (slot_id,idx)
,constraint dss_slotpslot_d_f foreign key (slot_id) references dss_profile_slot (id));





-- the source for this section is 
-- markers_ddl.sql





create table dps_markers (
	marker_id	varchar2(40)	not null,
	marker_key	varchar2(100)	not null,
	marker_value	varchar2(100)	null,
	marker_data	varchar2(100)	null,
	creation_date	timestamp	null,
	version	number(10)	not null,
	marker_type	number(10)	null
,constraint dps_markers_p primary key (marker_id));


create table dps_usr_markers (
	profile_id	varchar2(40)	not null,
	marker_id	varchar2(40)	not null,
	sequence_num	number(10)	not null
,constraint dps_usr_markers_p primary key (profile_id,sequence_num)
,constraint dpsusrmarkers_u_f foreign key (profile_id) references dps_user (id)
,constraint dpsusrmarkers_m_f foreign key (marker_id) references dps_markers (marker_id));

create index dpsusrmarkers1_ix on dps_usr_markers (marker_id);




-- the source for this section is 
-- business_process_rpt_ddl.sql





create table drpt_stage_reached (
	id	varchar2(40)	not null,
	owner_id	varchar2(40)	not null,
	process_start_time	date	not null,
	event_time	date	not null,
	bp_name	varchar2(255)	not null,
	bp_stage	varchar2(255)	null,
	is_transient	number(1,0)	not null,
	bp_stage_sequence	number(10)	not null
,constraint drpt_bpstage_c check (is_transient in (0,1)));





-- the source for this section is 
-- profile_bp_markers_ddl.sql





create table dss_user_bpmarkers (
	marker_id	varchar2(40)	not null,
	profile_id	varchar2(40)	not null,
	marker_key	varchar2(100)	not null,
	marker_value	varchar2(100)	null,
	marker_data	varchar2(100)	null,
	creation_date	timestamp	null,
	version	number(10)	not null,
	marker_type	number(10)	null
,constraint dssprofilebp_p primary key (marker_id,profile_id));





-- the source for this section is 
-- commerce_user.sql





create table dps_credit_card (
	id	varchar2(40)	not null,
	credit_card_number	varchar2(40)	null,
	credit_card_type	varchar2(40)	null,
	expiration_month	varchar2(20)	null,
	exp_day_of_month	varchar2(20)	null,
	expiration_year	varchar2(20)	null,
	billing_addr	varchar2(40)	null
,constraint dps_credit_card_p primary key (id));

create index dps_crcdba_idx on dps_credit_card (billing_addr);

create table dcs_user (
	user_id	varchar2(40)	not null,
	allow_partial_ship	number(1,0)	null,
	default_creditcard	varchar2(40)	null,
	daytime_phone_num	varchar2(30)	null,
	express_checkout	number(1,0)	null,
	default_carrier	varchar2(256)	null,
	price_list	varchar2(40)	null,
	sale_price_list	varchar2(40)	null
,constraint dcs_user_p primary key (user_id)
,constraint dcs_usrdeflt_cr_f foreign key (default_creditcard) references dps_credit_card (id)
,constraint dcs_user1_c check (allow_partial_ship in (0,1))
,constraint dcs_user2_c check (express_checkout in (0,1)));

create index dcs_usrdcc_idx on dcs_user (default_creditcard);

create table dps_usr_creditcard (
	user_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	credit_card_id	varchar2(40)	not null
,constraint dps_usr_creditca_p primary key (user_id,tag)
,constraint dps_usrccredt_cr_f foreign key (credit_card_id) references dps_credit_card (id)
,constraint dps_usrcusr_d_f foreign key (user_id) references dps_user (id));

create index dps_ucccid_idx on dps_usr_creditcard (credit_card_id);
create index dps_uccuid_idx on dps_usr_creditcard (user_id);




-- the source for this section is 
-- product_catalog_ddl.sql





create table dcs_folder (
	folder_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	description	varchar2(254)	null,
	name	varchar2(254)	not null,
	path	varchar2(254)	not null,
	parent_folder_id	varchar2(40)	null
,constraint dcs_folder_p primary key (folder_id)
,constraint dcs_foldparnt_fl_f foreign key (parent_folder_id) references dcs_folder (folder_id));

create index fldr_pfldrid_idx on dcs_folder (parent_folder_id);
create index fldr_end_dte_idx on dcs_folder (end_date);
create index fldr_path_idx on dcs_folder (path);
create index fldr_strt_dte_idx on dcs_folder (start_date);

create table dcs_media (
	media_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	description	varchar2(254)	null,
	name	varchar2(254)	not null,
	path	varchar2(254)	not null,
	parent_folder_id	varchar2(40)	not null,
	media_type	integer	null
,constraint dcs_media_p primary key (media_id)
,constraint dcs_medparnt_fl_f foreign key (parent_folder_id) references dcs_folder (folder_id));

create index med_pfldrid_idx on dcs_media (parent_folder_id);
create index med_end_dte_idx on dcs_media (end_date);
create index med_path_idx on dcs_media (path);
create index med_strt_dte_idx on dcs_media (start_date);
create index med_type_idx on dcs_media (media_type);

create table dcs_media_ext (
	media_id	varchar2(40)	not null,
	url	varchar2(254)	not null
,constraint dcs_media_ext_p primary key (media_id)
,constraint dcs_medxtmed_d_f foreign key (media_id) references dcs_media (media_id));


create table dcs_media_bin (
	media_id	varchar2(40)	not null,
	length	integer	not null,
	last_modified	timestamp	not null,
	data	blob	not null
,constraint dcs_media_bin_p primary key (media_id)
,constraint dcs_medbnmed_d_f foreign key (media_id) references dcs_media (media_id));


create table dcs_media_txt (
	media_id	varchar2(40)	not null,
	length	integer	not null,
	last_modified	timestamp	not null,
	data	clob	not null
,constraint dcs_media_txt_p primary key (media_id)
,constraint dcs_medtxtmed_d_f foreign key (media_id) references dcs_media (media_id));


create table dcs_category (
	category_id	varchar2(40)	not null,
	version	integer	not null,
	catalog_id	varchar2(40)	null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	parent_cat_id	varchar2(40)	null,
	category_type	integer	null,
	root_category	number(1,0)	null
,constraint dcs_category_p primary key (category_id)
,constraint dcs_category_c check (root_category in (0,1)));

create index cat_end_dte_idx on dcs_category (end_date);
create index cat_pcatid_idx on dcs_category (parent_cat_id);
create index cat_strt_dte_idx on dcs_category (start_date);
create index cat_type_idx on dcs_category (category_type);

create table dcs_category_acl (
	category_id	varchar2(40)	not null,
	item_acl	varchar2(1024)	null
,constraint dcs_category_acl_p primary key (category_id));


create table dcs_product (
	product_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	parent_cat_id	varchar2(40)	null,
	product_type	integer	null,
	admin_display	varchar2(254)	null,
	nonreturnable	number(1,0)	null,
	brand	varchar2(254)	null,
	disallow_recommend	number(1,0)	null
,constraint dcs_product_p primary key (product_id)
,constraint dcs_product_c check (nonreturnable in (0,1))
,constraint dcs_product1_c check (disallow_recommend in (0,1)));

create index prd_end_dte_idx on dcs_product (end_date);
create index prd_pcatid_idx on dcs_product (parent_cat_id);
create index prd_strt_dte_idx on dcs_product (start_date);
create index prd_type_idx on dcs_product (product_type);

create table dcs_product_acl (
	product_id	varchar2(40)	not null,
	item_acl	varchar2(1024)	null
,constraint dcs_product_acl_p primary key (product_id));


create table dcs_sku (
	sku_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	sku_type	integer	null,
	wholesale_price	number(19,7)	null,
	list_price	number(19,7)	null,
	sale_price	number(19,7)	null,
	on_sale	number(1,0)	null,
	tax_status	integer	null,
	fulfiller	integer	null,
	item_acl	varchar2(1024)	null,
	nonreturnable	number(1,0)	null
,constraint dcs_sku_p primary key (sku_id)
,constraint dcs_sku_c check (on_sale in (0,1))
,constraint dcs_sku1_c check (nonreturnable in (0,1)));

create index sku_end_dte_idx on dcs_sku (end_date);
create index sku_lstprice_idx on dcs_sku (list_price);
create index sku_sleprice_idx on dcs_sku (sale_price);
create index sku_strt_dte_idx on dcs_sku (start_date);
create index sku_type_idx on dcs_sku (sku_type);

create table dcs_cat_groups (
	category_id	varchar2(40)	not null,
	child_prd_group	varchar2(254)	null,
	child_cat_group	varchar2(254)	null,
	related_cat_group	varchar2(254)	null
,constraint dcs_cat_groups_p primary key (category_id)
,constraint dcs_catgcatgry_d_f foreign key (category_id) references dcs_category (category_id));


create table dcs_cat_chldprd (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	child_prd_id	varchar2(40)	not null
,constraint dcs_cat_chldprd_p primary key (category_id,sequence_num)
,constraint dcs_catccatgry_d_f foreign key (category_id) references dcs_category (category_id)
,constraint dcs_catcchild_pr_f foreign key (child_prd_id) references dcs_product (product_id));

create index ct_chldprd_cpi_idx on dcs_cat_chldprd (child_prd_id);
create index ct_chldprd_cid_idx on dcs_cat_chldprd (category_id);

create table dcs_cat_chldcat (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	child_cat_id	varchar2(40)	not null
,constraint dcs_cat_chldcat_p primary key (category_id,sequence_num)
,constraint dcs_catcchild_ct_f foreign key (child_cat_id) references dcs_category (category_id)
,constraint dcs_chlccatgry_d_f foreign key (category_id) references dcs_category (category_id));

create index ct_chldcat_cci_idx on dcs_cat_chldcat (child_cat_id);
create index ct_chldcat_cid_idx on dcs_cat_chldcat (category_id);

create table dcs_cat_ancestors (
	category_id	varchar2(40)	not null,
	anc_cat_id	varchar2(40)	not null
,constraint dcs_cat_ancestor_p primary key (category_id,anc_cat_id));

create index dcs_ct_anc_cat_id on dcs_cat_ancestors (anc_cat_id);
create index dcs_ct_cat_id on dcs_cat_ancestors (category_id);

create table dcs_cat_rltdcat (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	related_cat_id	varchar2(40)	not null
,constraint dcs_cat_rltdcat_p primary key (category_id,sequence_num)
,constraint dcs_catrcatgry_d_f foreign key (category_id) references dcs_category (category_id)
,constraint dcs_catrreltd_ct_f foreign key (related_cat_id) references dcs_category (category_id));

create index ct_rltdcat_rci_idx on dcs_cat_rltdcat (related_cat_id);
create index ct_rltdcat_cid_idx on dcs_cat_rltdcat (category_id);

create table dcs_cat_keywrds (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	keyword	varchar2(254)	not null
,constraint dcs_cat_keywrds_p primary key (category_id,sequence_num)
,constraint dcs_catkcatgry_d_f foreign key (category_id) references dcs_category (category_id));

create index cat_keywrds_idx on dcs_cat_keywrds (keyword);
create index ct_keywrds_cid_idx on dcs_cat_keywrds (category_id);

create table dcs_cat_media (
	category_id	varchar2(40)	not null,
	template_id	varchar2(40)	null,
	thumbnail_image_id	varchar2(40)	null,
	small_image_id	varchar2(40)	null,
	large_image_id	varchar2(40)	null
,constraint dcs_cat_media_p primary key (category_id)
,constraint dcs_catmcatgry_d_f foreign key (category_id) references dcs_category (category_id)
,constraint dcs_catmlarg_mgd_f foreign key (large_image_id) references dcs_media (media_id)
,constraint dcs_catmsmall_mg_f foreign key (small_image_id) references dcs_media (media_id)
,constraint dcs_catmtemplt_d_f foreign key (template_id) references dcs_media (media_id)
,constraint dcs_catmthumbnl__f foreign key (thumbnail_image_id) references dcs_media (media_id));

create index ct_mdia_lrimid_idx on dcs_cat_media (large_image_id);
create index ct_mdia_smimid_idx on dcs_cat_media (small_image_id);
create index ct_mdia_tmplid_idx on dcs_cat_media (template_id);
create index ct_mdia_thimid_idx on dcs_cat_media (thumbnail_image_id);

create table dcs_cat_aux_media (
	category_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	media_id	varchar2(40)	not null
,constraint dcs_cat_aux_medi_p primary key (category_id,tag)
,constraint dcs_catxcatgry_d_f foreign key (category_id) references dcs_category (category_id)
,constraint dcs_catxmdmed_d_f foreign key (media_id) references dcs_media (media_id));

create index ct_aux_mdia_mi_idx on dcs_cat_aux_media (media_id);
create index ct_aux_mdia_ci_idx on dcs_cat_aux_media (category_id);

create table dcs_prd_keywrds (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	keyword	varchar2(254)	not null
,constraint dcs_prd_keywrds_p primary key (product_id,sequence_num)
,constraint dcs_prdkprodct_d_f foreign key (product_id) references dcs_product (product_id));

create index prd_keywrds_idx on dcs_prd_keywrds (keyword);
create index pr_keywrds_pid_idx on dcs_prd_keywrds (product_id);

create table dcs_prd_media (
	product_id	varchar2(40)	not null,
	template_id	varchar2(40)	null,
	thumbnail_image_id	varchar2(40)	null,
	small_image_id	varchar2(40)	null,
	large_image_id	varchar2(40)	null
,constraint dcs_prd_media_p primary key (product_id)
,constraint dcs_prdmlarg_mgd_f foreign key (large_image_id) references dcs_media (media_id)
,constraint dcs_prdmsmall_mg_f foreign key (small_image_id) references dcs_media (media_id)
,constraint dcs_prdmtemplt_d_f foreign key (template_id) references dcs_media (media_id)
,constraint dcs_prdmthumbnl__f foreign key (thumbnail_image_id) references dcs_media (media_id)
,constraint dcs_prdmprodct_d_f foreign key (product_id) references dcs_product (product_id));

create index pr_mdia_lrimid_idx on dcs_prd_media (large_image_id);
create index pr_mdia_smimid_idx on dcs_prd_media (small_image_id);
create index pr_mdia_tmplid_idx on dcs_prd_media (template_id);
create index pr_mdia_thimid_idx on dcs_prd_media (thumbnail_image_id);

create table dcs_prd_aux_media (
	product_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	media_id	varchar2(40)	not null
,constraint dcs_prd_aux_medi_p primary key (product_id,tag)
,constraint dcs_prdaxmdmed_d_f foreign key (media_id) references dcs_media (media_id)
,constraint dcs_prdaprodct_d_f foreign key (product_id) references dcs_product (product_id));

create index pr_aux_mdia_mi_idx on dcs_prd_aux_media (media_id);
create index pr_aux_mdia_pi_idx on dcs_prd_aux_media (product_id);

create table dcs_prd_chldsku (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	sku_id	varchar2(40)	not null
,constraint dcs_prd_chldsku_p primary key (product_id,sequence_num)
,constraint dcs_prdcprodct_d_f foreign key (product_id) references dcs_product (product_id)
,constraint dcs_prdcsku_d_f foreign key (sku_id) references dcs_sku (sku_id));

create index pr_chldsku_sid_idx on dcs_prd_chldsku (sku_id);
create index pr_chldsku_pid_idx on dcs_prd_chldsku (product_id);

create table dcs_prd_skuattr (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	attribute_name	varchar2(40)	not null
,constraint dcs_prd_skuattr_p primary key (product_id,sequence_num)
,constraint dcs_prdsprodct_d_f foreign key (product_id) references dcs_product (product_id));

create index pr_skuattr_pid_idx on dcs_prd_skuattr (product_id);

create table dcs_prd_groups (
	product_id	varchar2(40)	not null,
	related_prd_group	varchar2(254)	null,
	upsl_prd_group	varchar2(254)	null
,constraint dcs_prd_groups_p primary key (product_id)
,constraint dcs_prdgprodct_d_f foreign key (product_id) references dcs_product (product_id));


create table dcs_prd_rltdprd (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	related_prd_id	varchar2(40)	not null
,constraint dcs_prd_rltdprd_p primary key (product_id,sequence_num)
,constraint dcs_prdrprodct_d_f foreign key (product_id) references dcs_product (product_id)
,constraint dcs_prdrreltd_pr_f foreign key (related_prd_id) references dcs_product (product_id));

create index pr_rltdprd_rpi_idx on dcs_prd_rltdprd (related_prd_id);
create index pr_rltdprd_pid_idx on dcs_prd_rltdprd (product_id);

create table dcs_prd_upslprd (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	upsell_prd_id	varchar2(40)	not null
,constraint dcs_prd_upslprd_p primary key (product_id,sequence_num)
,constraint dcs_prduprodct_d_f foreign key (product_id) references dcs_product (product_id)
,constraint dcs_prdureltd_pr_f foreign key (upsell_prd_id) references dcs_product (product_id));

create index pr_upslprd_upi_idx on dcs_prd_upslprd (upsell_prd_id);

create table dcs_prd_ancestors (
	product_id	varchar2(40)	not null,
	anc_cat_id	varchar2(40)	not null
,constraint dcs_prd_ancestor_p primary key (product_id,anc_cat_id));

create index dcs_prd_anc_cat_id on dcs_prd_ancestors (anc_cat_id);
create index dcs_prd_prd_id on dcs_prd_ancestors (product_id);

create table dcs_sku_attr (
	sku_id	varchar2(40)	not null,
	attribute_name	varchar2(42)	not null,
	attribute_value	varchar2(254)	not null
,constraint dcs_sku_attr_p primary key (sku_id,attribute_name)
,constraint dcs_skuttrsku_d_f foreign key (sku_id) references dcs_sku (sku_id));

create index sku_attr_skuid_idx on dcs_sku_attr (sku_id);

create table dcs_sku_link (
	sku_link_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	quantity	integer	not null,
	bundle_item	varchar2(40)	not null,
	item_acl	varchar2(1024)	null
,constraint dcs_sku_link_p primary key (sku_link_id)
,constraint dcs_skulbundl_tm_f foreign key (bundle_item) references dcs_sku (sku_id));

create index sk_link_bndlid_idx on dcs_sku_link (bundle_item);
create index skl_end_dte_idx on dcs_sku_link (end_date);
create index skl_strt_dte_idx on dcs_sku_link (start_date);

create table dcs_sku_bndllnk (
	sku_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	sku_link_id	varchar2(40)	not null
,constraint dcs_sku_bndllnk_p primary key (sku_id,sequence_num)
,constraint dcs_skubsku_d_f foreign key (sku_id) references dcs_sku (sku_id)
,constraint dcs_skubsku_lnkd_f foreign key (sku_link_id) references dcs_sku_link (sku_link_id));

create index sk_bndllnk_sli_idx on dcs_sku_bndllnk (sku_link_id);
create index sk_bndllnk_sid_idx on dcs_sku_bndllnk (sku_id);

create table dcs_sku_media (
	sku_id	varchar2(40)	not null,
	template_id	varchar2(40)	null,
	thumbnail_image_id	varchar2(40)	null,
	small_image_id	varchar2(40)	null,
	large_image_id	varchar2(40)	null
,constraint dcs_sku_media_p primary key (sku_id)
,constraint dcs_skumlarg_mgd_f foreign key (large_image_id) references dcs_media (media_id)
,constraint dcs_skumsmall_mg_f foreign key (small_image_id) references dcs_media (media_id)
,constraint dcs_skumtemplt_d_f foreign key (template_id) references dcs_media (media_id)
,constraint dcs_skumthumbnl__f foreign key (thumbnail_image_id) references dcs_media (media_id)
,constraint dcs_skumdsku_d_f foreign key (sku_id) references dcs_sku (sku_id));

create index sk_mdia_lrimid_idx on dcs_sku_media (large_image_id);
create index sk_mdia_smimid_idx on dcs_sku_media (small_image_id);
create index sk_mdia_tmplid_idx on dcs_sku_media (template_id);
create index sk_mdia_thimid_idx on dcs_sku_media (thumbnail_image_id);

create table dcs_sku_aux_media (
	sku_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	media_id	varchar2(40)	not null
,constraint dcs_sku_aux_medi_p primary key (sku_id,tag)
,constraint dcs_skuxmdmed_d_f foreign key (media_id) references dcs_media (media_id)
,constraint dcs_skuxmdsku_d_f foreign key (sku_id) references dcs_sku (sku_id));

create index sk_aux_mdia_mi_idx on dcs_sku_aux_media (media_id);
create index sk_aux_mdia_si_idx on dcs_sku_aux_media (sku_id);

create table dcs_sku_replace (
	sku_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	replacement	varchar2(40)	not null
,constraint dcs_sku_replace_p primary key (sku_id,sequence_num)
,constraint dcs_skurplcsku_d_f foreign key (sku_id) references dcs_sku (sku_id));

create index sk_replace_sid_idx on dcs_sku_replace (sku_id);

create table dcs_sku_conf (
	sku_id	varchar2(40)	not null,
	config_props	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcs_sku_conf_p primary key (sku_id,sequence_num)
,constraint dcs_skucnfsku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table dcs_config_prop (
	config_prop_id	varchar2(40)	not null,
	version	integer	not null,
	display_name	varchar2(40)	null,
	description	varchar2(255)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_config_prop_p primary key (config_prop_id));


create table dcs_conf_options (
	config_prop_id	varchar2(40)	not null,
	config_options	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcs_conf_options_p primary key (config_prop_id,sequence_num)
,constraint dcs_confconfg_pr_f foreign key (config_prop_id) references dcs_config_prop (config_prop_id));


create table dcs_config_opt (
	config_opt_id	varchar2(40)	not null,
	version	integer	not null,
	display_name	varchar2(40)	null,
	description	varchar2(255)	null,
	sku	varchar2(40)	null,
	product	varchar2(40)	null,
	price	number(19,7)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_config_opt_p primary key (config_opt_id));

create index ct_conf_prod_idx on dcs_config_opt (product);
create index ct_conf_sku_idx on dcs_config_opt (sku);

create table dcs_foreign_cat (
	catalog_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	name	varchar2(100)	null,
	description	varchar2(255)	null,
	host	varchar2(100)	null,
	port	integer	null,
	base_url	varchar2(255)	null,
	return_url	varchar2(255)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_foreign_cat_p primary key (catalog_id));





-- the source for this section is 
-- inventory_ddl.sql





create table dcs_inventory (
	inventory_id	varchar2(40)	not null,
	version	integer	not null,
	inventory_lock	varchar2(20)	null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	catalog_ref_id	varchar2(40)	not null,
	avail_status	integer	not null,
	availability_date	timestamp	null,
	stock_level	integer	null,
	backorder_level	integer	null,
	preorder_level	integer	null,
	stock_thresh	integer	null,
	backorder_thresh	integer	null,
	preorder_thresh	integer	null
,constraint dcs_inventory_p primary key (inventory_id)
,constraint inv_catrefid_idx unique (catalog_ref_id));

create index inv_end_dte_idx on dcs_inventory (end_date);
create index inv_strt_dte_idx on dcs_inventory (start_date);




-- the source for this section is 
-- promotion_ddl.sql




-- Add the DCS_PRM_FOLDER table, promotionFolder

create table dcs_prm_folder (
	folder_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	parent_folder	varchar2(40)	null
,constraint dcs_prm_folder_p primary key (folder_id)
,constraint dcs_prm_prntfol_f foreign key (parent_folder) references dcs_prm_folder (folder_id));

create index prm_prntfol_idx on dcs_prm_folder (parent_folder);

create table dcs_promotion (
	promotion_id	varchar2(40)	not null,
	version	integer	not null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	promotion_type	integer	null,
	enabled	number(1,0)	null,
	begin_usable	timestamp	null,
	end_usable	timestamp	null,
	priority	integer	null,
	global	number(1,0)	null,
	anon_profile	number(1,0)	null,
	allow_multiple	number(1,0)	null,
	uses	integer	null,
	rel_expiration	number(1,0)	null,
	time_until_expire	integer	null,
	template	varchar2(254)	null,
	ui_access_lvl	integer	null,
	parent_folder	varchar2(40)	null,
	last_modified	timestamp	null,
	pmdl_version	integer	null,
	qualifier	varchar2(254)	null
,constraint dcs_promotion_p primary key (promotion_id)
,constraint dcs_prm_fol_f foreign key (parent_folder) references dcs_prm_folder (folder_id)
,constraint dcs_promotion1_c check (enabled in (0,1))
,constraint dcs_promotion2_c check (global in (0,1))
,constraint dcs_promotion3_c check (anon_profile in (0,1))
,constraint dcs_promotion4_c check (allow_multiple in (0,1))
,constraint dcs_promotion5_c check (rel_expiration in (0,1)));

create index promo_folder_idx on dcs_promotion (parent_folder);
create index prmo_bgin_use_idx on dcs_promotion (begin_usable);
create index prmo_end_dte_idx on dcs_promotion (end_date);
create index prmo_end_use_idx on dcs_promotion (end_usable);
create index prmo_strt_dte_idx on dcs_promotion (start_date);

create table dcs_promo_media (
	promotion_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	media_id	varchar2(40)	not null
,constraint dcs_promo_media_p primary key (promotion_id,tag)
,constraint dcs_prommdmed_d_f foreign key (media_id) references dcs_media (media_id)
,constraint dcs_prompromtn_d_f foreign key (promotion_id) references dcs_promotion (promotion_id));

create index promo_mdia_mid_idx on dcs_promo_media (media_id);
create index promo_mdia_pid_idx on dcs_promo_media (promotion_id);

create table dcs_discount_promo (
	promotion_id	varchar2(40)	not null,
	calculator	varchar2(254)	null,
	adjuster	number(19,7)	null,
	pmdl_rule	clob	not null,
	one_use	number(1,0)	null
,constraint dcs_discount_pro_p primary key (promotion_id)
,constraint dcs_discpromtn_d_f foreign key (promotion_id) references dcs_promotion (promotion_id)
,constraint dcs_discount_pro_c check (one_use in (0, 1)));


create table dcs_promo_upsell (
	promotion_id	varchar2(40)	not null,
	upsell	number(1,0)	null
,constraint dcs_promo_upsell_p primary key (promotion_id)
,constraint dcs_proupsell_d_f foreign key (promotion_id) references dcs_promotion (promotion_id)
,constraint dcs_promo_upsell_c check (upsell in (0, 1)));


create table dcs_upsell_action (
	action_id	varchar2(40)	not null,
	version	number(10)	not null,
	name	varchar2(40)	not null,
	upsell_prd_grp	clob	null
,constraint dcs_upsell_actn_p primary key (action_id));


create table dcs_close_qualif (
	close_qualif_id	varchar2(40)	not null,
	version	number(10)	not null,
	name	varchar2(40)	not null,
	priority	number(10)	null,
	qualifier	clob	null,
	upsell_media	varchar2(40)	null,
	upsell_action	varchar2(40)	null
,constraint dcs_close_qualif_p primary key (close_qualif_id)
,constraint dcs_cq_media_d_f foreign key (upsell_media) references dcs_media (media_id)
,constraint dcs_cq_action_d_f foreign key (upsell_action) references dcs_upsell_action (action_id));

create index dcs_closequalif2_x on dcs_close_qualif (upsell_media);
create index dcs_closequalif1_x on dcs_close_qualif (upsell_action);

create table dcs_prm_cls_qlf (
	promotion_id	varchar2(40)	not null,
	closeness_qualif	varchar2(40)	not null
,constraint dcs_promo_cq_d_f foreign key (promotion_id) references dcs_promotion (promotion_id)
,constraint dcs_prmclsqlf_d_f foreign key (closeness_qualif) references dcs_close_qualif (close_qualif_id));

create index dcs_prm_cls_qlf2_x on dcs_prm_cls_qlf (promotion_id);
create index dcs_prm_cls_qlf1_x on dcs_prm_cls_qlf (closeness_qualif);

create table dcs_prm_sites (
	promotion_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint dcs_prm_sites1_d_f foreign key (promotion_id) references dcs_promotion (promotion_id)
,constraint dcs_prm_sites2_d_f foreign key (site_id) references site_configuration (id));

create index dcs_prm_sites1_x on dcs_prm_sites (promotion_id);
create index dcs_prm_sites2_x on dcs_prm_sites (site_id);

create table dcs_prm_site_grps (
	promotion_id	varchar2(40)	not null,
	site_group_id	varchar2(40)	not null
,constraint dcs_prm_sgrps1_d_f foreign key (promotion_id) references dcs_promotion (promotion_id)
,constraint dcs_prm_sgrps2_d_f foreign key (site_group_id) references site_group (id));

create index dcs_prm_sgrps1_x on dcs_prm_site_grps (promotion_id);
create index dcs_prm_sgrps2_x on dcs_prm_site_grps (site_group_id);

create table dcs_prm_tpl_vals (
	promotion_id	varchar2(40)	not null,
	placeholder	varchar2(40)	not null,
	placeholderValue	clob	null
,constraint dcs_prm_tpl_vals_p primary key (promotion_id,placeholder)
,constraint dcs_prmtplvals_d_f foreign key (promotion_id) references dcs_promotion (promotion_id));


create table dcs_prm_cls_vals (
	close_qualif_id	varchar2(40)	not null,
	placeholder	varchar2(40)	not null,
	placeholderValue	clob	null
,constraint dcs_prm_cls_vals_p primary key (close_qualif_id,placeholder)
,constraint dcs_prmclsvals_d_f foreign key (close_qualif_id) references dcs_close_qualif (close_qualif_id));


create table dcs_upsell_prods (
	action_id	varchar2(40)	not null,
	product_id	varchar2(40)	not null,
	sequence_num	number(10)	not null
,constraint dcs_upsell_prods_p primary key (action_id,product_id)
,constraint dcs_ups_prod_d_f foreign key (product_id) references dcs_product (product_id));

create index dcs_upsellprods1_x on dcs_upsell_prods (product_id);




-- the source for this section is 
-- user_promotion_ddl.sql




-- The promotion line was commented out to allow the profile and promotion tables to be delinked. The promotion tables are intended to be used as a "read-only" table on the production servers. The promotion (and product catalog) tables are promoted and made active on the production system through copy-switch. In doing so, the profile tables and the promotion tables cannot be in the same database, and therefore we must remove this referece. However if you are not going to use copy-switch for the promotions, then you can add this reference back in.     promotion			VARCHAR(40)		NOT NULL	REFERENCES dcs_promotion(promotion_id),

create table dcs_usr_promostat (
	status_id	varchar2(40)	not null,
	profile_id	varchar2(40)	not null,
	promotion	varchar2(40)	not null,
	num_uses	integer	null,
	expirationDate	timestamp	null,
	granted_date	timestamp	null
,constraint dcs_usr_promosta_p primary key (status_id));

create index promostat_prof_idx on dcs_usr_promostat (profile_id);
create index usr_prmstat_pr_idx on dcs_usr_promostat (promotion);

create table dcs_usr_actvpromo (
	id	varchar2(40)	not null,
	sequence_num	integer	not null,
	promo_status_id	varchar2(40)	not null
,constraint dcs_usr_actvprom_p primary key (id,sequence_num));

create index usr_actvprm_id_idx on dcs_usr_actvpromo (id);
-- The promotion_id column was commented out to allow the profile and promotion tables to be delinked. The promotion tables are intended to be used as a "read-only" table on the production servers. The promotion (and product catalog) tables are promoted and made active on the production system through copy-switch. In doing so, the profile tables and the promotion tables cannot be in the same database, and therefore we must remove this referece. However if you are not going to use copy-switch for the promotions, then you can add this reference back in.        promotion_id                    VARCHAR(40)             NOT NULL        REFERENCES dcs_promotion(promotion_id),

create table dcs_usr_usedpromo (
	id	varchar2(40)	not null,
	promotion_id	varchar2(40)	not null
,constraint dcs_usr_usedprom_p primary key (id,promotion_id));

create index usr_usedprm_id_idx on dcs_usr_usedpromo (id);
create index usr_usedprm_pi_idx on dcs_usr_usedpromo (promotion_id);




-- the source for this section is 
-- user_giftlist_ddl.sql





create table dcs_giftlist (
	id	varchar2(40)	not null,
	owner_id	varchar2(40)	null,
	site_id	varchar2(40)	null,
	is_public	number(1,0)	not null,
	is_published	number(1,0)	not null,
	event_name	varchar2(64)	null,
	event_type	integer	null,
	event_date	timestamp	null,
	comments	varchar2(254)	null,
	description	varchar2(254)	null,
	instructions	varchar2(254)	null,
	creation_date	timestamp	null,
	last_modified_date	timestamp	null,
	shipping_addr_id	varchar2(40)	null
,constraint dcs_giftlist_p primary key (id)
,constraint dcs_giftlist1_c check (is_public in (0,1))
,constraint dcs_giftlist2_c check (is_published in (0,1)));

create index gftlst_shpadid_idx on dcs_giftlist (shipping_addr_id);
create index gft_evnt_name_idx on dcs_giftlist (event_name);
create index gft_evnt_type_idx on dcs_giftlist (event_type);
create index gft_owner_id_idx on dcs_giftlist (owner_id);
create index gft_site_id_idx on dcs_giftlist (site_id);

create table dcs_giftinst (
	giftlist_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	special_inst	varchar2(254)	null
,constraint dcs_giftinst_p primary key (giftlist_id,tag)
,constraint dcs_giftgiftlst__f foreign key (giftlist_id) references dcs_giftlist (id));

create index giftinst_gflid_idx on dcs_giftinst (giftlist_id);

create table dcs_giftitem (
	id	varchar2(40)	not null,
	catalog_ref_id	varchar2(40)	null,
	product_id	varchar2(40)	null,
	site_id	varchar2(40)	null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	quantity_desired	integer	null,
	quantity_purchased	integer	null
,constraint dcs_giftitem_p primary key (id));

create index giftitem_cat_idx on dcs_giftitem (catalog_ref_id);
create index giftitem_prod_idx on dcs_giftitem (product_id);
create index giftitem_site_idx on dcs_giftitem (site_id);

create table dcs_giftlist_item (
	giftlist_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	giftitem_id	varchar2(40)	null
,constraint dcs_giftlist_ite_p primary key (giftlist_id,sequence_num)
,constraint dcs_giftgifttm_d_f foreign key (giftitem_id) references dcs_giftitem (id)
,constraint dcs_gftlstgftlst_f foreign key (giftlist_id) references dcs_giftlist (id));

create index gftlst_itm_gii_idx on dcs_giftlist_item (giftitem_id);
create index gftlst_itm_gli_idx on dcs_giftlist_item (giftlist_id);

create table dcs_user_wishlist (
	user_id	varchar2(40)	not null,
	giftlist_id	varchar2(40)	null
,constraint dcs_user_wishlis_p primary key (user_id)
,constraint dcs_usrwgiftlst__f foreign key (giftlist_id) references dcs_giftlist (id));

create index usr_wshlst_gli_idx on dcs_user_wishlist (giftlist_id);

create table dcs_user_giftlist (
	user_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	giftlist_id	varchar2(40)	null
,constraint dcs_user_giftlis_p primary key (user_id,sequence_num));

create index usr_gftlst_uid_idx on dcs_user_giftlist (user_id);

create table dcs_user_otherlist (
	user_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	giftlist_id	varchar2(40)	null
,constraint dcs_user_otherli_p primary key (user_id,sequence_num)
,constraint dcs_usrtgiftlst__f foreign key (giftlist_id) references dcs_giftlist (id));

create index usr_otrlst_gli_idx on dcs_user_otherlist (giftlist_id);




-- the source for this section is 
-- order_ddl.sql





create table dcspp_order (
	order_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	order_class_type	varchar2(40)	null,
	profile_id	varchar2(40)	null,
	description	varchar2(64)	null,
	state	varchar2(40)	null,
	state_detail	varchar2(254)	null,
	created_by_order	varchar2(40)	null,
	origin_of_order	number(10)	null,
	creation_date	timestamp	null,
	submitted_date	timestamp	null,
	last_modified_date	timestamp	null,
	completed_date	timestamp	null,
	price_info	varchar2(40)	null,
	tax_price_info	varchar2(40)	null,
	explicitly_saved	number(1,0)	null,
	agent_id	varchar2(40)	null,
	sales_channel	number(10)	null,
	creation_site_id	varchar2(40)	null,
	site_id	varchar2(40)	null
,constraint dcspp_order_p primary key (order_id)
,constraint dcspp_order_c check (explicitly_saved IN (0,1)));

create index order_lastmod_idx on dcspp_order (last_modified_date);
create index order_profile_idx on dcspp_order (profile_id);
create index order_submit_idx on dcspp_order (submitted_date);
create index ord_creat_site_idx on dcspp_order (creation_site_id);
create index ord_site_idx on dcspp_order (site_id);

create table dcspp_ship_group (
	shipping_group_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	shipgrp_class_type	varchar2(40)	null,
	shipping_method	varchar2(40)	null,
	description	varchar2(64)	null,
	ship_on_date	timestamp	null,
	actual_ship_date	timestamp	null,
	state	varchar2(40)	null,
	state_detail	varchar2(254)	null,
	submitted_date	timestamp	null,
	price_info	varchar2(40)	null,
	order_ref	varchar2(40)	null
,constraint dcspp_ship_group_p primary key (shipping_group_id));


create table dcspp_pay_group (
	payment_group_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	paygrp_class_type	varchar2(40)	null,
	payment_method	varchar2(40)	null,
	amount	number(19,7)	null,
	amount_authorized	number(19,7)	null,
	amount_debited	number(19,7)	null,
	amount_credited	number(19,7)	null,
	currency_code	varchar2(10)	null,
	state	varchar2(40)	null,
	state_detail	varchar2(254)	null,
	submitted_date	timestamp	null,
	order_ref	varchar2(40)	null
,constraint dcspp_pay_group_p primary key (payment_group_id));


create table dcspp_item (
	commerce_item_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	item_class_type	varchar2(40)	null,
	catalog_id	varchar2(40)	null,
	catalog_ref_id	varchar2(40)	null,
	catalog_key	varchar2(40)	null,
	product_id	varchar2(40)	null,
	site_id	varchar2(40)	null,
	quantity	number(19,0)	null,
	state	varchar2(40)	null,
	state_detail	varchar2(254)	null,
	price_info	varchar2(40)	null,
	order_ref	varchar2(40)	null
,constraint dcspp_item_p primary key (commerce_item_id));

create index item_catref_idx on dcspp_item (catalog_ref_id);
create index item_prodref_idx on dcspp_item (product_id);
create index item_site_idx on dcspp_item (site_id);

create table dcspp_relationship (
	relationship_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	rel_class_type	varchar2(40)	null,
	relationship_type	varchar2(40)	null,
	order_ref	varchar2(40)	null
,constraint dcspp_relationsh_p primary key (relationship_id));


create table dcspp_rel_orders (
	order_id	varchar2(40)	not null,
	related_orders	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_rel_orders_p primary key (order_id,sequence_num)
,constraint dcspp_reordr_d_f foreign key (order_id) references dcspp_order (order_id));


create table dcspp_order_inst (
	order_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	special_inst	varchar2(254)	null
,constraint dcspp_order_inst_p primary key (order_id,tag)
,constraint dcspp_orordr_d_f foreign key (order_id) references dcspp_order (order_id));

create index order_inst_oid_idx on dcspp_order_inst (order_id);

create table dcspp_order_sg (
	order_id	varchar2(40)	not null,
	shipping_groups	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_order_sg_p primary key (order_id,sequence_num)
,constraint dcspp_sgordr_d_f foreign key (order_id) references dcspp_order (order_id));

create index order_sg_ordid_idx on dcspp_order_sg (order_id);

create table dcspp_order_pg (
	order_id	varchar2(40)	not null,
	payment_groups	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_order_pg_p primary key (order_id,sequence_num)
,constraint dcspp_orpgordr_f foreign key (order_id) references dcspp_order (order_id));

create index order_pg_ordid_idx on dcspp_order_pg (order_id);

create table dcspp_order_item (
	order_id	varchar2(40)	not null,
	commerce_items	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_order_item_p primary key (order_id,sequence_num)
,constraint dcspp_oritordr_d_f foreign key (order_id) references dcspp_order (order_id));

create index order_item_oid_idx on dcspp_order_item (order_id);
create index order_item_cit_idx on dcspp_order_item (commerce_items);

create table dcspp_order_rel (
	order_id	varchar2(40)	not null,
	relationships	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_order_rel_p primary key (order_id,sequence_num)
,constraint dcspp_orlordr_d_f foreign key (order_id) references dcspp_order (order_id));

create index order_rel_orid_idx on dcspp_order_rel (order_id);

create table dcspp_ship_inst (
	shipping_group_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	special_inst	varchar2(254)	null
,constraint dcspp_ship_inst_p primary key (shipping_group_id,tag)
,constraint dcspp_shshippng__f foreign key (shipping_group_id) references dcspp_ship_group (shipping_group_id));

create index ship_inst_sgid_idx on dcspp_ship_inst (shipping_group_id);

create table dcspp_hrd_ship_grp (
	shipping_group_id	varchar2(40)	not null,
	tracking_number	varchar2(40)	null
,constraint dcspp_hrd_ship_g_p primary key (shipping_group_id)
,constraint dcspp_hrshippng__f foreign key (shipping_group_id) references dcspp_ship_group (shipping_group_id));


create table dcspp_ele_ship_grp (
	shipping_group_id	varchar2(40)	not null,
	email_address	varchar2(255)	null
,constraint dcspp_ele_ship_g_p primary key (shipping_group_id)
,constraint dcspp_elshippng__f foreign key (shipping_group_id) references dcspp_ship_group (shipping_group_id));


create table dcspp_ship_addr (
	shipping_group_id	varchar2(40)	not null,
	prefix	varchar2(40)	null,
	first_name	varchar2(40)	null,
	middle_name	varchar2(40)	null,
	last_name	varchar2(40)	null,
	suffix	varchar2(40)	null,
	job_title	varchar2(40)	null,
	company_name	varchar2(40)	null,
	address_1	varchar2(50)	null,
	address_2	varchar2(50)	null,
	address_3	varchar2(50)	null,
	city	varchar2(40)	null,
	county	varchar2(40)	null,
	state	varchar2(40)	null,
	postal_code	varchar2(10)	null,
	country	varchar2(40)	null,
	phone_number	varchar2(40)	null,
	fax_number	varchar2(40)	null,
	email	varchar2(255)	null
,constraint dcspp_ship_addr_p primary key (shipping_group_id)
,constraint dcspp_shdshippng_f foreign key (shipping_group_id) references dcspp_ship_group (shipping_group_id));


create table dcspp_hand_inst (
	handling_inst_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	hndinst_class_type	varchar2(40)	null,
	handling_method	varchar2(40)	null,
	shipping_group_id	varchar2(40)	null,
	commerce_item_id	varchar2(40)	null,
	quantity	integer	null
,constraint dcspp_hand_inst_p primary key (handling_inst_id));

create index hi_item_idx on dcspp_hand_inst (commerce_item_id);
create index hi_ship_group_idx on dcspp_hand_inst (shipping_group_id);

create table dcspp_gift_inst (
	handling_inst_id	varchar2(40)	not null,
	giftlist_id	varchar2(40)	null,
	giftlist_item_id	varchar2(40)	null
,constraint dcspp_gift_inst_p primary key (handling_inst_id)
,constraint dcspp_gihandlng__f foreign key (handling_inst_id) references dcspp_hand_inst (handling_inst_id));


create table dcspp_sg_hand_inst (
	shipping_group_id	varchar2(40)	not null,
	handling_instrs	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_sg_hand_in_p primary key (shipping_group_id,sequence_num)
,constraint dcspp_sgshippng__f foreign key (shipping_group_id) references dcspp_ship_group (shipping_group_id));

create index sg_hnd_ins_sgi_idx on dcspp_sg_hand_inst (shipping_group_id);

create table dcspp_pay_inst (
	payment_group_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	special_inst	varchar2(254)	null
,constraint dcspp_pay_inst_p primary key (payment_group_id,tag)
,constraint dcspp_papaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index pay_inst_pgrid_idx on dcspp_pay_inst (payment_group_id);

create table dcspp_config_item (
	config_item_id	varchar2(40)	not null,
	reconfig_data	varchar2(255)	null,
	notes	varchar2(255)	null
,constraint dcspp_config_ite_p primary key (config_item_id)
,constraint dcspp_coconfg_tm_f foreign key (config_item_id) references dcspp_item (commerce_item_id));


create table dcspp_subsku_item (
	subsku_item_id	varchar2(40)	not null,
	ind_quantity	integer	null
,constraint dcspp_subsku_ite_p primary key (subsku_item_id)
,constraint dcspp_susubsk_tm_f foreign key (subsku_item_id) references dcspp_item (commerce_item_id));


create table dcspp_item_ci (
	commerce_item_id	varchar2(40)	not null,
	commerce_items	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_item_ci_p primary key (commerce_item_id,sequence_num)
,constraint dcspp_itcommrc_t_f foreign key (commerce_item_id) references dcspp_item (commerce_item_id));


create table dcspp_gift_cert (
	payment_group_id	varchar2(40)	not null,
	profile_id	varchar2(40)	null,
	gift_cert_number	varchar2(50)	null
,constraint dcspp_gift_cert_p primary key (payment_group_id)
,constraint dcspp_gipaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index gc_number_idx on dcspp_gift_cert (gift_cert_number);
create index gc_profile_idx on dcspp_gift_cert (profile_id);

create table dcspp_store_cred (
	payment_group_id	varchar2(40)	not null,
	profile_id	varchar2(40)	null,
	store_cred_number	varchar2(50)	null
,constraint dcspp_store_cred_p primary key (payment_group_id)
,constraint dcspp_stpaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index sc_number_idx on dcspp_store_cred (store_cred_number);
create index sc_profile_idx on dcspp_store_cred (profile_id);

create table dcspp_credit_card (
	payment_group_id	varchar2(40)	not null,
	credit_card_number	varchar2(40)	null,
	credit_card_type	varchar2(40)	null,
	expiration_month	varchar2(20)	null,
	exp_day_of_month	varchar2(20)	null,
	expiration_year	varchar2(20)	null
,constraint dcspp_credit_car_p primary key (payment_group_id)
,constraint dcspp_crpaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));


create table dcspp_bill_addr (
	payment_group_id	varchar2(40)	not null,
	prefix	varchar2(40)	null,
	first_name	varchar2(40)	null,
	middle_name	varchar2(40)	null,
	last_name	varchar2(40)	null,
	suffix	varchar2(40)	null,
	job_title	varchar2(40)	null,
	company_name	varchar2(40)	null,
	address_1	varchar2(50)	null,
	address_2	varchar2(50)	null,
	address_3	varchar2(50)	null,
	city	varchar2(40)	null,
	county	varchar2(40)	null,
	state	varchar2(40)	null,
	postal_code	varchar2(10)	null,
	country	varchar2(40)	null,
	phone_number	varchar2(40)	null,
	fax_number	varchar2(40)	null,
	email	varchar2(255)	null
,constraint dcspp_bill_addr_p primary key (payment_group_id)
,constraint dcspp_bipaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));


create table dcspp_pay_status (
	status_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	trans_id	varchar2(50)	null,
	amount	number(19,7)	null,
	trans_success	number(1,0)	null,
	error_message	varchar2(254)	null,
	trans_timestamp	timestamp	null
,constraint dcspp_pay_status_p primary key (status_id)
,constraint dcspp_pay_status_c check (trans_success IN (0,1)));


create table dcspp_cc_status (
	status_id	varchar2(40)	not null,
	auth_expiration	timestamp	null,
	avs_code	varchar2(40)	null,
	avs_desc_result	varchar2(254)	null,
	integration_data	varchar2(256)	null
,constraint dcspp_cc_status_p primary key (status_id)
,constraint dcspp_ccstats_d_f foreign key (status_id) references dcspp_pay_status (status_id));


create table dcspp_gc_status (
	status_id	varchar2(40)	not null,
	auth_expiration	timestamp	null
,constraint dcspp_gc_status_p primary key (status_id)
,constraint dcspp_gcstats_d_f foreign key (status_id) references dcspp_pay_status (status_id));


create table dcspp_sc_status (
	status_id	varchar2(40)	not null,
	auth_expiration	timestamp	null
,constraint dcspp_sc_status_p primary key (status_id)
,constraint dcspp_scstats_d_f foreign key (status_id) references dcspp_pay_status (status_id));


create table dcspp_auth_status (
	payment_group_id	varchar2(40)	not null,
	auth_status	varchar2(254)	not null,
	sequence_num	integer	not null
,constraint dcspp_auth_statu_p primary key (payment_group_id,sequence_num)
,constraint dcspp_atpaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index auth_stat_pgid_idx on dcspp_auth_status (payment_group_id);

create table dcspp_debit_status (
	payment_group_id	varchar2(40)	not null,
	debit_status	varchar2(254)	not null,
	sequence_num	integer	not null
,constraint dcspp_debit_stat_p primary key (payment_group_id,sequence_num)
,constraint dcspp_depaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index debit_stat_pgi_idx on dcspp_debit_status (payment_group_id);

create table dcspp_cred_status (
	payment_group_id	varchar2(40)	not null,
	credit_status	varchar2(254)	not null,
	sequence_num	integer	not null
,constraint dcspp_cred_statu_p primary key (payment_group_id,sequence_num)
,constraint dcspp_crpaymntgr_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index cred_stat_pgid_idx on dcspp_cred_status (payment_group_id);

create table dcspp_shipitem_rel (
	relationship_id	varchar2(40)	not null,
	shipping_group_id	varchar2(40)	null,
	commerce_item_id	varchar2(40)	null,
	quantity	number(19,0)	null,
	returned_qty	number(19,0)	null,
	amount	number(19,7)	null,
	state	varchar2(40)	null,
	state_detail	varchar2(254)	null
,constraint dcspp_shipitem_r_p primary key (relationship_id)
,constraint dcspp_shreltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index sirel_item_idx on dcspp_shipitem_rel (commerce_item_id);
create index sirel_shipgrp_idx on dcspp_shipitem_rel (shipping_group_id);

create table dcspp_rel_range (
	relationship_id	varchar2(40)	not null,
	low_bound	integer	null,
	high_bound	integer	null
,constraint dcspp_rel_range_p primary key (relationship_id));


create table dcspp_payitem_rel (
	relationship_id	varchar2(40)	not null,
	payment_group_id	varchar2(40)	null,
	commerce_item_id	varchar2(40)	null,
	quantity	number(19,0)	null,
	amount	number(19,7)	null
,constraint dcspp_payitem_re_p primary key (relationship_id)
,constraint dcspp_pareltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index pirel_item_idx on dcspp_payitem_rel (commerce_item_id);
create index pirel_paygrp_idx on dcspp_payitem_rel (payment_group_id);

create table dcspp_payship_rel (
	relationship_id	varchar2(40)	not null,
	payment_group_id	varchar2(40)	null,
	shipping_group_id	varchar2(40)	null,
	amount	number(19,7)	null
,constraint dcspp_payship_re_p primary key (relationship_id)
,constraint dcspp_pshrltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index psrel_paygrp_idx on dcspp_payship_rel (payment_group_id);
create index psrel_shipgrp_idx on dcspp_payship_rel (shipping_group_id);

create table dcspp_payorder_rel (
	relationship_id	varchar2(40)	not null,
	payment_group_id	varchar2(40)	null,
	order_id	varchar2(40)	null,
	amount	number(19,7)	null
,constraint dcspp_payorder_r_p primary key (relationship_id)
,constraint dcspp_odreltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index porel_order_idx on dcspp_payorder_rel (order_id);
create index porel_paygrp_idx on dcspp_payorder_rel (payment_group_id);

create table dcspp_amount_info (
	amount_info_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	currency_code	varchar2(10)	null,
	amount	number(19,7)	null,
	discounted	number(1,0)	null,
	amount_is_final	number(1,0)	null,
	final_rc	number(10)	null
,constraint dcspp_amount_inf_p primary key (amount_info_id)
,constraint dcspp_amount_in1_c check (discounted IN (0,1))
,constraint dcspp_amount_in2_c check (amount_is_final IN (0,1)));


create table dcspp_order_price (
	amount_info_id	varchar2(40)	not null,
	raw_subtotal	number(19,7)	null,
	tax	number(19,7)	null,
	shipping	number(19,7)	null,
	manual_adj_total	number(19,7)	null
,constraint dcspp_order_pric_p primary key (amount_info_id)
,constraint dcspp_oramnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));


create table dcspp_item_price (
	amount_info_id	varchar2(40)	not null,
	list_price	number(19,7)	null,
	raw_total_price	number(19,7)	null,
	sale_price	number(19,7)	null,
	on_sale	number(1,0)	null,
	order_discount	number(19,7)	null,
	qty_discounted	number(19,0)	null,
	qty_as_qualifier	number(19,0)	null,
	price_list	varchar2(40)	null
,constraint dcspp_item_price_p primary key (amount_info_id)
,constraint dcspp_itamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id)
,constraint dcspp_item_price_c check (on_sale IN (0,1)));


create table dcspp_tax_price (
	amount_info_id	varchar2(40)	not null,
	city_tax	number(19,7)	null,
	county_tax	number(19,7)	null,
	state_tax	number(19,7)	null,
	country_tax	number(19,7)	null
,constraint dcspp_tax_price_p primary key (amount_info_id)
,constraint dcspp_taamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));


create table dcspp_ship_price (
	amount_info_id	varchar2(40)	not null,
	raw_shipping	number(19,7)	null
,constraint dcspp_ship_price_p primary key (amount_info_id)
,constraint dcspp_shamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));


create table dcspp_amtinfo_adj (
	amount_info_id	varchar2(40)	not null,
	adjustments	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_amtinfo_ad_p primary key (amount_info_id,sequence_num)
,constraint dcspp_amamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));

create index amtinf_adj_aid_idx on dcspp_amtinfo_adj (amount_info_id);
create index amtinf_adj_adj_idx on dcspp_amtinfo_adj (adjustments);

create table dcspp_price_adjust (
	adjustment_id	varchar2(40)	not null,
	version	integer	not null,
	adj_description	varchar2(254)	null,
	pricing_model	varchar2(40)	null,
	manual_adjustment	varchar2(40)	null,
	adjustment	number(19,7)	null,
	qty_adjusted	integer	null
,constraint dcspp_price_adju_p primary key (adjustment_id));


create table dcspp_shipitem_sub (
	amount_info_id	varchar2(40)	not null,
	shipping_group_id	varchar2(42)	not null,
	ship_item_subtotal	varchar2(40)	not null
,constraint dcspp_shipitem_s_p primary key (amount_info_id,shipping_group_id)
,constraint dcspp_sbamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));

create index ship_item_sub_idx on dcspp_shipitem_sub (amount_info_id);

create table dcspp_taxshipitem (
	amount_info_id	varchar2(40)	not null,
	shipping_group_id	varchar2(42)	not null,
	tax_ship_item_sub	varchar2(40)	not null
,constraint dcspp_taxshipite_p primary key (amount_info_id,shipping_group_id)
,constraint dcspp_shamntxnfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));

create index tax_ship_item_idx on dcspp_taxshipitem (amount_info_id);

create table dcspp_ntaxshipitem (
	amount_info_id	varchar2(40)	not null,
	shipping_group_id	varchar2(42)	not null,
	non_tax_item_sub	varchar2(40)	not null
,constraint dcspp_ntaxshipit_p primary key (amount_info_id,shipping_group_id)
,constraint dcspp_ntamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));

create index ntax_ship_item_idx on dcspp_ntaxshipitem (amount_info_id);

create table dcspp_shipitem_tax (
	amount_info_id	varchar2(40)	not null,
	shipping_group_id	varchar2(42)	not null,
	ship_item_tax	varchar2(40)	not null
,constraint dcspp_shipitem_t_p primary key (amount_info_id,shipping_group_id)
,constraint dcspp_txamnt_nfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));

create index ship_item_tax_idx on dcspp_shipitem_tax (amount_info_id);

create table dcspp_itmprice_det (
	amount_info_id	varchar2(40)	not null,
	cur_price_details	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_itmprice_d_p primary key (amount_info_id,sequence_num)
,constraint dcspp_sbamntnfd_f foreign key (amount_info_id) references dcspp_amount_info (amount_info_id));

create index itmprc_det_aii_idx on dcspp_itmprice_det (amount_info_id);

create table dcspp_det_price (
	amount_info_id	varchar2(40)	not null,
	tax	number(19,7)	null,
	order_discount	number(19,7)	null,
	order_manual_adj	number(19,7)	null,
	quantity	number(19,0)	null,
	qty_as_qualifier	number(19,0)	null
,constraint dcspp_det_price_p primary key (amount_info_id));


create table dcspp_det_range (
	amount_info_id	varchar2(40)	not null,
	low_bound	integer	null,
	high_bound	integer	null
,constraint dcspp_det_range_p primary key (amount_info_id));


create table dcspp_order_adj (
	order_id	varchar2(40)	not null,
	adjustment_id	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcspp_order_adj_p primary key (order_id,sequence_num)
,constraint dcspp_oradj_d_f foreign key (order_id) references dcspp_order (order_id));

create index order_adj_orid_idx on dcspp_order_adj (order_id);

create table dcspp_manual_adj (
	manual_adjust_id	varchar2(40)	not null,
	type	integer	not null,
	adjustment_type	integer	not null,
	reason	integer	not null,
	amount	number(19,7)	null,
	notes	varchar2(255)	null,
	version	integer	not null
,constraint dcspp_manual_adj_p primary key (manual_adjust_id));


create table dbcpp_sched_order (
	scheduled_order_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	name	varchar2(32)	null,
	profile_id	varchar2(40)	null,
	create_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	template_order	varchar2(32)	null,
	state	integer	null,
	next_scheduled	timestamp	null,
	schedule	varchar2(255)	null,
	site_id	varchar2(40)	null
,constraint dbcpp_sched_orde_p primary key (scheduled_order_id));

create index sched_tmplt_idx on dbcpp_sched_order (template_order);
create index sched_profile_idx on dbcpp_sched_order (profile_id);
create index sched_site_idx on dbcpp_sched_order (site_id);

create table dbcpp_sched_clone (
	scheduled_order_id	varchar2(40)	not null,
	cloned_order	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dbcpp_sched_clon_p primary key (scheduled_order_id,sequence_num)
,constraint dbcpp_scschedld__f foreign key (scheduled_order_id) references dbcpp_sched_order (scheduled_order_id));


create table dcspp_scherr_aux (
	scheduled_order_id	varchar2(40)	not null,
	sched_error_id	varchar2(40)	not null
,constraint dcspp_scherr_aux_p primary key (scheduled_order_id));

create index sched_error_idx on dcspp_scherr_aux (sched_error_id);

create table dcspp_sched_error (
	sched_error_id	varchar2(40)	not null,
	error_date	timestamp	not null
,constraint dcspp_sched_err_p primary key (sched_error_id));


create table dcspp_schd_errmsg (
	sched_error_id	varchar2(40)	not null,
	error_txt	varchar2(254)	not null,
	sequence_num	integer	not null
,constraint dcspp_schd_errs_p primary key (sched_error_id,sequence_num)
,constraint dcspp_sch_errs_f foreign key (sched_error_id) references dcspp_sched_error (sched_error_id));





-- the source for this section is 
-- dcs_mappers.sql





create table dcs_cart_event (
	id	varchar2(40)	not null,
	timestamp	timestamp	null,
	orderid	varchar2(40)	null,
	itemid	varchar2(40)	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	quantity	integer	null,
	amount	number(19,7)	null,
	profileid	varchar2(40)	null);


create table dcs_submt_ord_evt (
	id	varchar2(40)	not null,
	clocktime	timestamp	null,
	orderid	varchar2(40)	null,
	profileid	varchar2(40)	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null);


create table dcs_prom_used_evt (
	id	varchar2(40)	not null,
	clocktime	timestamp	null,
	orderid	varchar2(40)	null,
	profileid	varchar2(40)	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	promotionid	varchar2(40)	null,
	order_amount	number(26,7)	null,
	discount	number(26,7)	null);


create table dcs_ord_merge_evt (
	id	varchar2(40)	not null,
	clocktime	timestamp	null,
	sourceorderid	varchar2(40)	null,
	destorderid	varchar2(40)	null,
	profileid	varchar2(40)	null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null,
	sourceremoved	number(1,0)	null
,constraint dcs_ordmergeevt_ck check (sourceremoved in (0,1)));


create table dcs_promo_rvkd (
	id	varchar2(40)	not null,
	time_stamp	timestamp	null,
	promotionid	varchar2(254)	not null,
	profileid	varchar2(254)	not null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null);


create table dcs_promo_grntd (
	id	varchar2(40)	not null,
	time_stamp	timestamp	null,
	promotionid	varchar2(254)	not null,
	profileid	varchar2(254)	not null,
	sessionid	varchar2(100)	null,
	parentsessionid	varchar2(100)	null);





-- the source for this section is 
-- claimable_ddl.sql





create table dcspp_claimable (
	claimable_id	varchar2(40)	not null,
	version	integer	not null,
	type	integer	not null,
	status	integer	null,
	expiration_date	timestamp	null,
	last_modified	timestamp	null
,constraint dcspp_claimable_p primary key (claimable_id));


create table dcspp_giftcert (
	giftcertificate_id	varchar2(40)	not null,
	amount	double precision	not null,
	amount_authorized	double precision	not null,
	amount_remaining	double precision	not null,
	purchaser_id	varchar2(40)	null,
	purchase_date	timestamp	null,
	last_used	timestamp	null
,constraint dcspp_giftcert_p primary key (giftcertificate_id)
,constraint dcspp_gigiftcrtf_f foreign key (giftcertificate_id) references dcspp_claimable (claimable_id));

create index claimable_user_idx on dcspp_giftcert (purchaser_id);

create table dcs_storecred_clm (
	store_credit_id	varchar2(40)	not null,
	amount	number(19,7)	not null,
	amount_authorized	number(19,7)	not null,
	amount_remaining	number(19,7)	not null,
	owner_id	varchar2(40)	null,
	issue_date	timestamp	null,
	expiration_date	timestamp	null,
	last_used	timestamp	null
,constraint dcs_storecred_cl_p primary key (store_credit_id)
,constraint dcs_storstor_crd_f foreign key (store_credit_id) references dcspp_claimable (claimable_id));

create index storecr_issue_idx on dcs_storecred_clm (issue_date);
create index storecr_owner_idx on dcs_storecred_clm (owner_id);

create table dcspp_cp_folder (
	folder_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	parent_folder	varchar2(40)	null
,constraint dcspp_cp_folder_p primary key (folder_id)
,constraint dcspp_cp_prntfol_f foreign key (parent_folder) references dcspp_cp_folder (folder_id));

create index dcspp_prntfol_idx on dcspp_cp_folder (parent_folder);

create table dcspp_coupon (
	coupon_id	varchar2(40)	not null,
	promotion_id	varchar2(40)	not null
,constraint dcspp_coupon_p primary key (coupon_id,promotion_id)
,constraint dcspp_coupon_df foreign key (coupon_id) references dcspp_claimable (claimable_id));


create table dcspp_coupon_info (
	coupon_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	use_promo_site	number(10)	null,
	parent_folder	varchar2(40)	null
,constraint dcspp_copninfo_p primary key (coupon_id)
,constraint dcspp_copninfo_d_f foreign key (coupon_id) references dcspp_claimable (claimable_id)
,constraint dcspp_cpnifol_f foreign key (parent_folder) references dcspp_cp_folder (folder_id));

create index dcspp_folder_idx on dcspp_coupon_info (parent_folder);




-- the source for this section is 
-- priceLists_ddl.sql





create table dcs_price_list (
	price_list_id	varchar2(40)	not null,
	version	integer	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	creation_date	timestamp	null,
	last_mod_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	locale	number(10)	null,
	base_price_list	varchar2(40)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_price_list_p primary key (price_list_id)
,constraint dcs_pricbas_prcl_f foreign key (base_price_list) references dcs_price_list (price_list_id));

create index dcs_pricelstbase_i on dcs_price_list (base_price_list);

create table dcs_complex_price (
	complex_price_id	varchar2(40)	not null,
	version	integer	not null
,constraint dcs_complex_pric_p primary key (complex_price_id));


create table dcs_price (
	price_id	varchar2(40)	not null,
	version	integer	not null,
	price_list	varchar2(40)	not null,
	product_id	varchar2(40)	null,
	sku_id	varchar2(40)	null,
	parent_sku_id	varchar2(40)	null,
	pricing_scheme	integer	not null,
	list_price	number(19,7)	null,
	complex_price	varchar2(40)	null
,constraint dcs_price_p primary key (price_id)
,constraint dcs_priccomplx_p_f foreign key (complex_price) references dcs_complex_price (complex_price_id)
,constraint dcs_pricpric_lst_f foreign key (price_list) references dcs_price_list (price_list_id));

create index dcs_cmplx_prc_idx on dcs_price (complex_price);
create index dcs_price_idx1 on dcs_price (product_id);
create index dcs_price_idx2 on dcs_price (price_list,sku_id);

create table dcs_price_levels (
	complex_price_id	varchar2(40)	not null,
	price_levels	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dcs_price_levels_p primary key (complex_price_id,sequence_num)
,constraint dcs_lvlscomplx_p_f foreign key (complex_price_id) references dcs_complex_price (complex_price_id));


create table dcs_price_level (
	price_level_id	varchar2(40)	not null,
	version	integer	not null,
	quantity	integer	not null,
	price	number(19,7)	not null
,constraint dcs_price_level_p primary key (price_level_id));


create table dcs_gen_fol_pl (
	folder_id	varchar2(40)	not null,
	type	integer	not null,
	name	varchar2(40)	not null,
	parent	varchar2(40)	null,
	description	varchar2(254)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_gen_fol_pl_p primary key (folder_id));


create table dcs_child_fol_pl (
	folder_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	child_folder_id	varchar2(40)	not null
,constraint dcs_child_fol_pl_p primary key (folder_id,sequence_num)
,constraint dcs_chilfoldr_d_f foreign key (folder_id) references dcs_gen_fol_pl (folder_id));


create table dcs_plfol_chld (
	plfol_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	price_list_id	varchar2(40)	not null
,constraint dcs_plfol_chld_p primary key (plfol_id,sequence_num)
,constraint dcs_plfoplfol_d_f foreign key (plfol_id) references dcs_gen_fol_pl (folder_id));





-- the source for this section is 
-- order_markers_ddl.sql





create table dcs_order_markers (
	marker_id	varchar2(40)	not null,
	order_id	varchar2(40)	not null,
	marker_key	varchar2(100)	not null,
	marker_value	varchar2(100)	null,
	marker_data	varchar2(100)	null,
	creation_date	timestamp	null,
	version	number(10)	not null,
	marker_type	number(10)	null
,constraint dcsordermarkers_p primary key (marker_id,order_id)
,constraint dcsordermarkers_f foreign key (order_id) references dcspp_order (order_id));

create index dcs_ordrmarkers1_x on dcs_order_markers (order_id);

create table dcspp_commerce_item_markers (
	marker_id	varchar2(40)	not null,
	commerce_item_id	varchar2(40)	not null,
	marker_key	varchar2(100)	not null,
	marker_value	varchar2(100)	null,
	marker_data	varchar2(100)	null,
	creation_date	timestamp	null,
	version	number(10)	not null,
	marker_type	number(10)	null
,constraint dcscitemmarkers_p primary key (marker_id,commerce_item_id)
,constraint dcscitemmarkers_f foreign key (commerce_item_id) references dcspp_item (commerce_item_id));

create index dcs_itemmarkers1_x on dcspp_commerce_item_markers (commerce_item_id);




-- the source for this section is 
-- commerce_site_ddl.sql




-- This file contains create table statements, which will configureyour database for use MultiSite

create table dcs_site (
	id	varchar2(40)	not null,
	catalog_id	varchar2(40)	null,
	list_pricelist_id	varchar2(40)	null,
	sale_pricelist_id	varchar2(40)	null
,constraint dcs_site_p primary key (id));





-- the source for this section is 
-- custom_catalog_ddl.sql





create table dcs_catalog (
	catalog_id	varchar2(40)	not null,
	version	integer	not null,
	display_name	varchar2(254)	null,
	creation_date	timestamp	null,
	last_mod_date	timestamp	null,
	migration_status	number(3,0)	null,
	migration_index	number(10)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_catalog_p primary key (catalog_id));


create table dcs_root_cats (
	catalog_id	varchar2(40)	not null,
	root_cat_id	varchar2(40)	not null
,constraint dcs_root_cats_p primary key (catalog_id,root_cat_id)
,constraint dcs_rotccatlg_d_f foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_rotcrot_ctd_f foreign key (root_cat_id) references dcs_category (category_id));

create index dcs_rootcatscat_id on dcs_root_cats (root_cat_id);

create table dcs_allroot_cats (
	catalog_id	varchar2(40)	not null,
	root_cat_id	varchar2(40)	not null
,constraint dcs_allroot_cats_p primary key (catalog_id,root_cat_id)
,constraint dcs_allrcatlg_d_f foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_allrrot_ctd_f foreign key (root_cat_id) references dcs_category (category_id));

create index dcs_allrt_cats_id on dcs_allroot_cats (root_cat_id);

create table dcs_root_subcats (
	catalog_id	varchar2(40)	not null,
	sub_catalog_id	varchar2(40)	not null
,constraint dcs_root_subcats_p primary key (catalog_id,sub_catalog_id)
,constraint dcs_rotscatlg_d_f foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_rotssub_ctlg_f foreign key (sub_catalog_id) references dcs_catalog (catalog_id));

create index dcs_rtsubcats_id on dcs_root_subcats (sub_catalog_id);

create table dcs_category_info (
	category_info_id	varchar2(40)	not null,
	version	integer	not null,
	item_acl	varchar2(1024)	null
,constraint dcs_category_inf_p primary key (category_info_id));


create table dcs_product_info (
	product_info_id	varchar2(40)	not null,
	version	integer	not null,
	parent_cat_id	varchar2(40)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_product_info_p primary key (product_info_id));


create table dcs_sku_info (
	sku_info_id	varchar2(40)	not null,
	version	integer	not null,
	item_acl	varchar2(1024)	null
,constraint dcs_sku_info_p primary key (sku_info_id));


create table dcs_cat_subcats (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	catalog_id	varchar2(40)	not null
,constraint dcs_cat_subcats_p primary key (category_id,sequence_num)
,constraint dcs_catscatlg_d_f foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_catscatgry_d_f foreign key (category_id) references dcs_category (category_id));

create index dcs_catsubcatlogid on dcs_cat_subcats (catalog_id);

create table dcs_cat_subroots (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	sub_category_id	varchar2(40)	not null
,constraint dcs_cat_subroots_p primary key (category_id,sequence_num)
,constraint dcs_subrtscatgry_f foreign key (category_id) references dcs_category (category_id));


create table dcs_cat_catinfo (
	category_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null,
	category_info_id	varchar2(40)	not null
,constraint dcs_cat_catinfo_p primary key (category_id,catalog_id)
,constraint dcs_infocatgry_d_f foreign key (category_id) references dcs_category (category_id));


create table dcs_catinfo_anc (
	category_info_id	varchar2(40)	not null,
	anc_cat_id	varchar2(40)	not null
,constraint dcs_catinfo_anc_p primary key (category_info_id,anc_cat_id));


create table dcs_prd_prdinfo (
	product_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null,
	product_info_id	varchar2(40)	not null
,constraint dcs_prd_prdinfo_p primary key (product_id,catalog_id)
,constraint dcs_prdpprodct_d_f foreign key (product_id) references dcs_product (product_id));


create table dcs_prdinfo_rdprd (
	product_info_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	related_prd_id	varchar2(40)	not null
,constraint dcs_prdinfo_rdpr_p primary key (product_info_id,sequence_num)
,constraint dcs_prdireltd_pr_f foreign key (related_prd_id) references dcs_product (product_id)
,constraint dcs_prdiprodct_n_f foreign key (product_info_id) references dcs_product_info (product_info_id));

create index dcs_prdrelatedinfo on dcs_prdinfo_rdprd (related_prd_id);

create table dcs_prdinfo_anc (
	product_info_id	varchar2(40)	not null,
	anc_cat_id	varchar2(40)	not null
,constraint dcs_prdinfo_anc_p primary key (product_info_id,anc_cat_id));


create table dcs_sku_skuinfo (
	sku_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null,
	sku_info_id	varchar2(40)	not null
,constraint dcs_sku_skuinfo_p primary key (sku_id,catalog_id)
,constraint dcs_skusknfsku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table dcs_skuinfo_rplc (
	sku_info_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	replacement	varchar2(40)	not null
,constraint dcs_skuinfo_rplc_p primary key (sku_info_id,sequence_num)
,constraint dcs_skunsku_nfd_f foreign key (sku_info_id) references dcs_sku_info (sku_info_id));


create table dcs_gen_fol_cat (
	folder_id	varchar2(40)	not null,
	type	integer	not null,
	name	varchar2(40)	not null,
	parent	varchar2(40)	null,
	description	varchar2(254)	null,
	item_acl	varchar2(1024)	null
,constraint dcs_gen_fol_cat_p primary key (folder_id));


create table dcs_child_fol_cat (
	folder_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	child_folder_id	varchar2(40)	not null
,constraint dcs_child_fol_ca_p primary key (folder_id,sequence_num)
,constraint dcs_catlfoldr_d_f foreign key (folder_id) references dcs_gen_fol_cat (folder_id));


create table dcs_catfol_chld (
	catfol_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	catalog_id	varchar2(40)	not null
,constraint dcs_catfol_chld_p primary key (catfol_id,sequence_num)
,constraint dcs_catfcatfl_d_f foreign key (catfol_id) references dcs_gen_fol_cat (folder_id));


create table dcs_catfol_sites (
	catfol_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint dcs_catfl_sites_pk primary key (catfol_id,site_id));


create table dcs_dir_anc_ctlgs (
	catalog_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	anc_catalog_id	varchar2(40)	not null
,constraint dcs_dirancctlgs_pk primary key (catalog_id,sequence_num)
,constraint dcs_dirancctlgs_f1 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_dirancctlgs_f2 foreign key (anc_catalog_id) references dcs_catalog (catalog_id));

create index dcs_dirancctlg_idx on dcs_dir_anc_ctlgs (anc_catalog_id);

create table dcs_ind_anc_ctlgs (
	catalog_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	anc_catalog_id	varchar2(40)	not null
,constraint dcs_indancctlgs_pk primary key (catalog_id,sequence_num)
,constraint dcs_indancctlgs_f1 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_indancctlgs_f2 foreign key (anc_catalog_id) references dcs_catalog (catalog_id));

create index dcs_indanctlg_idx on dcs_ind_anc_ctlgs (anc_catalog_id);

create table dcs_ctlg_anc_cats (
	catalog_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	category_id	varchar2(40)	not null
,constraint dcs_ctlganccats_pk primary key (catalog_id,sequence_num)
,constraint dcs_ctlganccats_f1 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_ctlganccats_f2 foreign key (category_id) references dcs_category (category_id));

create index dcs_ctlgancat_idx on dcs_ctlg_anc_cats (category_id);

create table dcs_cat_anc_cats (
	category_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	anc_category_id	varchar2(40)	not null
,constraint dcs_cat_anccats_pk primary key (category_id,sequence_num)
,constraint dcs_cat_anccats_f1 foreign key (category_id) references dcs_category (category_id)
,constraint dcs_cat_anccats_f2 foreign key (anc_category_id) references dcs_category (category_id));

create index dcs_catanccat_idx on dcs_cat_anc_cats (anc_category_id);

create table dcs_cat_prnt_cats (
	category_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null,
	parent_ctgy_id	varchar2(40)	not null
,constraint dcs_catprntcats_pk primary key (category_id,catalog_id)
,constraint dcscatprntcats_fk1 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcscatprntcats_fk2 foreign key (category_id) references dcs_category (category_id)
,constraint dcscatprntcats_fk3 foreign key (parent_ctgy_id) references dcs_category (category_id));

create index dcscatprntcats_ix1 on dcs_cat_prnt_cats (catalog_id);
create index dcscatprntcats_ix2 on dcs_cat_prnt_cats (category_id);
create index dcscatprntcats_ix3 on dcs_cat_prnt_cats (parent_ctgy_id);

create table dcs_prd_prnt_cats (
	product_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null,
	category_id	varchar2(40)	not null
,constraint dcs_prdprntcats_pk primary key (product_id,catalog_id)
,constraint dcs_prdprntcats_f2 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_prdprntcats_f3 foreign key (category_id) references dcs_category (category_id)
,constraint dcs_prdprntcats_f1 foreign key (product_id) references dcs_product (product_id));

create index pr_prnt_cat_pi_idx on dcs_prd_prnt_cats (catalog_id);
create index pr_prnt_cat_ci_idx on dcs_prd_prnt_cats (category_id);

create table dcs_prd_anc_cats (
	product_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	category_id	varchar2(40)	not null
,constraint dcs_prdanc_cats_pk primary key (product_id,sequence_num)
,constraint dcs_prdanc_cats_f2 foreign key (category_id) references dcs_category (category_id)
,constraint dcs_prdanc_cats_f1 foreign key (product_id) references dcs_product (product_id));

create index dcs_prdanccat_idx on dcs_prd_anc_cats (category_id);

create table dcs_cat_catalogs (
	category_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null
,constraint dcs_cat_catalgs_pk primary key (category_id,catalog_id)
,constraint dcs_cat_catalgs_f2 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_cat_catalgs_f1 foreign key (category_id) references dcs_category (category_id));

create index dcs_catctlgs_idx on dcs_cat_catalogs (catalog_id);

create table dcs_prd_catalogs (
	product_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null
,constraint dcs_prd_catalgs_pk primary key (product_id,catalog_id)
,constraint dcs_prd_catalgs_f2 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_prd_catalgs_f1 foreign key (product_id) references dcs_product (product_id));

create index dcs_prd_ctlgs_idx on dcs_prd_catalogs (catalog_id);

create table dcs_sku_catalogs (
	sku_id	varchar2(40)	not null,
	catalog_id	varchar2(40)	not null
,constraint dcs_sku_catalgs_pk primary key (sku_id,catalog_id)
,constraint dcs_sku_catalgs_f2 foreign key (catalog_id) references dcs_catalog (catalog_id)
,constraint dcs_sku_catalgs_f1 foreign key (sku_id) references dcs_sku (sku_id));

create index dcs_sku_ctlgs_idx on dcs_sku_catalogs (catalog_id);

create table dcs_catalog_sites (
	catalog_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint dcs_catlg_sites_pk primary key (catalog_id,site_id));

create index catlg_site_id_idx on dcs_catalog_sites (site_id);

create table dcs_category_sites (
	category_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint dcs_cat_sites_pk primary key (category_id,site_id));

create index cat_site_id_idx on dcs_category_sites (site_id);

create table dcs_product_sites (
	product_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint dcs_prod_sites_pk primary key (product_id,site_id)
,constraint dcs_prod_sites_f1 foreign key (product_id) references dcs_product (product_id));

create index prd_site_id_idx on dcs_product_sites (site_id);

create table dcs_sku_sites (
	sku_id	varchar2(40)	not null,
	site_id	varchar2(40)	not null
,constraint dcs_sku_sites_pk primary key (sku_id,site_id)
,constraint dcs_sku_sites_f1 foreign key (sku_id) references dcs_sku (sku_id));

create index sku_site_id_idx on dcs_sku_sites (site_id);




-- the source for this section is 
-- custom_catalog_user_ddl.sql





create table dcs_user_catalog (
	user_id	varchar2(40)	not null,
	user_catalog	varchar2(40)	null
,constraint dcs_usr_catalog_pk primary key (user_id));





-- the source for this section is 
-- b2b_product_catalog_ddl.sql





create table dbc_manufacturer (
	manufacturer_id	varchar2(40)	not null,
	manufacturer_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	email	varchar2(255)	null
,constraint dbc_manufacturer_p primary key (manufacturer_id));

create index dbc_man_name_idx on dbc_manufacturer (manufacturer_name);

create table dbc_measurement (
	sku_id	varchar2(40)	not null,
	unit_of_measure	integer	null,
	quantity	number(19,7)	null
,constraint dbc_measurement_p primary key (sku_id));


create table dbc_product (
	product_id	varchar2(40)	not null,
	manufacturer	varchar2(40)	null
,constraint dbc_product_p primary key (product_id)
,constraint dbc_prodmanfctrr_f foreign key (manufacturer) references dbc_manufacturer (manufacturer_id)
,constraint dbc_prodprodct_d_f foreign key (product_id) references dcs_product (product_id));

create index dbc_prd_man_idx on dbc_product (manufacturer);

create table dbc_sku (
	sku_id	varchar2(40)	not null,
	manuf_part_num	varchar2(254)	null
,constraint dbc_sku_p primary key (sku_id)
,constraint dbc_skusku_d_f foreign key (sku_id) references dcs_sku (sku_id));

create index dbc_sku_prtnum_idx on dbc_sku (manuf_part_num);




-- the source for this section is 
-- b2b_order_ddl.sql





create table dbcpp_approverids (
	order_id	varchar2(40)	not null,
	approver_ids	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dbcpp_approverid_p primary key (order_id,sequence_num)
,constraint dbcpp_apordr_d_f foreign key (order_id) references dcspp_order (order_id));


create table dbcpp_authapprids (
	order_id	varchar2(40)	not null,
	auth_appr_ids	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dbcpp_authapprid_p primary key (order_id,sequence_num)
,constraint dbcpp_atordr_d_f foreign key (order_id) references dcspp_order (order_id));


create table dbcpp_apprsysmsgs (
	order_id	varchar2(40)	not null,
	appr_sys_msgs	varchar2(254)	not null,
	sequence_num	integer	not null
,constraint dbcpp_apprsysmsg_p primary key (order_id,sequence_num)
,constraint dbcpp_sysmordr_d_f foreign key (order_id) references dcspp_order (order_id));


create table dbcpp_appr_msgs (
	order_id	varchar2(40)	not null,
	approver_msgs	varchar2(254)	not null,
	sequence_num	integer	not null
,constraint dbcpp_appr_msgs_p primary key (order_id,sequence_num)
,constraint dbcpp_msgordr_d_f foreign key (order_id) references dcspp_order (order_id));


create table dbcpp_invoice_req (
	payment_group_id	varchar2(40)	not null,
	po_number	varchar2(40)	null,
	pref_format	varchar2(40)	null,
	pref_delivery	varchar2(40)	null,
	disc_percent	number(19,7)	null,
	disc_days	integer	null,
	net_days	integer	null,
	pmt_due_date	date	null
,constraint dbcpp_invoice_re_p primary key (payment_group_id)
,constraint dbcpp_inpaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));


create table dbcpp_cost_center (
	cost_center_id	varchar2(40)	not null,
	type	integer	not null,
	version	integer	not null,
	costctr_class_type	varchar2(40)	null,
	identifier	varchar2(40)	null,
	amount	number(19,7)	null,
	order_ref	varchar2(40)	null
,constraint dbcpp_cost_cente_p primary key (cost_center_id));


create table dbcpp_order_cc (
	order_id	varchar2(40)	not null,
	cost_centers	varchar2(40)	not null,
	sequence_num	integer	not null
,constraint dbcpp_order_cc_p primary key (order_id,sequence_num)
,constraint dbcpp_orordr_d_f foreign key (order_id) references dcspp_order (order_id));

create index order_cc_ordid_idx on dbcpp_order_cc (order_id);

create table dbcpp_ccitem_rel (
	relationship_id	varchar2(40)	not null,
	cost_center_id	varchar2(40)	null,
	commerce_item_id	varchar2(40)	null,
	quantity	integer	null,
	amount	number(19,7)	null
,constraint dbcpp_ccitem_rel_p primary key (relationship_id)
,constraint dbcpp_ccreltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index cirel_cstctr_idx on dbcpp_ccitem_rel (cost_center_id);
create index cirel_item_idx on dbcpp_ccitem_rel (commerce_item_id);

create table dbcpp_ccship_rel (
	relationship_id	varchar2(40)	not null,
	cost_center_id	varchar2(40)	null,
	shipping_group_id	varchar2(40)	null,
	amount	number(19,7)	null
,constraint dbcpp_ccship_rel_p primary key (relationship_id)
,constraint dbcpp_shreltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index csrel_cstctr_idx on dbcpp_ccship_rel (cost_center_id);
create index csrel_shipgrp_idx on dbcpp_ccship_rel (shipping_group_id);

create table dbcpp_ccorder_rel (
	relationship_id	varchar2(40)	not null,
	cost_center_id	varchar2(40)	null,
	order_id	varchar2(40)	null,
	amount	number(19,7)	null
,constraint dbcpp_ccorder_re_p primary key (relationship_id)
,constraint dbcpp_odreltnshp_f foreign key (relationship_id) references dcspp_relationship (relationship_id));

create index corel_cstctr_idx on dbcpp_ccorder_rel (cost_center_id);
create index corel_order_idx on dbcpp_ccorder_rel (order_id);

create table dbcpp_pmt_req (
	payment_group_id	varchar2(40)	not null,
	req_number	varchar2(40)	null
,constraint dbcpp_pmt_req_p primary key (payment_group_id)
,constraint dbcpp_pmpaymnt_g_f foreign key (payment_group_id) references dcspp_pay_group (payment_group_id));

create index pmtreq_req_idx on dbcpp_pmt_req (req_number);




-- the source for this section is 
-- invoice_ddl.sql





create table dbc_inv_delivery (
	id	varchar2(40)	not null,
	version	integer	not null,
	type	integer	not null,
	prefix	varchar2(40)	null,
	first_name	varchar2(40)	null,
	middle_name	varchar2(40)	null,
	last_name	varchar2(40)	null,
	suffix	varchar2(40)	null,
	job_title	varchar2(80)	null,
	company_name	varchar2(40)	null,
	address1	varchar2(80)	null,
	address2	varchar2(80)	null,
	address3	varchar2(80)	null,
	city	varchar2(40)	null,
	county	varchar2(40)	null,
	state	varchar2(40)	null,
	postal_code	varchar2(10)	null,
	country	varchar2(40)	null,
	phone_number	varchar2(40)	null,
	fax_number	varchar2(40)	null,
	email_addr	varchar2(255)	null,
	format	integer	null,
	delivery_mode	integer	null
,constraint dbc_inv_delivery_p primary key (id));


create table dbc_inv_pmt_terms (
	id	varchar2(40)	not null,
	version	integer	not null,
	type	integer	not null,
	disc_percent	number(19,7)	null,
	disc_days	integer	null,
	net_days	integer	null
,constraint dbc_inv_pmt_term_p primary key (id));


create table dbc_invoice (
	id	varchar2(40)	not null,
	version	integer	not null,
	type	integer	not null,
	creation_date	timestamp	null,
	last_mod_date	timestamp	null,
	invoice_number	varchar2(40)	null,
	po_number	varchar2(40)	null,
	req_number	varchar2(40)	null,
	delivery_info	varchar2(40)	null,
	balance_due	number(19,7)	null,
	pmt_due_date	date	null,
	pmt_terms	varchar2(40)	null,
	order_id	varchar2(40)	null,
	pmt_group_id	varchar2(40)	null
,constraint dbc_invoice_p primary key (id)
,constraint dbc_invcdelvry_n_f foreign key (delivery_info) references dbc_inv_delivery (id)
,constraint dbc_invcpmt_term_f foreign key (pmt_terms) references dbc_inv_pmt_terms (id));

create index dbc_inv_dlivr_info on dbc_invoice (delivery_info);
create index dbc_inv_pmt_terms on dbc_invoice (pmt_terms);
create index inv_inv_idx on dbc_invoice (invoice_number);
create index inv_order_idx on dbc_invoice (order_id);
create index inv_pmt_idx on dbc_invoice (pmt_group_id);
create index inv_po_idx on dbc_invoice (po_number);




-- the source for this section is 
-- contracts_ddl.sql




-- Normally, catalog_id and price_list_id would reference the appropriate table it is possible not to use those tables though, which is why the reference is not included

create table dbc_contract (
	contract_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	creation_date	timestamp	null,
	start_date	timestamp	null,
	end_date	timestamp	null,
	creator_id	varchar2(40)	null,
	negotiator_info	varchar2(40)	null,
	price_list_id	varchar2(40)	null,
	catalog_id	varchar2(40)	null,
	term_id	varchar2(40)	null,
	comments	varchar2(254)	null
,constraint dbc_contract_p primary key (contract_id));


create table dbc_contract_term (
	terms_id	varchar2(40)	not null,
	terms	clob	null,
	disc_percent	number(19,7)	null,
	disc_days	integer	null,
	net_days	integer	null
,constraint dbc_contract_ter_p primary key (terms_id));





-- the source for this section is 
-- b2b_user_ddl.sql




-- Specific extensions for B2B user profiles

create table dbc_cost_center (
	id	varchar2(40)	not null,
	identifier	varchar2(40)	not null,
	description	varchar2(64)	null,
	user_id	varchar2(40)	null
,constraint dbc_cost_center_p primary key (id));


create table dbc_user (
	id	varchar2(40)	not null,
	price_list	varchar2(40)	null,
	user_catalog	varchar2(40)	null,
	user_role	integer	null,
	business_addr	varchar2(40)	null,
	dflt_shipping_addr	varchar2(40)	null,
	dflt_billing_addr	varchar2(40)	null,
	dflt_payment_type	varchar2(40)	null,
	dflt_cost_center	varchar2(40)	null,
	order_price_limit	number(19,7)	null,
	approval_required	number(1,0)	null
,constraint dbc_user_p primary key (id)
,constraint dbc_usrdflt_cos_f foreign key (dflt_cost_center) references dbc_cost_center (id)
,constraint dbc_usrbusnss_d_f foreign key (business_addr) references dps_contact_info (id)
,constraint dbc_usrdflt_bil_f foreign key (dflt_billing_addr) references dps_contact_info (id)
,constraint dbc_usrdflt_shi_f foreign key (dflt_shipping_addr) references dps_contact_info (id)
,constraint dbc_usrdflt_pay_f foreign key (dflt_payment_type) references dps_credit_card (id)
,constraint dbc_usrid_f foreign key (id) references dps_user (id));

create index usr_defcstctr_idx on dbc_user (dflt_cost_center);
create index dbc_usr_busnes_adr on dbc_user (business_addr);
create index dbc_usrdfltblngadr on dbc_user (dflt_billing_addr);
create index dbc_usrdfltshp_adr on dbc_user (dflt_shipping_addr);
create index dbc_usrdfltpymntty on dbc_user (dflt_payment_type);

create table dbc_buyer_costctr (
	user_id	varchar2(40)	not null,
	seq	integer	not null,
	cost_center_id	varchar2(40)	not null
,constraint dbc_buyer_costct_p primary key (user_id,seq)
,constraint dbc_buyrcost_cnt_f foreign key (cost_center_id) references dbc_cost_center (id));

create index dbc_byr_costctr_id on dbc_buyer_costctr (cost_center_id);
-- Multi-table associating a Buyer with one or more order approvers.  Approvers are required to be registered users of the site so they can perform online approvals.

create table dbc_buyer_approver (
	user_id	varchar2(40)	not null,
	approver_id	varchar2(40)	not null,
	seq	integer	not null
,constraint dbc_buyer_approv_p primary key (user_id,seq)
,constraint dbc_buyrapprvr_d_f foreign key (approver_id) references dps_user (id)
,constraint dbc_buyrusr_d_f foreign key (user_id) references dps_user (id));

create index buyer_approver_idx on dbc_buyer_approver (approver_id);

create table dbc_buyer_payment (
	user_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	payment_id	varchar2(40)	not null
,constraint dbc_buyer_paymen_p primary key (user_id,tag)
,constraint dbc_buyrpaymnt_d_f foreign key (payment_id) references dps_credit_card (id)
,constraint dbc_brpymntusr_d_f foreign key (user_id) references dps_user (id));

create index dbc_byr_pymnt_id on dbc_buyer_payment (payment_id);

create table dbc_buyer_shipping (
	user_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	addr_id	varchar2(40)	not null
,constraint dbc_buyer_shippi_p primary key (user_id,tag)
,constraint dbc_buyraddr_d_f foreign key (addr_id) references dps_contact_info (id)
,constraint dbc_buyrshpusr_d_f foreign key (user_id) references dps_user (id));

create index dbc_byr_shpng_addr on dbc_buyer_shipping (addr_id);

create table dbc_buyer_billing (
	user_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	addr_id	varchar2(40)	not null
,constraint dbc_buyer_billin_p primary key (user_id,tag)
,constraint dbc_buyrblladdr_f foreign key (addr_id) references dps_contact_info (id)
,constraint dbc_buyrbllusr_d_f foreign key (user_id) references dps_user (id));

create index dbc_byr_biladdr_id on dbc_buyer_billing (addr_id);

create table dbc_buyer_prefvndr (
	user_id	varchar2(40)	not null,
	vendor	varchar2(100)	not null,
	seq	integer	not null
,constraint dbc_buyer_prefvn_p primary key (user_id,seq)
,constraint dbc_byrprfndusrd_f foreign key (user_id) references dps_user (id));


create table dbc_buyer_plist (
	user_id	varchar2(40)	not null,
	list_id	varchar2(40)	not null,
	tag	integer	not null
,constraint dbc_buyer_plist_p primary key (user_id,tag));





-- the source for this section is 
-- organization_ddl.sql





create table dbc_organization (
	id	varchar2(40)	not null,
	type	integer	null,
	cust_type	integer	null,
	duns_number	varchar2(20)	null,
	dflt_shipping_addr	varchar2(40)	null,
	dflt_billing_addr	varchar2(40)	null,
	dflt_payment_type	varchar2(40)	null,
	dflt_cost_center	varchar2(40)	null,
	order_price_limit	number(19,7)	null,
	contract_id	varchar2(40)	null,
	approval_required	number(1,0)	null
,constraint dbc_organization_p primary key (id)
,constraint dbc_orgncontrct__f foreign key (contract_id) references dbc_contract (contract_id)
,constraint dbc_orgndflt_bil_f foreign key (dflt_billing_addr) references dps_contact_info (id)
,constraint dbc_orgndflt_shi_f foreign key (dflt_shipping_addr) references dps_contact_info (id)
,constraint dbc_orgndflt_pay_f foreign key (dflt_payment_type) references dps_credit_card (id)
,constraint dbc_orgnztnid_f foreign key (id) references dps_organization (org_id));

create index dbc_org_cntrct_id on dbc_organization (contract_id);
create index dbc_orgdfltblig_ad on dbc_organization (dflt_billing_addr);
create index dbc_orgdflt_shpadr on dbc_organization (dflt_shipping_addr);
create index dbc_orgdflt_pmttyp on dbc_organization (dflt_payment_type);
create index dbc_orgdfltcst_ctr on dbc_organization (dflt_cost_center);

create table dbc_org_contact (
	org_id	varchar2(40)	not null,
	contact_id	varchar2(40)	not null,
	seq	integer	not null
,constraint dbc_org_contact_p primary key (org_id,seq)
,constraint dbc_orgccontct_d_f foreign key (contact_id) references dps_contact_info (id)
,constraint dbc_orgcorg_d_f foreign key (org_id) references dps_organization (org_id));

create index dbc_org_cntct_id on dbc_org_contact (contact_id);
-- Multi-table associating an Organization with one or more order approvers.  Like administrators, approvers are required to be registered users of the site so they can perform online approvals.

create table dbc_org_approver (
	org_id	varchar2(40)	not null,
	approver_id	varchar2(40)	not null,
	seq	integer	not null
,constraint dbc_org_approver_p primary key (org_id,seq)
,constraint dbc_orgporg_d_f foreign key (org_id) references dps_organization (org_id)
,constraint dbc_orgpapprvr_d_f foreign key (approver_id) references dps_user (id));

create index org_approver_idx on dbc_org_approver (approver_id);
-- Multi-table associating an Organization with one or more costcenters that are pre-approved for use by members of the organization.  

create table dbc_org_costctr (
	org_id	varchar2(40)	not null,
	cost_center	varchar2(40)	not null,
	seq	integer	not null
,constraint dbc_org_costctr_p primary key (org_id,seq)
,constraint dbc_ocstctrorgd_f foreign key (org_id) references dps_organization (org_id));

create index dbc_org_cstctr on dbc_org_costctr (cost_center);
-- Multi-table associating an Organization with one or more payment types that are pre-apprived for use by members of the organization.Right now we're just using credit cards here, but this will needto change to support more general payment types, including invoicing and purchase orders

create table dbc_org_payment (
	org_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	payment_id	varchar2(40)	not null
,constraint dbc_org_payment_p primary key (org_id,tag)
,constraint dbc_orgppaymnt_d_f foreign key (payment_id) references dps_credit_card (id)
,constraint dbc_orgpymntorg_f foreign key (org_id) references dps_organization (org_id));

create index dbc_org_pymnt_id on dbc_org_payment (payment_id);

create table dbc_org_shipping (
	org_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	addr_id	varchar2(40)	not null
,constraint dbc_org_shipping_p primary key (org_id,tag)
,constraint dbc_orgsaddr_d_f foreign key (addr_id) references dps_contact_info (id)
,constraint dbc_orgsorg_d_f foreign key (org_id) references dps_organization (org_id));

create index dbc_org_shpng_adr on dbc_org_shipping (addr_id);

create table dbc_org_billing (
	org_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	addr_id	varchar2(40)	not null
,constraint dbc_org_billing_p primary key (org_id,tag)
,constraint dbc_orgbaddr_d_f foreign key (addr_id) references dps_contact_info (id)
,constraint dbc_orgborg_d_f foreign key (org_id) references dps_organization (org_id));

create index dbc_org_billng_adr on dbc_org_billing (addr_id);

create table dbc_org_prefvndr (
	org_id	varchar2(40)	not null,
	vendor	varchar2(100)	not null,
	seq	integer	not null
,constraint dbc_org_prefvndr_p primary key (org_id,seq)
,constraint dbc_orgprfvndorg_f foreign key (org_id) references dps_organization (org_id));





-- the source for this section is 
-- reporting_views.sql




--        In the comments, the time periods indicated are calendar time, meaning that   
--        the current period should be calculated from the start of the calendar time period,   
--        rather than in real time.  For example, if it is Thursday, July 12,   
--        the most current row in a view calculating totals for a week    
--        would run from Sunday, July 8 - July 12, rather than July 5 - July 12.   
--        drpt_order gathers basic information about each order   
create or replace view drpt_order
as
select o.order_id as order_id, 
	o.submitted_date as submitted_date, 
	ai.amount as amount, 
	count(i.quantity) as distinct_items, 
	sum(i.quantity) as total_items,
	ba.state as state, 
	ba.country as country, 
	o.price_info as price_info
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcspp_pay_group pg, 
	dcspp_bill_addr ba
where o.order_id = i.order_ref 
	and o.price_info = ai.amount_info_id 
	and o.order_id = pg.order_ref
	and pg.payment_group_id = ba.payment_group_id
group by o.order_id, 
	o.submitted_date, 
	ai.amount, 
	ba.state, 
	ba.country,
	 o.price_info
         ;


--        drpt_cost_of_goods calculates the total wholesale cost   
--        of the items purchased in each order   
create or replace view drpt_cost_of_goods
as
select i.order_ref as order_id, 
	sum(i.quantity * s.wholesale_price) as cost_of_goods
from dcspp_item i, 
	dcs_sku s
where i.catalog_ref_id = s.sku_id
group by i.order_ref
         ;


--        drpt_discount calculates the total amount discounted   
--        from each order via promotions   
create or replace view drpt_discount
as
select o.order_id as order_id, 
	o.submitted_date as submitted_date, 
	(0 - sum(pa.adjustment)) as discount
from dcspp_order o, 
	dcspp_item i, 
	dcspp_amtinfo_adj aa, 
	dcspp_price_adjust pa
where o.order_id = i.order_ref 
	and i.price_info = aa.amount_info_id 
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model is not null
group by o.order_id, 
	o.submitted_date
         ;


--        drptw_discounts calculates the number of orders that   
--        were discounted by promotions over each week   
--        The "UNION" operation allows weeks in which there   
--        were no discounts to have a row in the view   
create or replace view drptw_discounts
as
select trunc(submitted_date, 'DAY') as week, 
	count(order_id) as num_of_discounts
from drpt_discount
group by trunc(submitted_date, 'DAY')
UNION
select trunc(submitted_date, 'DAY') as week, 
	0 as num_of_discounts
from dcspp_order 
where trunc(submitted_date, 'DAY') not in (select trunc(submitted_date, 'DAY') from drpt_discount)
         ;


--        drptm_discounts calculates the number of orders that   
--        were discounted by promotions over each month   
--        The "UNION" operation allows months in which there   
--        were no discounts to have a row in the view   
create or replace view drptm_discounts
as
select trunc(submitted_date, 'MON') as month, 
	count(order_id) as num_of_discounts
from drpt_discount
group by trunc(submitted_date, 'MON')
UNION
select trunc(submitted_date, 'MON') as month, 
	0 as num_of_discounts
from dcspp_order 
where trunc(submitted_date, 'MON') not in (select trunc(submitted_date, 'MON') from drpt_discount)
         ;


--        drptq_discounts calculates the number of orders that   
--        were discounted by promotions over each quarter   
--        The "UNION" operation allows quarters in which there   
--        were no discounts to have a row in the view   
create or replace view drptq_discounts
as
select trunc(submitted_date, 'Q') as quarter, 
	count(order_id) as num_of_discounts
from drpt_discount
group by trunc(submitted_date, 'Q')
UNION
select trunc(submitted_date, 'Q') as quarter, 
	0 as num_of_discounts
from dcspp_order 
where trunc(submitted_date, 'Q') not in (select trunc(submitted_date, 'Q') from drpt_discount)
         ;


--        drpta_discounts calculates the number of orders that   
--        were discounted by promotions over each year   
--        The "UNION" operation allows years in which there   
--        were no discounts to have a row in the view   
create or replace view drpta_discounts
as
select trunc(submitted_date, 'YEAR') as year, 
	count(order_id) as num_of_discounts
from drpt_discount
group by trunc(submitted_date, 'YEAR')
UNION
select trunc(submitted_date, 'YEAR') as year, 
	0 as num_of_discounts
from dcspp_order 
where trunc(submitted_date, 'YEAR') not in (select trunc(submitted_date, 'YEAR') from drpt_discount)
         ;


--        drpt_ordered_items comprises a list of each item purchased   
create or replace view drpt_ordered_items
as
select o.order_id as order_id, 
	o.submitted_date as submitted_date, 
	i.catalog_ref_id as catalog_ref_id,
	i.product_id as product_id, 
	i.quantity as quantity, 
	ai.amount as price
from dcspp_order o, 
	dcspp_item i, 
	dcspp_amount_info ai
where o.order_id = i.order_ref 
	and i.price_info = ai.amount_info_id
         ;


--        drpt_sku_stock calculates the number of unique skus in stock per product   
--        in the catalog.  The "UNION" operation exists so that a row will   
--        appear for products that have no skus in stock   
create or replace view drpt_sku_stock
as
select pc.product_id as product_id, 
	count(i.catalog_ref_id) as skus_in_stock
from dcs_prd_chldsku pc, 
	dcs_inventory i
where pc.sku_id = i.catalog_ref_id 
	and i.stock_level > 0
group by pc.product_id
UNION
select product_id, 
	0 as skus_in_stock 
from dcs_prd_chldsku 
where product_id not in 
(select product_id 
from dcs_prd_chldsku pc, 
	dcs_inventory i 
where pc.sku_id = i.catalog_ref_id 
	and i.stock_level > 0)
         ;


--        drptw_browses calculatess the number of times each product's page   
--        has been viewed online each week   
create or replace view drptw_browses
as
select repositoryid as product_id, 
	trunc(timestamp, 'DAY') as week, 
	count(timestamp) as browses
from dss_dps_view_item
group by repositoryid, 
	trunc(timestamp, 'DAY')
         ;


--        drptm_browses calculates the number of times each product's page   
--        has been viewed online each month   
create or replace view drptm_browses
as
select repositoryid as product_id, 
	trunc(timestamp, 'MON') as month, 
	count(timestamp) as browses
from dss_dps_view_item
group by repositoryid, 
	trunc(timestamp, 'MON')
         ;


--        drptq_browses calculates the number of times each product's page   
--        has been viewed online each quarter   
create or replace view drptq_browses
as
select repositoryid as product_id, 
	trunc(timestamp, 'Q') as quarter, 
	count(timestamp) as browses
from dss_dps_view_item
group by repositoryid, 
	trunc(timestamp, 'Q')
         ;


--        drpta_browses calculates the number of times each product's page   
--        has been viewed online each year   
create or replace view drpta_browses
as
select repositoryid as product_id, 
	trunc(timestamp, 'YEAR') as year, 
	count(timestamp) as browses
from dss_dps_view_item
group by repositoryid,
	trunc(timestamp, 'YEAR')
         ;


--        drptw_carts calculates the number of times each product has   
--        been added to a user's shopping cart each week   
--        Note:  A single user adding a quantity greater than one   
--        to their cart at one time is considered a single "add to cart"   
create or replace view drptw_carts
as
select pc.product_id as product_id, 
	trunc(ce.timestamp, 'DAY') as week, 
	count(ce.id) as adds_to_cart
from dcs_cart_event ce, 
	dcs_prd_chldsku pc
where ce.itemid = pc.sku_id
group by pc.product_id, 
	trunc(ce.timestamp, 'DAY')
         ;


--        drptm_carts calculates the number of times each product has   
--        been added to a user's shopping cart each month   
--        Note:  A single user adding a quantity greater than one   
--        to their cart at one time is considered a single "add to cart"   
create or replace view drptm_carts
as
select pc.product_id as product_id, 
	trunc(ce.timestamp, 'MON') as month, 
	count(ce.id) as adds_to_cart
from dcs_cart_event ce, 
	dcs_prd_chldsku pc
where ce.itemid = pc.sku_id
group by pc.product_id, 
	trunc(ce.timestamp, 'MON')
         ;


--        drptq_carts calculates the number of times each product has   
--        been added to a user's shopping cart each quarter   
--        Note:  A single user adding a quantity greater than one   
--        to their cart at one time is considered a single "add to cart"   
create or replace view drptq_carts
as
select pc.product_id as product_id, 
	trunc(ce.timestamp, 'Q') as quarter, 
	count(ce.id) as adds_to_cart
from dcs_cart_event ce, 
	dcs_prd_chldsku pc
where ce.itemid = pc.sku_id
group by pc.product_id, 
	trunc(ce.timestamp, 'Q')
         ;


--        drpta_carts calculates the number of times each product has   
--        been added to a user's shopping cart each year   
--        Note:  A single user adding a quantity greater than one   
--        to their cart at one time is considered a single "add to cart"   
create or replace view drpta_carts
as
select pc.product_id as product_id, 
	trunc(ce.timestamp, 'YEAR') as year, 
	count(ce.id) as adds_to_cart
from dcs_cart_event ce, 
	dcs_prd_chldsku pc
where ce.itemid = pc.sku_id
group by pc.product_id, 
	trunc(ce.timestamp, 'YEAR')
         ;


--        drpt_shipping compiles the total shipping cost for each shipping group   
create or replace view drpt_shipping
as
select o.order_id as order_id, 
	ai.amount as shipping_cost
from dcspp_order o, 
	dcspp_ship_group sg, 
	dcspp_amount_info ai
where o.order_id = sg.order_ref 
	and sg.price_info = ai.amount_info_id
         ;


--        drpt_taxes compiles the total tax cost for each order   
create or replace view drpt_taxes
as
select o.order_id as order_id, 
	ai.amount as tax
from dcspp_order o, 
	dcspp_amount_info ai
where o.tax_price_info = ai.amount_info_id
         ;


--        drpt_cancels compiles information about orders that failed or   
--        were cancelled   
create or replace view drpt_cancels
as
select o.order_id as order_id, 
	o.submitted_date as submitted_date,
	ai.amount as amount, 
	si.shipping_cost as shipping_cost,
	ti.tax as tax
from dcspp_order o, 
	dcspp_amount_info ai, 
	drpt_shipping si, 
	drpt_taxes ti
where (o.state = 'FAILED' or o.state = 'REMOVED') 
	and o.price_info = ai.amount_info_id
	and o.order_id = si.order_id 
	and o.order_id = ti.order_id
         ;


--        drptw_cancels calculates the number of orders that failed or   
--        were cancelled each week.  It also calculates the total   
--        amount, shipping costs, and tax costs from those orders.   
create or replace view drptw_cancels
as
select trunc(submitted_date, 'DAY') as week, 
	count(order_id) as number_of_cancels,
	sum(amount) as amount, 
	sum(shipping_cost) as shipping_cost, 
	sum(tax) as tax
from drpt_cancels
group by trunc(submitted_date, 'DAY')
UNION
select trunc(submitted_date, 'DAY') as week, 
	0 as number_of_cancels, 
	0 as amount,
	0 as shipping_cost, 
	0 as tax
from dcspp_order
where trunc(submitted_date, 'DAY') not in (select trunc(submitted_date, 'DAY') from drpt_cancels)
group by trunc(submitted_date, 'DAY')
         ;


--        drptm_cancels calculates the number of orders that failed or   
--        were cancelled each month.  It also calculates the total   
--        amount, shipping costs, and tax costs from those orders.   
create or replace view drptm_cancels
as
select trunc(submitted_date, 'MON') as month, 
	count(order_id) as number_of_cancels,
	sum(amount) as amount, 
	sum(shipping_cost) as shipping_cost, 
	sum(tax) as tax
from drpt_cancels
group by trunc(submitted_date, 'MON')
UNION
select trunc(submitted_date, 'MON') as month, 
	0 as number_of_cancels, 
	0 as amount,
	0 as shipping_cost, 
	0 as tax
from dcspp_order
where trunc(submitted_date, 'MON') not in (select trunc(submitted_date, 'MON') from drpt_cancels)
group by trunc(submitted_date, 'MON')
         ;


--        drptq_cancels calculates the number of orders that failed or   
--        were cancelled each quarter.  It also calculates the total   
--        amount, shipping costs, and tax costs from those orders.   
create or replace view drptq_cancels
as
select trunc(submitted_date, 'Q') as quarter, 
	count(order_id) as number_of_cancels,
	sum(amount) as amount, 
	sum(shipping_cost) as shipping_cost, 
	sum(tax) as tax
from drpt_cancels
group by trunc(submitted_date, 'Q')
UNION
select trunc(submitted_date, 'Q') as quarter, 
	0 as number_of_cancels, 
	0 as amount,
	0 as shipping_cost, 
	0 as tax
from dcspp_order
where trunc(submitted_date, 'Q') not in (select trunc(submitted_date, 'Q') from drpt_cancels)
group by trunc(submitted_date, 'Q')
         ;


--        drpta_cancels calculates the number of orders that failed or   
--        were cancelled in the past year.  It also calculates the total   
--        amount, shipping costs, and tax costs from those orders.   
create or replace view drpta_cancels
as
select trunc(submitted_date, 'YEAR') as year, 
	count(order_id) as number_of_cancels,
	sum(amount) as amount, 
	sum(shipping_cost) as shipping_cost, 
	sum(tax) as tax
from drpt_cancels
group by trunc(submitted_date, 'YEAR')
UNION
select trunc(submitted_date, 'YEAR') as year, 
	0 as number_of_cancels, 
	0 as amount,
	0 as shipping_cost, 
	0 as tax
from dcspp_order
where trunc(submitted_date, 'YEAR') not in (select trunc(submitted_date, 'YEAR') from drpt_cancels)
group by trunc(submitted_date, 'YEAR')
         ;


--        drptw_gift_certs calculates the number of gift certificates   
--        that were redeemed each week   
create or replace view drptw_gift_certs
as
select trunc(o.submitted_date, 'DAY') as week, 
	count(gc.payment_group_id) as num_of_gift_certs
from dcspp_order o, 
	dcspp_pay_group pg, 
	dcspp_gift_cert gc
where o.order_id = pg.order_ref 
	and pg.payment_group_id = gc.payment_group_id
group by trunc(o.submitted_date, 'DAY')
UNION
select trunc(submitted_date, 'DAY') as week, 
	0 as num_of_gift_certs
from dcspp_order
where order_id not in 
(select pg.order_ref 
from dcspp_pay_group pg, 
	dcspp_gift_cert gc 
where pg.payment_group_id = gc.payment_group_id)
group by trunc(submitted_date, 'DAY')
         ;


--        drptm_gift_certs calculates the number of gift certificates   
--        that were redeemed each month   
create or replace view drptm_gift_certs
as
select trunc(o.submitted_date, 'MON') as month, 
	count(gc.payment_group_id) as num_of_gift_certs
from dcspp_order o, 
	dcspp_pay_group pg, 
	dcspp_gift_cert gc
where o.order_id = pg.order_ref 
	and pg.payment_group_id = gc.payment_group_id
group by trunc(o.submitted_date, 'MON')
UNION
select trunc(submitted_date, 'MON') as month, 
	0 as num_of_gift_certs
from dcspp_order
where order_id not in 
(select pg.order_ref 
from dcspp_pay_group pg, 
	dcspp_gift_cert gc 
where pg.payment_group_id = gc.payment_group_id)
group by trunc(submitted_date, 'MON')
         ;


--        drptq_gift_certs calculates the number of gift certificates   
--        that were redeemed each quarter   
create or replace view drptq_gift_certs
as
select trunc(o.submitted_date, 'Q') as quarter, 
	count(gc.payment_group_id) as num_of_gift_certs
from dcspp_order o, 
	dcspp_pay_group pg, 
	dcspp_gift_cert gc
where o.order_id = pg.order_ref 
	and pg.payment_group_id = gc.payment_group_id
group by trunc(o.submitted_date, 'Q')
UNION
select trunc(submitted_date, 'Q') as quarter, 
	0 as num_of_gift_certs
from dcspp_order
where order_id not in 
(select pg.order_ref 
from dcspp_pay_group pg, 
	dcspp_gift_cert gc 
where pg.payment_group_id = gc.payment_group_id)
group by trunc(submitted_date, 'Q')
         ;


--        drpta_gift_certs calculates the number of gift certificates   
--        that were redeemed each year   
create or replace view drpta_gift_certs
as
select trunc(o.submitted_date, 'YEAR') as year, 
	count(gc.payment_group_id) as num_of_gift_certs
from dcspp_order o, 
	dcspp_pay_group pg, 
	dcspp_gift_cert gc
where o.order_id = pg.order_ref 
	and pg.payment_group_id = gc.payment_group_id
group by trunc(o.submitted_date, 'YEAR')
UNION
select trunc(submitted_date, 'YEAR') as year, 
	0 as num_of_gift_certs
from dcspp_order
where order_id not in 
(select pg.order_ref 
from dcspp_pay_group pg, 
	dcspp_gift_cert gc 
where pg.payment_group_id = gc.payment_group_id)
group by trunc(submitted_date, 'YEAR')
         ;


--        drptw_orders calculates various totals from orders over each week   
create or replace view drptw_orders
as
select trunc(dri.submitted_date, 'DAY') as week, 
	(sum(ai.amount) + sum(si.shipping_cost) + sum(ti.tax)) as total_dollar_sales,
	(wct.amount + wct.shipping_cost + wct.tax) as dollar_cancels,
	(sum(ai.amount) - wct.amount) as merch_rev,
	(sum(si.shipping_cost) + sum(ti.tax) - wct.shipping_cost - wct.tax) as shipping_tax_rev,
	sum(cog.cost_of_goods) as cost_of_goods_sold,
	(count(dri.order_id)) as number_of_orders, 
	(wct.number_of_cancels) as cancelled_orders,
	(count(dri.order_id) - wct.number_of_cancels) as net_num_of_orders,
	sum(dri.total_items) as total_units_sold,
	wdt.num_of_discounts as num_of_discounts,
	wgct.num_of_gift_certs as num_of_gift_certs
from dcspp_amount_info ai, 
	drpt_shipping si, 
	drpt_taxes ti,
	drptw_cancels wct, 
	drptw_discounts wdt,
	drptw_gift_certs wgct, 
	drpt_order dri, 
	drpt_cost_of_goods cog
where dri.price_info = ai.amount_info_id 
	and dri.order_id = si.order_id 
	and dri.order_id = ti.order_id 
	and trunc(dri.submitted_date, 'DAY') = wct.week 
	and trunc(dri.submitted_date, 'DAY') = wdt.week 
	and trunc(dri.submitted_date, 'DAY') = wgct.week 
	and dri.order_id = cog.order_id
group by trunc(dri.submitted_date, 'DAY'), 
	wct.number_of_cancels, 
	wct.amount, 
	wct.shipping_cost, 
	wct.tax, 
	wdt.num_of_discounts, 
	wgct.num_of_gift_certs
         ;


--        drptm_orders calculates various totals from orders over each month   
create or replace view drptm_orders
as
select trunc(dri.submitted_date, 'MON') as month, 
	(sum(ai.amount) + sum(si.shipping_cost) + sum(ti.tax)) as total_dollar_sales,
	(mct.amount + mct.shipping_cost + mct.tax) as dollar_cancels,
	(sum(ai.amount) - mct.amount) as merch_rev,
	(sum(si.shipping_cost) + sum(ti.tax) - mct.shipping_cost - mct.tax) as shipping_tax_rev,
	sum(cog.cost_of_goods) as cost_of_goods_sold,
	(count(dri.order_id)) as number_of_orders, 
	(mct.number_of_cancels) as cancelled_orders,
	(count(dri.order_id) - mct.number_of_cancels) as net_num_of_orders,
	sum(dri.total_items) as total_units_sold,
	mdt.num_of_discounts as num_of_discounts,
	mgct.num_of_gift_certs as num_of_gift_certs
from dcspp_amount_info ai, 
	drpt_shipping si, 
	drpt_taxes ti,
	drptm_cancels mct, 
	drptm_discounts mdt,
	drptm_gift_certs mgct, 
	drpt_order dri, 
	drpt_cost_of_goods cog
where dri.price_info = ai.amount_info_id 
	and dri.order_id = si.order_id 
	and dri.order_id = ti.order_id 
	and trunc(dri.submitted_date, 'MON') = mct.month 
	and trunc(dri.submitted_date, 'MON') = mdt.month 
	and trunc(dri.submitted_date, 'MON') = mgct.month 
	and dri.order_id = cog.order_id
group by trunc(dri.submitted_date, 'MON'), 
	mct.number_of_cancels, mct.amount, 
	mct.shipping_cost, 
	mct.tax, 
	mdt.num_of_discounts, 
	mgct.num_of_gift_certs
         ;


--        drptq_orders calculates various totals from orders over each quarter   
create or replace view drptq_orders
as
select trunc(dri.submitted_date, 'Q') as quarter, 
	(sum(ai.amount) + sum(si.shipping_cost) + sum(ti.tax)) as total_dollar_sales,
	(qct.amount + qct.shipping_cost + qct.tax) as dollar_cancels,
	(sum(ai.amount) - qct.amount) as merch_rev,
	(sum(si.shipping_cost) + sum(ti.tax) - qct.shipping_cost - qct.tax) as shipping_tax_rev,
	sum(cog.cost_of_goods) as cost_of_goods_sold,
	(count(dri.order_id)) as number_of_orders, 
	(qct.number_of_cancels) as cancelled_orders,
	(count(dri.order_id) - qct.number_of_cancels) as net_num_of_orders,
	sum(dri.total_items) as total_units_sold,
	qdt.num_of_discounts as num_of_discounts,
	qgct.num_of_gift_certs as num_of_gift_certs
from dcspp_amount_info ai, 
	drpt_shipping si, 
	drpt_taxes ti,
	drptq_cancels qct, 
	drptq_discounts qdt,
	drptq_gift_certs qgct, 
	drpt_order dri, 
	drpt_cost_of_goods cog
where dri.price_info = ai.amount_info_id 
	and dri.order_id = si.order_id 
	and dri.order_id = ti.order_id 
	and trunc(dri.submitted_date, 'Q') = qct.quarter 
	and trunc(dri.submitted_date, 'Q') = qdt.quarter 
	and trunc(dri.submitted_date, 'Q') = qgct.quarter 
	and dri.order_id = cog.order_id
group by trunc(dri.submitted_date, 'Q'), 
	qct.number_of_cancels, 
	qct.amount, 
	qct.shipping_cost, 
	qct.tax, 
	qdt.num_of_discounts, 
	qgct.num_of_gift_certs
         ;


--        drpta_orders calculates various totals from orders over each year   
create or replace view drpta_orders
as
select trunc(dri.submitted_date, 'YEAR') as year, 
	(sum(ai.amount) + sum(si.shipping_cost) + sum(ti.tax)) as total_dollar_sales,
	(act.amount + act.shipping_cost + act.tax) as dollar_cancels,
	(sum(ai.amount) - act.amount) as merch_rev,
	(sum(si.shipping_cost) + sum(ti.tax) - act.shipping_cost - act.tax) as shipping_tax_rev,
	sum(cog.cost_of_goods) as cost_of_goods_sold,
	(count(dri.order_id)) as number_of_orders, 
	(act.number_of_cancels) as cancelled_orders,
	(count(dri.order_id) - act.number_of_cancels) as net_num_of_orders,
	sum(dri.total_items) as total_units_sold,
	adt.num_of_discounts as num_of_discounts,
	agct.num_of_gift_certs as num_of_gift_certs
from dcspp_amount_info ai, 
	drpt_shipping si, 
	drpt_taxes ti,
	drpta_cancels act, 
	drpta_discounts adt,
	drpta_gift_certs agct, 
	drpt_order dri, 
	drpt_cost_of_goods cog
where dri.price_info = ai.amount_info_id 
	and dri.order_id = si.order_id 
	and dri.order_id = ti.order_id 
	and trunc(dri.submitted_date, 'YEAR') = act.year 
	and trunc(dri.submitted_date, 'YEAR') = adt.year 
	and trunc(dri.submitted_date, 'YEAR') = agct.year 
	and dri.order_id = cog.order_id
group by trunc(dri.submitted_date, 'YEAR'), 
	act.number_of_cancels, 
	act.amount, 
	act.shipping_cost, 
	act.tax, 
	adt.num_of_discounts, 
	agct.num_of_gift_certs
         ;


create or replace view drpt_visitor
(profileid,day,state,country)
as
 select distinct 
	vi.profileid, 
	TRUNC(vi.timestamp, 'DATE') as day, 
	ci.state, 
	ci.country
from 
	dss_dps_view_item vi, 
	dps_user_address ua, 
	dps_contact_info ci
where 
	vi.profileid = ua.id 
	and ua.billing_addr_id = ci.id
         ;


--        drpt_cart calculates the total quantity and amount of   
--        items that have been added to shopping carts over each day   
create or replace view drpt_cart
(orderid,day,quantity,amount)
as
select 
	orderid as orderid, 
	trunc(timestamp) as day, 
	sum(quantity) as quantity, 
	sum(amount) as amount
from dcs_cart_event
group by orderid, 
	trunc(timestamp)
         ;


--        drptw_fiscal_info caclulates several revenue-related totals over each week   
create or replace view drptw_fiscal_info
as
select wot.week as week, 
	wot.total_dollar_sales as total_dollar_sales,
	wot.dollar_cancels as dollar_cancels, 
	(wot.total_dollar_sales - wot.dollar_cancels) as net_dollar_sales,
	wot.merch_rev as merch_rev,
	wot.shipping_tax_rev as shipping_tax_rev, 
	wot.number_of_orders as number_of_orders,
	wot.cancelled_orders as cancelled_orders, 
	wot.net_num_of_orders as net_num_of_orders,
	count(distinct ce.orderid) as num_of_carts, 
	((wot.total_dollar_sales - wot.dollar_cancels) / wot.net_num_of_orders) as avg_order_rev,
	(wot.merch_rev / wot.net_num_of_orders) as avg_order_merc_rev,
	count(distinct vi.sessionid) as number_of_shoppers,
	(wot.number_of_orders / count(distinct vi.sessionid)) as shop_to_purc_conv,
	(count(distinct ce.orderid) / count(distinct vi.sessionid)) as shop_to_cart_conv,
	(wot.number_of_orders / count(distinct ce.orderid)) as cart_to_purc_conv,
	wot.num_of_discounts as num_of_discounts, 
	wot.num_of_gift_certs as num_of_gift_certs
from drptw_orders wot, 
	dcs_cart_event ce, 
	dss_dps_view_item vi
where trunc(ce.timestamp, 'DAY') = wot.week 
	and trunc(vi.timestamp, 'DAY') = wot.week
group by wot.week, 
	wot.total_dollar_sales, 
	wot.dollar_cancels,
	wot.merch_rev, 
	wot.shipping_tax_rev, 
	wot.number_of_orders,
	wot.cancelled_orders, 
	wot.net_num_of_orders, 
	wot.num_of_discounts,
	wot.num_of_gift_certs
         ;


--        drptm_fiscal_info caclulates several revenue-related totals over each month   
create or replace view drptm_fiscal_info
as
select mot.month as month, 
	mot.total_dollar_sales as total_dollar_sales,
	mot.dollar_cancels as dollar_cancels, 
	(mot.total_dollar_sales - mot.dollar_cancels) as net_dollar_sales,
	mot.merch_rev as merch_rev,
	mot.shipping_tax_rev as shipping_tax_rev, 
	mot.number_of_orders as number_of_orders,
	mot.cancelled_orders as cancelled_orders, 
	mot.net_num_of_orders as net_num_of_orders,
	count(distinct ce.orderid) as num_of_carts, 
	((mot.total_dollar_sales - mot.dollar_cancels) / mot.net_num_of_orders) as avg_order_rev,
	(mot.merch_rev / mot.net_num_of_orders) as avg_order_merc_rev,
	count(distinct vi.sessionid) as number_of_shoppers,
	(mot.number_of_orders / count(distinct vi.sessionid)) as shop_to_purc_conv,
	(count(distinct ce.orderid) / count(distinct vi.sessionid)) as shop_to_cart_conv,
	(mot.number_of_orders / count(distinct ce.orderid)) as cart_to_purc_conv,
	mot.num_of_discounts as num_of_discounts, 
	mot.num_of_gift_certs as num_of_gift_certs
from drptm_orders mot, 
	dcs_cart_event ce, 
	dss_dps_view_item vi
where trunc(ce.timestamp, 'MON') = mot.month 
	and trunc(vi.timestamp, 'MON') = mot.month
group by mot.month, 
	mot.total_dollar_sales, 
	mot.dollar_cancels,
	mot.merch_rev, 
	mot.shipping_tax_rev, 
	mot.number_of_orders,
	mot.cancelled_orders, 
	mot.net_num_of_orders, 
	mot.num_of_discounts,
	mot.num_of_gift_certs
         ;


--        drptq_fiscal_info caclulates several revenue-related totals over each quarter   
create or replace view drptq_fiscal_info
as
select qot.quarter as quarter, 
	qot.total_dollar_sales as total_dollar_sales,
	qot.dollar_cancels as dollar_cancels, 
	(qot.total_dollar_sales - qot.dollar_cancels) as net_dollar_sales,
	qot.merch_rev as merch_rev,
	qot.shipping_tax_rev as shipping_tax_rev, 
	qot.number_of_orders as number_of_orders,
	qot.cancelled_orders as cancelled_orders, 
	qot.net_num_of_orders as net_num_of_orders,
	count(distinct ce.orderid) as num_of_carts, 
	((qot.total_dollar_sales - qot.dollar_cancels) / qot.net_num_of_orders) as avg_order_rev,
	(qot.merch_rev / qot.net_num_of_orders) as avg_order_merc_rev,
	count(distinct vi.sessionid) as number_of_shoppers,
	(qot.number_of_orders / count(distinct vi.sessionid)) as shop_to_purc_conv,
	(count(distinct ce.orderid) / count(distinct vi.sessionid)) as shop_to_cart_conv,
	(qot.number_of_orders / count(distinct ce.orderid)) as cart_to_purc_conv,
	qot.num_of_discounts as num_of_discounts, 
	qot.num_of_gift_certs as num_of_gift_certs
from drptq_orders qot, 
	dcs_cart_event ce, 
	dss_dps_view_item vi
where trunc(ce.timestamp, 'Q') = qot.quarter 
	and trunc(vi.timestamp, 'Q') = qot.quarter
group by qot.quarter, 
	qot.total_dollar_sales, 
	qot.dollar_cancels,
	qot.merch_rev, 
	qot.shipping_tax_rev, 
	qot.number_of_orders,
	qot.cancelled_orders, 
	qot.net_num_of_orders, 
	qot.num_of_discounts,
	qot.num_of_gift_certs
         ;


--        drpta_fiscal_info caclulates several revenue-related totals over each year   
create or replace view drpta_fiscal_info
as
select aot.year as year, 
	aot.total_dollar_sales as total_dollar_sales,
	aot.dollar_cancels as dollar_cancels, 
	(aot.total_dollar_sales - aot.dollar_cancels) as net_dollar_sales,
	aot.merch_rev as merch_rev,
	aot.shipping_tax_rev as shipping_tax_rev,
	aot.number_of_orders as number_of_orders,
	aot.cancelled_orders as cancelled_orders, 
	aot.net_num_of_orders as net_num_of_orders,
	count(distinct ce.orderid) as num_of_carts, 
	((aot.total_dollar_sales - aot.dollar_cancels) / aot.net_num_of_orders) as avg_order_rev,
	(aot.merch_rev / aot.net_num_of_orders) as avg_order_merc_rev,
	count(distinct vi.sessionid) as number_of_shoppers,
	(aot.number_of_orders / count(distinct vi.sessionid)) as shop_to_purc_conv,
	(count(distinct ce.orderid) / count(distinct vi.sessionid)) as shop_to_cart_conv,
	(aot.number_of_orders / count(distinct ce.orderid)) as cart_to_purc_conv,
	aot.num_of_discounts as num_of_discounts, 
	aot.num_of_gift_certs as num_of_gift_certs
from drpta_orders aot, 
	dcs_cart_event ce, 
	dss_dps_view_item vi
where trunc(ce.timestamp, 'YEAR') = aot.year 
	and trunc(vi.timestamp, 'YEAR') = aot.year
group by aot.year, 
	aot.total_dollar_sales, 
	aot.dollar_cancels,
	aot.merch_rev, 
	aot.shipping_tax_rev, 
	aot.number_of_orders,
	aot.cancelled_orders, 
	aot.net_num_of_orders, 
	aot.num_of_discounts,
	aot.num_of_gift_certs
         ;


--        drptw_promotion calculates totals about orders that were discounted   
--        by the sample 'promo60003' promotion over each week   
create or replace view drptw_promotion
as
select trunc(o.submitted_date, 'DAY') as week, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'DAY')
         ;


--        drptm_promotion calculates totals about orders that were discounted   
--        by the sample 'promo60003' promotion over each month   
create or replace view drptm_promotion
as
select trunc(o.submitted_date, 'MON') as month, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'MON')
         ;


--        drptq_promotion calculates totals about orders that were discounted   
--        by the sample 'promo60003' promotion over each quarter   
create or replace view drptq_promotion
as
select trunc(o.submitted_date, 'Q') as quarter, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'Q')
         ;


--        drpta_promotion calculates totals about orders that were discounted   
--        by the sample 'promo60003' promotion over each year   
create or replace view drpta_promotion
as
select trunc(o.submitted_date, 'YEAR') as year, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'YEAR')
         ;


--        drptw_male_18_25 calculates totals about orders that were placed   
--        each week by males aged 18-25   
create or replace view drptw_male_18_25
as
select trunc(o.submitted_date, 'DAY') as week, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25)
group by trunc(o.submitted_date, 'DAY')
         ;


--        drptm_male_18_25 calculates totals about orders that were placed   
--        each month by males aged 18-25   
create or replace view drptm_male_18_25
as
select trunc(o.submitted_date, 'MON') as month, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25) 
group by trunc(o.submitted_date, 'MON')
         ;


--        drptq_male_18_25 calculates totals about orders that were placed   
--        each quarter by males aged 18-25   
create or replace view drptq_male_18_25
as
select trunc(o.submitted_date, 'Q') as quarter, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25) 
group by trunc(o.submitted_date, 'Q')
         ;


--        drpta_male_18_25 calculates totals about orders that were placed   
--        each year by males aged 18-25   
create or replace view drpta_male_18_25
as
select trunc(o.submitted_date, 'YEAR') as year, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25) 
group by trunc(o.submitted_date, 'YEAR')
         ;


--        drptw_male_25_39 calculates totals about orders that were placed   
--        each week by males aged 25-39   
create or replace view drptw_male_25_39
as
select trunc(o.submitted_date, 'DAY') as week, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39)
group by trunc(o.submitted_date, 'DAY')
         ;


--        drptm_male_25_39 calculates totals about orders that were placed   
--        each month by males aged 25-39   
create or replace view drptm_male_25_39
as
select trunc(o.submitted_date, 'MON') as month, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39) 
group by trunc(o.submitted_date, 'MON')
         ;


--        drptq_male_25_39 calculates totals about orders that were placed   
--        each quarter by males aged 25-39   
create or replace view drptq_male_25_39
as
select trunc(o.submitted_date, 'Q') as quarter, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39) 
group by trunc(o.submitted_date, 'Q')
         ;


--        drpta_male_25_39 calculates totals about orders that were placed   
--        each year by males aged 25-39   
create or replace view drpta_male_25_39
as
select trunc(o.submitted_date, 'YEAR') as year, 
	sum(ai.amount) as total_dollar_sales,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	count(o.order_id) as number_of_orders, 
	sum(i.quantity) as total_units_sold
from dcspp_order o, 
	dcspp_amount_info ai, 
	dcspp_item i, 
	dcs_sku s, 
	dps_user u
where o.price_info = ai.amount_info_id 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED' 
	and o.order_id = i.order_ref 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39) 
group by trunc(o.submitted_date, 'YEAR')
         ;




-- the source for this section is 
-- custom_catalog_reporting.sql




--        new drpt_products compiles information about each product in the catalog new   
create or replace view drpt_products
as
select p.product_id as product_id, 
	'N/A' as category_name,
	avg(s.wholesale_price) as avg_cost, 
	avg(s.list_price) as avg_list_price, 
	avg(s.sale_price) as avg_sale_price, 
	((avg(s.list_price) - avg(s.wholesale_price)) / avg(s.wholesale_price)) as avg_initial_markup, 
	sum(inv.stock_level) as units_on_hand, 
	count(s.sku_id) as number_of_skus
from dcs_product p, 
	dcs_sku s, 
	dcs_prd_chldsku pc, 
	dcs_inventory inv
where p.product_id = pc.product_id 
	and pc.sku_id = s.sku_id
	and pc.sku_id = inv.catalog_ref_id
group by p.product_id
         ;


--        new drpt_category calculates statistics about prices and costs on a per-category basis  new   
create or replace view drpt_category
as
select ctlg.display_name as catalog_name, 
	c.display_name as category_name, 
	c.category_id as category_id,
	avg(s.wholesale_price)as avg_cost,
	avg(s.list_price) as avg_list_price,
	avg(s.sale_price) as avg_sale_price,
	((avg(s.list_price) - avg(s.wholesale_price)) / avg(s.wholesale_price)) as avg_initial_markup,
	sum(inv.stock_level) as units_on_hand, 
	count(s.sku_id) as number_of_skus
from dcs_catalog ctlg, 
	dcs_category c, 
	dcs_sku s, 
	dcs_prd_chldsku pc, 
	dcs_product_info pi,
	dcs_prd_prdinfo ppi, 
	dcs_inventory inv
where c.category_id = pi.parent_cat_id 
	and pc.product_id = ppi.product_id 
	and pc.sku_id = s.sku_id
	and ctlg.catalog_id = c.catalog_id 
	and pc.sku_id = s.sku_id 
	and ppi.catalog_id = ctlg.catalog_id 
	and ppi.product_info_id = pi.product_info_id 
	and pc.sku_id = inv.catalog_ref_id
group by c.display_name,
	ctlg.display_name, 
	c.category_id
         ;




-- the source for this section is 
-- reporting_views2.sql




--        drptw_prod_sales calculates several statistics over each week on a per-product basis    
-- drptw_prod_sales calculates several statistics over each week on a per-product basis    
create or replace view drptw_prod_sales
as
select trunc(o.submitted_date, 'DAY') as week, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / wot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price * i.quantity)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / wot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	wb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / wb.browses) as shop_to_purc_conv, 
	wc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / wc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptw_browses wb, 
	drptw_carts wc, 
	drpt_sku_stock si, 
	drptw_orders wot, 
	dcs_sku s
where o.order_id = i.order_ref 
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = wc.product_id 
	and i.product_id = wb.product_id 
	and trunc(o.submitted_date, 'DAY') = wb.week 
	and trunc(o.submitted_date, 'DAY') = wc.week 
	and si.product_id = i.product_id 
	and wot.week = trunc(o.submitted_date, 'DAY') 
	and i.catalog_ref_id = s.sku_id
group by trunc(o.submitted_date, 'DAY'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	wb.browses, 
	wc.adds_to_cart, 
	wot.total_units_sold,
	wot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock
         ;


--        drptm_prod_sales calculates several statistics over each month on a per-product basis    
create or replace view drptm_prod_sales
as
select trunc(o.submitted_date, 'MON') as month, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / mot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as months_on_hand,
	sum(ai.amount) as total_rev, 
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price * i.quantity)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / mot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	mb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / mb.browses) as shop_to_purc_conv, 
	mc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / mc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptm_browses mb, 
	drptm_carts mc, 
	drpt_sku_stock si, 
	drptm_orders mot, 
	dcs_sku s
where o.order_id = i.order_ref 
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = mc.product_id 
	and i.product_id = mb.product_id 
	and trunc(o.submitted_date, 'MON') = mb.month 
	and trunc(o.submitted_date, 'MON') = mc.month 
	and si.product_id = i.product_id 
	and mot.month = trunc(o.submitted_date, 'MON') 
	and i.catalog_ref_id = s.sku_id
group by trunc(o.submitted_date, 'MON'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup,
	pri.units_on_hand, 
	mb.browses, 
	mc.adds_to_cart, 
	mot.total_units_sold,
	mot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock
         ;


--        drptq_prod_sales calculates several statistics over each quarter on a per-product basis    
create or replace view drptq_prod_sales
as
select trunc(o.submitted_date, 'Q') as quarter, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / qot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as quarters_on_hand,
	sum(ai.amount) as total_rev, 
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price * i.quantity)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / qot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	qb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / qb.browses) as shop_to_purc_conv, 
	qc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / qc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptq_browses qb, 
	drptq_carts qc, 
	drpt_sku_stock si, 
	drptq_orders qot, 
	dcs_sku s
where o.order_id = i.order_ref 
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = qc.product_id 
	and i.product_id = qb.product_id 
	and trunc(o.submitted_date, 'Q') = qb.quarter 
	and trunc(o.submitted_date, 'Q') = qc.quarter 
	and si.product_id = i.product_id 
	and qot.quarter = trunc(o.submitted_date, 'Q') 
	and i.catalog_ref_id = s.sku_id
group by trunc(o.submitted_date, 'Q'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup,
	pri.units_on_hand, 
	qb.browses, 	
	qc.adds_to_cart, 
	qot.total_units_sold,
	qot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock
         ;


--        drpta_prod_sales calculates several statistics over each year on a per-product basis    
create or replace view drpta_prod_sales
as
select trunc(o.submitted_date, 'YEAR') as year, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / aot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as years_on_hand,
	sum(ai.amount) as total_rev, 
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price * i.quantity)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / aot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	ab.browses as browses, count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / ab.browses) as shop_to_purc_conv, 
	ac.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / ac.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drpta_browses ab, 
	drpta_carts ac, 
	drpt_sku_stock si, 
	drpta_orders aot, 
	dcs_sku s
where o.order_id = i.order_ref 
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = ac.product_id 
	and i.product_id = ab.product_id 
	and trunc(o.submitted_date, 'YEAR') = ab.year 
	and trunc(o.submitted_date, 'YEAR') = ac.year 
	and si.product_id = i.product_id 
	and aot.year = trunc(o.submitted_date, 'YEAR') 
	and i.catalog_ref_id = s.sku_id
group by trunc(o.submitted_date, 'YEAR'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup,
	pri.units_on_hand, 
	ab.browses, 
	ac.adds_to_cart, 
	aot.total_units_sold,
	aot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock
         ;


--        drptw_promo_sales calculates totals about products that were discounted   
--        by the sample 'promo60003' promotion over each week   
create or replace view drptw_promo_sales
as
select trunc(o.submitted_date, 'DAY') as week, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / wpt.total_units_sold) as promo_units_sold_p, 
	(sum(i.quantity) / wot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / wpt.total_dollar_sales) as promo_rev_p,
	(sum(ai.amount) / wot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	wb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / wb.browses) as shop_to_purc_conv, 
	wc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / wc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptw_browses wb, 
	drptw_carts wc, 
	drpt_sku_stock si, 
	drptw_orders wot, 
	dcs_sku s, 
	drptw_promotion wpt, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = wc.product_id 
	and i.product_id = wb.product_id 
	and trunc(o.submitted_date, 'DAY') = wb.week 
	and trunc(o.submitted_date, 'DAY') = wc.week 
	and si.product_id = i.product_id 
	and wot.week = trunc(o.submitted_date, 'DAY') 
	and wpt.week = trunc(o.submitted_date, 'DAY') 
	and i.catalog_ref_id = s.sku_id
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'DAY'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	wb.browses, 
	wc.adds_to_cart, 
	wot.total_units_sold, 
	wot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	wpt.total_units_sold, 
	wpt.total_dollar_sales
         ;


--        drptm_promo_sales calculates totals about products that were discounted   
--        by the sample 'promo60003' promotion over each month   
create or replace view drptm_promo_sales
as
select trunc(o.submitted_date, 'MON') as month, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / mpt.total_units_sold) as promo_units_sold_p, 
	(sum(i.quantity) / mot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as months_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / mpt.total_dollar_sales) as promo_rev_p,
	(sum(ai.amount) / mot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	mb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / mb.browses) as shop_to_purc_conv, 
	mc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / mc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptm_browses mb, 
	drptm_carts mc, 
	drpt_sku_stock si, 
	drptm_orders mot, 
	dcs_sku s, 
	drptm_promotion mpt, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = mc.product_id 
	and i.product_id = mb.product_id 
	and trunc(o.submitted_date, 'MON') = mb.month 
	and trunc(o.submitted_date, 'MON') = mc.month 
	and si.product_id = i.product_id 
	and mot.month = trunc(o.submitted_date, 'MON') 
	and mpt.month = trunc(o.submitted_date, 'MON') 
	and i.catalog_ref_id = s.sku_id
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'MON'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	mb.browses, 
	mc.adds_to_cart, 
	mot.total_units_sold, 
	mot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	mpt.total_units_sold, 
	mpt.total_dollar_sales
         ;


--        drptq_promo_sales calculates totals about products that were discounted   
--        by the sample 'promo60003' promotion over each quarter   
create or replace view drptq_promo_sales
as
select trunc(o.submitted_date, 'Q') as quarter, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / qpt.total_units_sold) as promo_units_sold_p, 
	(sum(i.quantity) / qot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as quarters_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / qpt.total_dollar_sales) as promo_rev_p,
	(sum(ai.amount) / qot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	qb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / qb.browses) as shop_to_purc_conv, 
	qc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / qc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptq_browses qb, 
	drptq_carts qc, 
	drpt_sku_stock si, 
	drptq_orders qot,
	dcs_sku s, 
	drptq_promotion qpt, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = qc.product_id 
	and i.product_id = qb.product_id 
	and trunc(o.submitted_date, 'Q') = qb.quarter 
	and trunc(o.submitted_date, 'Q') = qc.quarter 
	and si.product_id = i.product_id 
	and qot.quarter = trunc(o.submitted_date, 'Q') 
	and qpt.quarter = trunc(o.submitted_date, 'Q') 
	and i.catalog_ref_id = s.sku_id
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'Q'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	qb.browses, 
	qc.adds_to_cart, 
	qot.total_units_sold, 
	qot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	qpt.total_units_sold, 
	qpt.total_dollar_sales
         ;


--        drpta_promo_sales calculates totals about products that were discounted   
--        by the sample 'promo60003' promotion over each year   
create or replace view drpta_promo_sales
as
select trunc(o.submitted_date, 'YEAR') as year, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / apt.total_units_sold) as promo_units_sold_p, 
	(sum(i.quantity) / aot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as years_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / apt.total_dollar_sales) as promo_rev_p,
	(sum(ai.amount) / aot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	ab.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / ab.browses) as shop_to_purc_conv, 
	ac.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / ac.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drpta_browses ab, 
	drpta_carts ac, 
	drpt_sku_stock si, 
	drpta_orders aot, 
	dcs_sku s, 
	drpta_promotion apt, 
	dcspp_amtinfo_adj aa,
	dcspp_price_adjust pa
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = ac.product_id 
	and i.product_id = ab.product_id 
	and trunc(o.submitted_date, 'YEAR') = ab.year 
	and trunc(o.submitted_date, 'YEAR') = ac.year 
	and si.product_id = i.product_id 
	and aot.year = trunc(o.submitted_date, 'YEAR') 
	and apt.year = trunc(o.submitted_date, 'YEAR') 
	and i.catalog_ref_id = s.sku_id
	and i.price_info = aa.amount_info_id 
	and aa.adjustments = pa.adjustment_id 
	and pa.pricing_model = 'promo60003'
group by trunc(o.submitted_date, 'YEAR'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	ab.browses, 
	ac.adds_to_cart, 
	aot.total_units_sold, 
	aot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	apt.total_units_sold, 
	apt.total_dollar_sales
         ;


--        drptw_m_18_25_sales calculates totals about products that were purchased   
--        by males aged 18-25 each week   
create or replace view drptw_m18_25_sales
as
select trunc(o.submitted_date, 'DAY') as week, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / wpt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / wot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / wpt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / wot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	wb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / wb.browses) as shop_to_purc_conv, 
	wc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / wc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptw_browses wb, 
	drptw_carts wc, 
	drpt_sku_stock si, 
	drptw_orders wot, 
	dcs_sku s, 
	drptw_male_18_25 wpt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = wc.product_id 
	and i.product_id = wb.product_id 
	and trunc(o.submitted_date, 'DAY') = wb.week 
	and trunc(o.submitted_date, 'DAY') = wc.week 
	and si.product_id = i.product_id 
	and wot.week = trunc(o.submitted_date, 'DAY') 
	and wpt.week = trunc(o.submitted_date, 'DAY') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25)
group by trunc(o.submitted_date, 'DAY'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	wb.browses, 
	wc.adds_to_cart, 
	wot.total_units_sold, 
	wot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	wpt.total_units_sold, 
	wpt.total_dollar_sales
         ;


--        drptm_m_18_25_sales calculates totals about products that were purchased   
--        by males aged 18-25 each month   
create or replace view drptm_m18_25_sales
as
select trunc(o.submitted_date, 'MON') as month, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / mpt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / mot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as months_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / mpt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / mot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	mb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / mb.browses) as shop_to_purc_conv, 
	mc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / mc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptm_browses mb, 
	drptm_carts mc, 
	drpt_sku_stock si, 
	drptm_orders mot, 
	dcs_sku s, 
	drptm_male_18_25 mpt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = mc.product_id 
	and i.product_id = mb.product_id 
	and trunc(o.submitted_date, 'MON') = mb.month 
	and trunc(o.submitted_date, 'MON') = mc.month 
	and si.product_id = i.product_id 
	and mot.month = trunc(o.submitted_date, 'MON') 
	and mpt.month = trunc(o.submitted_date, 'MON') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25)
group by trunc(o.submitted_date, 'MON'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	mb.browses, 
	mc.adds_to_cart, 
	mot.total_units_sold, 
	mot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	mpt.total_units_sold, 
	mpt.total_dollar_sales
         ;


--        drptq_m_18_25_sales calculates totals about products that were purchased   
--        by males aged 18-25 each quarter   
create or replace view drptq_m18_25_sales
as
select trunc(o.submitted_date, 'Q') as quarter, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / qpt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / qot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as quarters_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / qpt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / qot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	qb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / qb.browses) as shop_to_purc_conv, 
	qc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / qc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptq_browses qb, 
	drptq_carts qc, 
	drpt_sku_stock si, 
	drptq_orders qot, 
	dcs_sku s, 
	drptq_male_18_25 qpt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = qc.product_id 
	and i.product_id = qb.product_id 
	and trunc(o.submitted_date, 'Q') = qb.quarter 
	and trunc(o.submitted_date, 'Q') = qc.quarter 
	and si.product_id = i.product_id 
	and qot.quarter = trunc(o.submitted_date, 'Q') 
	and qpt.quarter = trunc(o.submitted_date, 'Q') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25)
group by trunc(o.submitted_date, 'Q'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	qb.browses, 
	qc.adds_to_cart, 
	qot.total_units_sold, 
	qot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	qpt.total_units_sold, 
	qpt.total_dollar_sales
         ;


--        drpta_m_18_25_sales calculates totals about products that were purchased   
--        by males aged 18-25 each year   
create or replace view drpta_m18_25_sales
as
select trunc(o.submitted_date, 'YEAR') as year, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / apt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / aot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as years_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / apt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / aot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	ab.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / ab.browses) as shop_to_purc_conv, 
	ac.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / ac.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drpta_browses ab, 
	drpta_carts ac, 
	drpt_sku_stock si, 
	drpta_orders aot, 
	dcs_sku s, 
	drpta_male_18_25 apt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = ac.product_id 
	and i.product_id = ab.product_id 
	and trunc(o.submitted_date, 'YEAR') = ab.year 
	and trunc(o.submitted_date, 'YEAR') = ac.year 
	and si.product_id = i.product_id 
	and aot.year = trunc(o.submitted_date, 'YEAR') 
	and apt.year = trunc(o.submitted_date, 'YEAR') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 18) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 25)
group by trunc(o.submitted_date, 'YEAR'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	ab.browses, 
	ac.adds_to_cart, 
	aot.total_units_sold, 
	aot.merch_rev,
	pri.number_of_skus, 
	si.skus_in_stock, 
	apt.total_units_sold, 
	apt.total_dollar_sales
         ;


--        drptw_m_25_39_sales calculates totals about products that were purchased   
--        by males aged 25-39 each week   
create or replace view drptw_m25_39_sales
as
select trunc(o.submitted_date, 'DAY') as week, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / wpt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / wot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / wpt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / wot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	wb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / wb.browses) as shop_to_purc_conv, 
	wc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / wc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptw_browses wb, 
	drptw_carts wc, 
	drpt_sku_stock si, 
	drptw_orders wot, 
	dcs_sku s, 
	drptw_male_25_39 wpt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = wc.product_id 
	and i.product_id = wb.product_id 
	and trunc(o.submitted_date, 'DAY') = wb.week 
	and trunc(o.submitted_date, 'DAY') = wc.week 
	and si.product_id = i.product_id 
	and wot.week = trunc(o.submitted_date, 'DAY') 
	and wpt.week = trunc(o.submitted_date, 'DAY') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39)
group by trunc(o.submitted_date, 'DAY'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	wb.browses, 
	wc.adds_to_cart, 
	wot.total_units_sold, 
	wot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	wpt.total_units_sold, 
	wpt.total_dollar_sales
         ;


--        drptm_m_25_39_sales calculates totals about products that were purchased   
--        by males aged 25-39 each month   
create or replace view drptm_m25_39_sales
as
select trunc(o.submitted_date, 'MON') as month, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / mpt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / mot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as months_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / mpt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / mot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	mb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / mb.browses) as shop_to_purc_conv, 
	mc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / mc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptm_browses mb, 
	drptm_carts mc, 
	drpt_sku_stock si, 
	drptm_orders mot, 
	dcs_sku s, 
	drptm_male_25_39 mpt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = mc.product_id 
	and i.product_id = mb.product_id 
	and trunc(o.submitted_date, 'MON') = mb.month 
	and trunc(o.submitted_date, 'MON') = mc.month 
	and si.product_id = i.product_id 
	and mot.month = trunc(o.submitted_date, 'MON') 
	and mpt.month = trunc(o.submitted_date, 'MON') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39)
group by trunc(o.submitted_date, 'MON'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	mb.browses, 
	mc.adds_to_cart, 
	mot.total_units_sold, 
	mot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	mpt.total_units_sold, 
	mpt.total_dollar_sales
         ;


--        drptq_m_25_39_sales calculates totals about products that were purchased   
--        by males aged 25-39 each quarter   
create or replace view drptq_m25_39_sales
as
select trunc(o.submitted_date, 'Q') as quarter, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / qpt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / qot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as quarters_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / qpt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / qot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	qb.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / qb.browses) as shop_to_purc_conv, 
	qc.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / qc.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drptq_browses qb, 
	drptq_carts qc, 
	drpt_sku_stock si, 
	drptq_orders qot, 
	dcs_sku s, 
	drptq_male_25_39 qpt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = qc.product_id 
	and i.product_id = qb.product_id 
	and trunc(o.submitted_date, 'Q') = qb.quarter 
	and trunc(o.submitted_date, 'Q') = qc.quarter 
	and si.product_id = i.product_id 
	and qot.quarter = trunc(o.submitted_date, 'Q') 
	and qpt.quarter = trunc(o.submitted_date, 'Q') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39)
group by trunc(o.submitted_date, 'Q'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	qb.browses, 
	qc.adds_to_cart, 
	qot.total_units_sold, 
	qot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	qpt.total_units_sold, 
	qpt.total_dollar_sales
         ;


--        drpta_m_25_39_sales calculates totals about products that were purchased   
--        by males aged 25-39 each year   
create or replace view drpta_m25_39_sales
as
select trunc(o.submitted_date, 'YEAR') as year, 
	i.product_id as product_id, 
	pri.category_name as category_name, 
	pri.avg_cost as avg_cost,
	pri.avg_list_price as avg_list_price, 
	pri.avg_sale_price as avg_sale_price, 
	pri.avg_initial_markup as avg_initial_markup,
	pri.units_on_hand as units_on_hand,
	sum(i.quantity) as units_sold, 
	(sum(i.quantity) / apt.total_units_sold) as demo_units_sold_p, 
	(sum(i.quantity) / aot.total_units_sold) as total_units_sold_p, 
	(pri.units_on_hand / sum(i.quantity)) as years_on_hand,
	sum(ai.amount) as total_rev,
	sum(s.wholesale_price * i.quantity) as cost_of_goods_sold,
	((sum(ai.amount) - sum(s.wholesale_price)) / sum(ai.amount)) as maintained_markup, 
	(sum(ai.amount) / apt.total_dollar_sales) as demo_rev_p,
	(sum(ai.amount) / aot.merch_rev) as total_rev_p,
	pri.number_of_skus as number_of_skus, 
	si.skus_in_stock as skus_in_stock,
	(si.skus_in_stock / pri.number_of_skus) as skus_in_stock_p,
	ab.browses as browses, 
	count(distinct i.order_ref) as browse_conversions,
	(count(distinct i.order_ref) / ab.browses) as shop_to_purc_conv, 
	ac.adds_to_cart as adds_to_cart, 
	count(i.order_ref) as cart_conversions, 
	(count(i.order_ref) / ac.adds_to_cart) as cart_to_purc_conv
from dcspp_order o, 
	dcspp_item i, 
	drpt_products pri, 
	dcspp_amount_info ai,
	drpta_browses ab, 
	drpta_carts ac, 
	drpt_sku_stock si, 
	drpta_orders aot, 
	dcs_sku s, 
	drpta_male_25_39 apt, 
	dps_user u
where o.order_id = i.order_ref 
	and o.state != 'FAILED' 
	and o.state != 'REMOVED'
	and i.product_id = pri.product_id 
	and i.price_info = ai.amount_info_id 
	and i.product_id = ac.product_id 
	and i.product_id = ab.product_id 
	and trunc(o.submitted_date, 'YEAR') = ab.year 
	and trunc(o.submitted_date, 'YEAR') = ac.year 
	and si.product_id = i.product_id 
	and aot.year = trunc(o.submitted_date, 'YEAR') 
	and apt.year = trunc(o.submitted_date, 'YEAR') 
	and i.catalog_ref_id = s.sku_id 
	and o.profile_id = u.id 
	and u.gender = 2 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 >= 25) 
	and (MONTHS_BETWEEN(o.submitted_date, u.date_of_birth)/12 < 39)
group by trunc(o.submitted_date, 'YEAR'), 
	i.product_id, 
	pri.category_name, 
	pri.avg_cost,
	pri.avg_list_price, 
	pri.avg_sale_price, 
	pri.avg_initial_markup, 
	pri.units_on_hand, 
	ab.browses, 
	ac.adds_to_cart, 
	aot.total_units_sold, 
	aot.merch_rev, 
	pri.number_of_skus, 
	si.skus_in_stock, 
	apt.total_units_sold, 	
	apt.total_dollar_sales
         ;




-- the source for this section is 
-- custom_catalog_reporting1.sql




--        new drptw_cat_sales calculates various statistics over each week on a per-category basis  new   
create or replace view drptw_cat_sales
as
select wps.week as week, 
	cri.catalog_name as catalog_name, 
	wps.category_name as category_name, 
	cri.avg_cost as avg_cost,
	cri.avg_list_price as avg_list_price, 
	cri.avg_sale_price as avg_sale_price,
	cri.avg_initial_markup as avg_initial_markup,
	sum(wps.units_sold) as units_sold, 
	sum(wps.total_rev) as total_rev,
	sum(wps.cost_of_goods_sold) as cost_of_goods_sold,
	((sum(wps.total_rev) - sum(wps.cost_of_goods_sold)) / sum(wps.total_rev)) as maintained_markup,
	(sum(wps.units_sold) / wot.total_units_sold) as total_units_sold_p,
	(sum(wps.total_rev) / wot.merch_rev) as total_rev_p, 
	cri.units_on_hand as units_on_hand,
	(cri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(wps.number_of_skus) as number_of_skus, 
	sum(wps.skus_in_stock) as skus_in_stock,
	(sum(wps.skus_in_stock) / sum(wps.number_of_skus)) as skus_in_stock_p,
	sum(wps.browses) as browses, 
	sum(wps.browse_conversions) as browse_conversions,
	(sum(wps.browse_conversions) / sum(wps.browses)) as shop_to_purc_conv,
	sum(wps.adds_to_cart) as adds_to_cart, 
	sum(wps.cart_conversions) as cart_conversions,
	(sum(wps.cart_conversions) / sum(wps.adds_to_cart)) as cart_to_purc_conv
from drptw_prod_sales wps, 
	drpt_category cri, 
	drptw_orders wot, 
	dcs_category c, 
	dcs_product_info pi, 
	dcs_prd_prdinfo ppi, 
	dcspp_item i
where wps.product_id = ppi.product_id 
	and i.product_id = ppi.product_id 
	and i.catalog_id = c.catalog_id
	and cri.category_id = c.category_id 
	and i.catalog_id = ppi.catalog_id
	and ppi.product_info_id = pi.product_info_id 
	and pi.parent_cat_id = cri.category_id 
	and wps.week = wot.week
group by wps.week, 
	cri.catalog_name, 
	wps.category_name, 
	cri.avg_cost, 
	cri.avg_list_price, 
	cri.avg_sale_price,
	cri.avg_initial_markup,
	wot.total_units_sold, 
	wot.merch_rev, 
	cri.units_on_hand
         ;


--        new drptm_cat_sales calculates various statistics over each month on a per-category basis    
create or replace view drptm_cat_sales
as
select mps.month as month, 
	cri.catalog_name as catalog_name, 
	mps.category_name as category_name, 
	cri.avg_cost as avg_cost,
	cri.avg_list_price as avg_list_price, 
	cri.avg_sale_price as avg_sale_price, 
	cri.avg_initial_markup as avg_initial_markup,
	sum(mps.units_sold) as units_sold, 
	sum(mps.total_rev) as total_rev,
	sum(mps.cost_of_goods_sold) as cost_of_goods_sold,
	((sum(mps.total_rev) - sum(mps.cost_of_goods_sold)) / sum(mps.total_rev)) as maintained_markup,
	(sum(mps.units_sold) / mot.total_units_sold) as total_units_sold_p,
	(sum(mps.total_rev) / mot.merch_rev) as total_rev_p, 
	cri.units_on_hand as units_on_hand,
	(cri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(mps.number_of_skus) as number_of_skus, 
	sum(mps.skus_in_stock) as skus_in_stock,
	(sum(mps.skus_in_stock) / sum(mps.number_of_skus)) as skus_in_stock_p,
	sum(mps.browses) as browses, 
	sum(mps.browse_conversions) as browse_conversions,
	(sum(mps.browse_conversions) / sum(mps.browses)) as shop_to_purc_conv,
	sum(mps.adds_to_cart) as adds_to_cart, 
	sum(mps.cart_conversions) as cart_conversions,
	(sum(mps.cart_conversions) / sum(mps.adds_to_cart)) as cart_to_purc_conv
from drptm_prod_sales mps, 
	drpt_category cri, 
	drptm_orders mot, 
	dcs_category c, 
	dcs_product_info pi, 
	dcs_prd_prdinfo ppi, 
	dcspp_item i
where mps.product_id = ppi.product_id 
	and i.product_id = ppi.product_id 
	and i.catalog_id = c.catalog_id 
	and cri.category_id = c.category_id 
	and i.catalog_id = ppi.catalog_id 
	and ppi.product_info_id = pi.product_info_id 
	and pi.parent_cat_id = cri.category_id 
	and mps.month = mot.month
group by mps.month, 
	cri.catalog_name, 
	mps.category_name, 
	cri.avg_cost, 
	cri.avg_list_price, 
	cri.avg_sale_price,
	cri.avg_initial_markup,
	mot.total_units_sold, 
	mot.merch_rev, 
	cri.units_on_hand
         ;


--        new drptq_cat_sales calculates various statistics over each quarter on a per-category basis   
create or replace view drptq_cat_sales
as
select qps.quarter as quarter, 
	cri.catalog_name as catalog_name, 
	qps.category_name as category_name, 
	cri.avg_cost as avg_cost,
	cri.avg_list_price as avg_list_price, 
	cri.avg_sale_price as avg_sale_price, 
	cri.avg_initial_markup as avg_initial_markup,
	sum(qps.units_sold) as units_sold, 
	sum(qps.total_rev) as total_rev,
	sum(qps.cost_of_goods_sold) as cost_of_goods_sold,
	((sum(qps.total_rev) - sum(qps.cost_of_goods_sold)) / sum(qps.total_rev)) as maintained_markup,
	(sum(qps.units_sold) / qot.total_units_sold) as total_units_sold_p,
	(sum(qps.total_rev) / qot.merch_rev) as total_rev_p, 
	cri.units_on_hand as units_on_hand,
	(cri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(qps.number_of_skus) as number_of_skus, 
	sum(qps.skus_in_stock) as skus_in_stock,
	(sum(qps.skus_in_stock) / sum(qps.number_of_skus)) as skus_in_stock_p,
	sum(qps.browses) as browses, 
	sum(qps.browse_conversions) as browse_conversions,
	(sum(qps.browse_conversions) / sum(qps.browses)) as shop_to_purc_conv,
	sum(qps.adds_to_cart) as adds_to_cart, 
	sum(qps.cart_conversions) as cart_conversions,
	(sum(qps.cart_conversions) / sum(qps.adds_to_cart)) as cart_to_purc_conv
from drptq_prod_sales qps, 
	drpt_category cri, 
	drptq_orders qot, 
	dcs_category c, 
	dcs_product_info pi, 
	dcs_prd_prdinfo ppi, 
	dcspp_item i
where qps.product_id = ppi.product_id 
	and i.product_id = ppi.product_id 
	and i.catalog_id = c.catalog_id 
	and cri.category_id = c.category_id 
	and i.catalog_id = ppi.catalog_id 
	and ppi.product_info_id = pi.product_info_id 
	and pi.parent_cat_id = cri.category_id 
	and qps.quarter = qot.quarter
group by qps.quarter, 
	cri.catalog_name, 
	qps.category_name, 
	cri.avg_cost, 
	cri.avg_list_price, 
	cri.avg_sale_price,
	cri.avg_initial_markup,
	qot.total_units_sold, 
	qot.merch_rev, 
	cri.units_on_hand
         ;


--        new drpta_cat_sales calculates various statistics over each year on a per-category basis   
create or replace view drpta_cat_sales
as
select aps.year as year, 
	cri.catalog_name as catalog_name, 
	aps.category_name as category_name, 
	cri.avg_cost as avg_cost,
	cri.avg_list_price as avg_list_price, 
	cri.avg_sale_price as avg_sale_price, 
	cri.avg_initial_markup as avg_initial_markup,
	sum(aps.units_sold) as units_sold, 
	sum(aps.total_rev) as total_rev,
	sum(aps.cost_of_goods_sold) as cost_of_goods_sold,
	((sum(aps.total_rev) - sum(aps.cost_of_goods_sold)) / sum(aps.total_rev)) as maintained_markup,
	(sum(aps.units_sold) / aot.total_units_sold) as total_units_sold_p,
	(sum(aps.total_rev) / aot.merch_rev) as total_rev_p, 
	cri.units_on_hand as units_on_hand,
	(cri.units_on_hand / sum(i.quantity)) as weeks_on_hand,
	sum(aps.number_of_skus) as number_of_skus, 
	sum(aps.skus_in_stock) as skus_in_stock,
	(sum(aps.skus_in_stock) / sum(aps.number_of_skus)) as skus_in_stock_p,
	sum(aps.browses) as browses, 
	sum(aps.browse_conversions) as browse_conversions,
	(sum(aps.browse_conversions) / sum(aps.browses)) as shop_to_purc_conv,
	sum(aps.adds_to_cart) as adds_to_cart, 
	sum(aps.cart_conversions) as cart_conversions,
	(sum(aps.cart_conversions) / sum(aps.adds_to_cart)) as cart_to_purc_conv
from drpta_prod_sales aps, 
	drpt_category cri, 
	drpta_orders aot, 
	dcs_category c, 
	dcs_product_info pi, 
	dcs_prd_prdinfo ppi, 
	dcspp_item i
where aps.product_id = ppi.product_id 
	and i.product_id = ppi.product_id 
	and i.catalog_id = c.catalog_id 
	and cri.category_id = c.category_id 
	and i.catalog_id = ppi.catalog_id 
	and ppi.product_info_id = pi.product_info_id 
	and pi.parent_cat_id = cri.category_id 
	and aps.year = aot.year
group by aps.year, 
	cri.catalog_name, 
	aps.category_name, 
	cri.avg_cost, 
	cri.avg_list_price, 
	cri.avg_sale_price,
	cri.avg_initial_markup,
	aot.total_units_sold, 
	aot.merch_rev, 
	cri.units_on_hand
         ;




-- the source for this section is 
-- abandoned_order_ddl.sql




-- $Id: //product/DCS/version/10.0.3/templates/DCS/AbandonedOrderServices/sql/abandoned_order_ddl.xml#1 $

create table dcspp_ord_abandon (
	abandonment_id	varchar2(40)	not null,
	version	number(10)	not null,
	order_id	varchar2(40)	not null,
	ord_last_updated	timestamp	null,
	abandon_state	varchar2(40)	null,
	abandonment_count	number(10)	null,
	abandonment_date	timestamp	null,
	reanimation_date	timestamp	null,
	convert_date	timestamp	null,
	lost_date	timestamp	null
,constraint dcspp_ord_abndn_p primary key (abandonment_id));

create index dcspp_ordabandn1_x on dcspp_ord_abandon (order_id);

create table dcs_user_abandoned (
	id	varchar2(40)	not null,
	order_id	varchar2(40)	not null,
	profile_id	varchar2(40)	not null
,constraint dcs_usr_abndnd_p primary key (id));


create table drpt_conv_order (
	order_id	varchar2(40)	not null,
	converted_date	timestamp	not null,
	amount	number(19,7)	not null,
	promo_count	number(10)	not null,
	promo_value	number(19,7)	not null
,constraint drpt_conv_order_p primary key (order_id));


create table drpt_session_ord (
	dataset_id	varchar2(40)	not null,
	order_id	varchar2(40)	not null,
	date_time	timestamp	not null,
	amount	number(19,7)	not null,
	submitted	number(10)	not null,
	order_persistent	number(1)	null,
	session_id	varchar2(40)	null,
	parent_session_id	varchar2(40)	null
,constraint drpt_session_ord_p primary key (order_id));





-- the source for this section is 
-- abandoned_order_views.sql




create or replace view drpt_abandon_ord
as
      select oa.abandonment_date as abandonment_date, ai.amount as amount, decode(oa.abandon_state, 'CONVERTED', 100, 0) as converted from dcspp_order o, dcspp_ord_abandon oa, dcspp_amount_info ai where oa.order_id=o.order_id and o.price_info=ai.amount_info_id
         ;


create or replace view drpt_tns_abndn_ord
as
      select date_time as abandonment_date, amount as amount from drpt_session_ord where submitted=0
         ;




-- the source for this section is 
-- b2b_reporting_views.sql




create or replace view drpt_dlr_org
as
             select ORG.name as organization, round(sum(AI.amount),2) as amount
from 	dcspp_order O,
	dcspp_amount_info AI,
	dps_organization ORG,
	dps_user_org DO
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.price_info = AI.amount_info_id
	and O.state = 'NO_PENDING_ACTION'
group by ORG.name
         ;


create or replace view drpt_dlr_byr
as
             select ORG.name as organization, DU.id as buyerid, 
   (DU.last_name || ',' || DU.first_name) as buyer,
    round(sum(AI.amount),2) as amount
from  dcspp_order O,
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
group by ORG.name,DU.id, (DU.last_name || ',' || DU.first_name)
         ;


create or replace view drpt_dlr_org_parts
as
             select org.name as organization, s.manuf_part_num as partnumber, round(sum(ai.amount),2) as amount
from  dcspp_order o, 
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
group by org.name, s.manuf_part_num
         ;


create or replace view drpt_dlr_org_cc_i
as
             select ORG.name as organization, CC.identifier as costcenter,round(sum(CI.amount),2) as amount
from 	dcspp_order O,
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
group by ORG.name, CC.identifier
         ;


create or replace view drpt_dlr_org_cc_s
as
             select ORG.name as organization, CC.identifier as costcenter,round(sum(CS.amount),2) as amount
from 	dcspp_order O,
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
group by ORG.name, CC.identifier
         ;


create or replace view drpt_dlr_org_cc_o
as
             select ORG.name as organization, CC.identifier as costcenter,round(sum(CO.amount),2) as amount
from 	dcspp_order O,
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
group by ORG.name, CC.identifier
         ;


create or replace view drpt_dlr_org_cc
as
             select O.organization as organization, O.costcenter as costcenter,
(sum(I.amount) + sum(O.amount)) as amount
from drpt_dlr_org_cc_i I,
drpt_dlr_org_cc_o O
where O.organization = I.organization
and O.costcenter = I.costcenter
group by O.organization, O.costcenter
UNION
select I.organization as organization, I.costcenter as costcenter,
sum(I.amount) as amount
from drpt_dlr_org_cc_i I
where NOT EXISTS (select 1 from drpt_dlr_org_cc_o xx 
where xx.organization = I.organization
and xx.costcenter = I.costcenter)
group by I.organization, I.costcenter
UNION
select O.organization as organization, O.costcenter as costcenter,
sum(O.amount) as amount
from drpt_dlr_org_cc_o O
where NOT EXISTS (select 1 from drpt_dlr_org_cc_i xx
where xx.organization = O.organization
and xx.costcenter = O.costcenter)
group by O.organization, O.costcenter
         ;


create or replace view drpt_dlr_parts
as
             select s.manuf_part_num as partnumber, round(sum(ai.amount),2) as amount
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
group by s.manuf_part_num
         ;


create or replace view drpt_ordr_by_date
as
             select trunc (O.submitted_date) as datesubmitted,
 count(distinct O.order_id) as orders, 
 round(sum(ai.amount),2) as totalamount
from dcspp_order O,
     dcspp_item i, 
     dcspp_amount_info ai
where O.submitted_date is not null
  and O.order_id = i.order_ref
  and i.price_info = ai.amount_info_id
   and O.state = 'NO_PENDING_ACTION'
group by trunc (O.submitted_date)
         ;


create or replace view drpt_ordr_org
as
             select ORG.name as organization, count(*) as orders
from 	dcspp_order O,
	dps_organization ORG,
	dps_user_org DO
where              
	O.profile_id =DO.user_id
	and DO.organization = ORG.org_id
	and O.state = 'NO_PENDING_ACTION'
group by ORG.name
         ;


create or replace view drpt_ordr_buyr
as
             select ORG.name as organization, DU.id as buyerid, (DU.last_name || ',' || DU.first_name) as buyer, count(*) as orders
from 	dcspp_order O,
	dps_user DU,
	dps_organization ORG,
	dps_user_org DO
where              
	O.profile_id =DU.id
	and DU.id = DO.user_id
	and DO.organization = ORG.org_id
	and O.state = 'NO_PENDING_ACTION'
group by ORG.name, DU.id, (DU.last_name || ',' || DU.first_name)
         ;


create or replace view drpt_ordr_org_cc
as
             select ORG.name as organization, CC.identifier as costcenter, count(*) as orders
from 	dcspp_order O,
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
group by ORG.name, CC.identifier
         ;


create or replace view drpt_part_purchsed
as
             select Distinct S.manuf_part_num as partnumber, M.manufacturer_name as manufacturer 
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
         ;




-- the source for this section is 
-- motorprise_ddl.sql


-- the source for this section is 
-- b2b_custom_catalog_ddl.sql





create table b2b_belt_sku (
	sku_id	varchar2(40)	not null,
	length	varchar2(254)	null,
	top_width	varchar2(254)	null,
	angle	varchar2(254)	null,
	notched	integer	null
,constraint b2b_belt_sku_p primary key (sku_id)
,constraint b2b_beltsksku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table b2b_hose_sku (
	sku_id	varchar2(40)	not null,
	inner_diameter	varchar2(254)	null,
	length	varchar2(254)	null
,constraint b2b_hose_sku_p primary key (sku_id)
,constraint b2b_hossksku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table b2b_sprkplg_sku (
	sku_id	varchar2(40)	not null,
	plug_number	varchar2(254)	null,
	thread	varchar2(254)	null
,constraint b2b_sprkplg_sku_p primary key (sku_id)
,constraint b2b_sprksku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table b2b_oilfltr_sku (
	sku_id	varchar2(40)	not null,
	thread_type	varchar2(254)	null,
	length	varchar2(254)	null,
	outer_diameter	varchar2(254)	null
,constraint b2b_oilfltr_sku_p primary key (sku_id)
,constraint b2b_olflsku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table b2b_cylinder_sku (
	sku_id	varchar2(40)	not null,
	diameter	varchar2(254)	null,
	height	varchar2(254)	null
,constraint b2b_cylinder_sku_p primary key (sku_id)
,constraint b2b_cylisku_d_f foreign key (sku_id) references dcs_sku (sku_id));


create table b2b_cube_sku (
	sku_id	varchar2(40)	not null,
	height	varchar2(254)	null,
	width	varchar2(254)	null,
	depth	varchar2(254)	null
,constraint b2b_cube_sku_p primary key (sku_id)
,constraint b2b_cubsksku_d_f foreign key (sku_id) references dcs_sku (sku_id));





-- the source for this section is 
-- german_catalog_ddl.sql





create table dbc_catalog_de (
	catalog_id	varchar2(40)	not null,
	display_name	varchar2(254)	null
,constraint dbc_catalog_de_p primary key (catalog_id));


create table dbc_category_de (
	category_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	template_id	varchar2(40)	null
,constraint dbc_category_de_p primary key (category_id));


create table dbc_product_de (
	product_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	admin_display	varchar2(254)	null,
	template_id	varchar2(40)	null
,constraint dbc_product_de_p primary key (product_id));


create table dbc_sku_de (
	sku_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	template_id	varchar2(40)	null
,constraint dbc_sku_de_p primary key (sku_id));


create table dbc_sku_link_de (
	sku_link_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null
,constraint dbc_sku_link_de_p primary key (sku_link_id));


create table dbc_config_prop_de (
	config_prop_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null
,constraint dbc_config_prop__p primary key (config_prop_id));


create table dbc_config_opt_de (
	config_opt_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	price	number(19,7)	null
,constraint dbc_config_opt_d_p primary key (config_opt_id));


create table dbc_cat_key_de (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	keyword	varchar2(254)	not null
,constraint dbc_cat_key_de_p primary key (category_id,sequence_num));


create table dbc_prd_key_de (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	keyword	varchar2(254)	not null
,constraint dbc_prd_key_de_p primary key (product_id,sequence_num));


create table dbc_promotion_de (
	promotion_id	varchar2(40)	not null,
	display_name	varchar2(254)	null
,constraint dbc_promotion_de_p primary key (promotion_id));





-- the source for this section is 
-- japanese_catalog_ddl.sql





create table dbc_catalog_ja (
	catalog_id	varchar2(40)	not null,
	display_name	varchar2(254)	null
,constraint dbc_catalog_ja_p primary key (catalog_id));


create table dbc_category_ja (
	category_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	template_id	varchar2(40)	null
,constraint dbc_category_ja_p primary key (category_id));


create table dbc_product_ja (
	product_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	long_description	clob	null,
	admin_display	varchar2(254)	null,
	template_id	varchar2(40)	null
,constraint dbc_product_ja_p primary key (product_id));


create table dbc_sku_ja (
	sku_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	template_id	varchar2(40)	null
,constraint dbc_sku_ja_p primary key (sku_id));


create table dbc_sku_link_ja (
	sku_link_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null
,constraint dbc_sku_link_ja_p primary key (sku_link_id));


create table dbc_config_prop_ja (
	config_prop_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null
,constraint dbc_configpropja_p primary key (config_prop_id));


create table dbc_config_opt_ja (
	config_opt_id	varchar2(40)	not null,
	display_name	varchar2(254)	null,
	description	varchar2(254)	null,
	price	number(19,7)	null
,constraint dbc_config_optja_p primary key (config_opt_id));


create table dbc_cat_key_ja (
	category_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	keyword	varchar2(254)	not null
,constraint dbc_cat_key_ja_p primary key (category_id,sequence_num));


create table dbc_prd_key_ja (
	product_id	varchar2(40)	not null,
	sequence_num	integer	not null,
	keyword	varchar2(254)	not null
,constraint dbc_prd_key_ja_p primary key (product_id,sequence_num));


create table dbc_promotion_ja (
	promotion_id	varchar2(40)	not null,
	display_name	varchar2(254)	null
,constraint dbc_promotion_ja_p primary key (promotion_id));





-- the source for this section is 
-- b2b_user_orddet_ddl.sql





create table b2b_user_info (
	id	varchar2(40)	not null,
	num_orders	integer	null,
	avg_order_amt	number(19,7)	null,
	use_org_approver	number(1,0)	null,
	use_org_costctr	number(1,0)	null,
	use_org_billaddr	number(1,0)	null,
	use_org_shipaddr	number(1,0)	null,
	use_org_payment	number(1,0)	null,
	use_org_vendors	number(1,0)	null,
	use_org_purchlst	number(1,0)	null
,constraint b2b_user_info_p primary key (id)
,constraint b2b_usrnfid_f foreign key (id) references dps_user (id)
,constraint b2b_user_info1_c check (use_org_approver in (0,1))
,constraint b2b_user_info2_c check (use_org_costctr in (0,1))
,constraint b2b_user_info3_c check (use_org_billaddr in (0,1))
,constraint b2b_user_info4_c check (use_org_shipaddr in (0,1))
,constraint b2b_user_info5_c check (use_org_payment in (0,1))
,constraint b2b_user_info6_c check (use_org_vendors in (0,1))
,constraint b2b_user_info7_c check (use_org_purchlst in (0,1)));


create table b2b_org_info (
	org_id	varchar2(40)	not null,
	logo	varchar2(40)	null,
	cc_auth	number(1,0)	null,
	invoice_auth	number(1,0)	null,
	store_crdt_auth	number(1,0)	null,
	gift_crt_auth	number(1,0)	null,
	use_prnt_approver	number(1,0)	null,
	use_prnt_costctr	number(1,0)	null,
	use_prnt_billaddr	number(1,0)	null,
	use_prnt_shipaddr	number(1,0)	null,
	use_prnt_payment	number(1,0)	null,
	use_prnt_vendors	number(1,0)	null,
	use_prnt_purchlst	number(1,0)	null
,constraint b2b_org_info_p primary key (org_id)
,constraint b2b_orgnforg_d_f foreign key (org_id) references dps_organization (org_id)
,constraint b2b_org_info1_c check (cc_auth in (0,1))
,constraint b2b_org_info2_c check (invoice_auth in (0,1))
,constraint b2b_org_info3_c check (store_crdt_auth in (0,1))
,constraint b2b_org_info4_c check (gift_crt_auth in (0,1))
,constraint b2b_org_info5_c check (use_prnt_approver in (0,1))
,constraint b2b_org_info6_c check (use_prnt_costctr in (0,1))
,constraint b2b_org_info7_c check (use_prnt_billaddr in (0,1))
,constraint b2b_org_info8_c check (use_prnt_shipaddr in (0,1))
,constraint b2b_org_info9_c check (use_prnt_payment in (0,1))
,constraint b2b_org_infoa_c check (use_prnt_vendors in (0,1))
,constraint b2b_org_infob_c check (use_prnt_purchlst in (0,1)));





-- the source for this section is 
-- b2b_auth_cc_ddl.sql





create table b2b_auth_pmnt (
	id	varchar2(40)	not null,
	cc_auth	number(1,0)	null,
	invoice_auth	number(1,0)	null,
	store_crdt_auth	number(1,0)	null,
	gift_crt_auth	number(1,0)	null
,constraint b2b_auth_pmnt_p primary key (id)
,constraint b2b_athpmntid_f foreign key (id) references dps_user (id)
,constraint b2b_auth_pmnt1_c check (cc_auth in (0,1))
,constraint b2b_auth_pmnt2_c check (invoice_auth in (0,1))
,constraint b2b_auth_pmnt3_c check (store_crdt_auth in (0,1))
,constraint b2b_auth_pmnt4_c check (gift_crt_auth in (0,1)));


create table b2b_credit_card (
	id	varchar2(40)	not null,
	cc_first_name	varchar2(40)	null,
	cc_middle_name	varchar2(40)	null,
	cc_last_name	varchar2(40)	null
,constraint b2b_credit_card_p primary key (id)
,constraint b2b_credtcrdid_f foreign key (id) references dps_credit_card (id));

create index b2b_crcdba_idx on b2b_credit_card (cc_last_name);




-- the source for this section is 
-- membership_ddl.sql





create table mem_membership_req (
	id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	user_id	varchar2(40)	not null,
	community_id	varchar2(40)	not null,
	request_type	number(1,0)	not null,
	creation_date	timestamp	not null
,constraint mem_membershiprq_p primary key (id)
,constraint mem_membershiprq_c check (request_type in (0,1)));





-- the source for this section is 
-- alert_ddl.sql





create table alt_user (
	id	varchar2(40)	not null,
	version	number(10)	default 0 not null,
	target_id	varchar2(40)	not null,
	target_type	varchar2(40)	not null,
	source_id	varchar2(40)	null,
	msg_type	varchar2(255)	null,
	message_bean	blob	null,
	creation_date	timestamp	null,
	end_date	timestamp	null,
	start_date	timestamp	null,
	delete_flag	number(1,0)	not null
,constraint alt_userpk primary key (id));

create index alt_user_idx on alt_user (target_id,target_type,source_id);

create table alt_group (
	id	varchar2(40)	not null,
	version	number(10)	not null,
	target_id	varchar2(40)	not null,
	target_type	varchar2(40)	not null,
	source_id	varchar2(40)	null,
	msg_type	varchar2(255)	null,
	message_bean	blob	null,
	creation_date	timestamp	null,
	end_date	timestamp	null,
	start_date	timestamp	null,
	delete_flag	number(1,0)	not null
,constraint alt_grouppk primary key (id));

create index alt_group_idx on alt_group (target_id,target_type,source_id);

create table alt_user_alert_rel (
	id	varchar2(40)	not null,
	alert_id	varchar2(40)	not null
,constraint alt_useralertrel_p primary key (id,alert_id));


create table alt_user_pref (
	id	varchar2(40)	not null,
	source_id	varchar2(40)	not null,
	source_type	varchar2(40)	not null,
	version	number(10)	not null,
	event_type	varchar2(255)	null,
	name	varchar2(40)	not null,
	value	varchar2(40)	not null
,constraint alt_user_prefpk primary key (id));


create table alt_userpref_rel (
	id	varchar2(40)	not null,
	alert_user_pref_id	varchar2(40)	not null
,constraint alt_user_relpk primary key (id,alert_user_pref_id));

create index alt_userpref_idx on alt_userpref_rel (alert_user_pref_id);

create table alt_gear (
	id	varchar2(40)	not null,
	source_id	varchar2(40)	not null,
	source_type	varchar2(40)	not null,
	version	number(10)	not null,
	message_type	varchar2(255)	not null,
	name	varchar2(40)	not null,
	value	varchar2(40)	not null,
	resource_bundle	varchar2(255)	not null
,constraint alt_gearpk primary key (id));


create table alt_gear_rel (
	id	varchar2(40)	not null,
	name	varchar2(40)	not null,
	gear_id	varchar2(40)	not null
,constraint alt_gear_relpk primary key (id,gear_id));

create index alt_gear_idx on alt_gear_rel (gear_id);

create table alt_gear_def (
	id	varchar2(40)	not null,
	version	number(10)	not null,
	message_type	varchar2(255)	not null,
	name	varchar2(40)	not null,
	value	varchar2(40)	not null,
	resource_bundle	varchar2(255)	not null
,constraint alt_gear_defpk primary key (id));


create table alt_gear_def_rel (
	id	varchar2(40)	not null,
	name	varchar2(40)	not null,
	gear_def_id	varchar2(40)	not null
,constraint alt_def_relpk primary key (id,gear_def_id));

create index alt_gear_def_idx on alt_gear_def_rel (gear_def_id);

create table alt_channel (
	channel_id	varchar2(40)	not null,
	version	number(10)	not null,
	component_name	varchar2(255)	not null,
	display_name	varchar2(255)	not null
,constraint alt_channel_pk primary key (channel_id));


create table alt_chan_usr_rel (
	alt_user_pref_id	varchar2(40)	not null,
	channel_id	varchar2(40)	not null
,constraint alt_chnusr_relpk primary key (channel_id,alt_user_pref_id));





-- the source for this section is 
-- paf_mappers_ddl.sql





create table paf_page_visit (
	id	varchar2(40)	not null,
	tstamp	date	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	page_path	varchar2(255)	null,
	msg_type	varchar2(255)	null);

create index paf_pgvst_comid on paf_page_visit (community_id);
create index paf_pgvst_gearid on paf_page_visit (gear_id);
create index paf_pgvst_usrid on paf_page_visit (user_id);

create table comm_gear_add (
	id	varchar2(40)	not null,
	tstamp	date	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index comm_gearaddcom_id on comm_gear_add (community_id);
create index comm_gearaddgearid on comm_gear_add (gear_id);
create index comm_gearaddusr_id on comm_gear_add (user_id);

create table comm_gear_rem (
	id	varchar2(40)	not null,
	tstamp	date	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index comm_gearremcom_id on comm_gear_rem (community_id);
create index comm_gearremgearid on comm_gear_rem (gear_id);
create index comm_gearremusr_id on comm_gear_rem (user_id);

create table page_gear_add (
	id	varchar2(40)	not null,
	tstamp	date	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	page_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index page_gearaddcom_id on page_gear_add (community_id);
create index page_gearaddgearid on page_gear_add (gear_id);
create index page_gearaddpageid on page_gear_add (page_id);
create index page_gearaddusr_id on page_gear_add (user_id);

create table page_gear_rem (
	id	varchar2(40)	not null,
	tstamp	date	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	page_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index page_gearremcom_id on page_gear_rem (community_id);
create index page_gearremgearid on page_gear_rem (gear_id);
create index page_gearrempageid on page_gear_rem (page_id);
create index page_gearremusr_id on page_gear_rem (user_id);




-- the source for this section is 
-- portal_ddl.sql





create table paf_folder (
	folder_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	type	number(1,0)	not null,
	parent	varchar2(40)	null,
	url_name	varchar2(254)	not null
,constraint paf_folderpk primary key (folder_id)
,constraint paf_folder1_f foreign key (parent) references paf_folder (folder_id)
,constraint type_enum check (type in (0,1,2)));

create index paf_folderpnidx on paf_folder (parent,name);

create table paf_folder_acl (
	id	varchar2(254)	not null,
	indx	number(10)	not null,
	acl	varchar2(254)	null);


create table paf_child_folder (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_folder_id	varchar2(40)	not null
,constraint paf_childfolderpk primary key (folder_id,child_folder_id)
,constraint paf_childfolder1_f foreign key (folder_id) references paf_folder (folder_id)
,constraint paf_childfolder2_f foreign key (child_folder_id) references paf_folder (folder_id));

create index paf_cfchldflddlix on paf_child_folder (child_folder_id);

create table paf_fldr_ln_names (
	folder_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_fldr_lnnamespk primary key (folder_id,locale)
,constraint paf_fldrlnnames1_f foreign key (folder_id) references paf_folder (folder_id));


create table paf_fldr_ln_descs (
	folder_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_fldr_lndescspk primary key (folder_id,locale)
,constraint paf_fldrlndescs1_f foreign key (folder_id) references paf_folder (folder_id));


create table paf_gear_param (
	gear_param_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	description	varchar2(254)	null,
	default_value	varchar2(254)	null,
	required	number(1,0)	not null,
	isreadonly	number(1,0)	default 0 not null
,constraint paf_gearparampk primary key (gear_param_id)
,constraint required_bool check (required in (0,1))
,constraint isreadonly_bool check (isreadonly in (0,1)));


create table paf_gear_prmvals (
	gear_param_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	param_value	varchar2(254)	null
,constraint paf_gprmvalspk primary key (gear_param_id,sequence_num)
,constraint paf_gprmvals1_f foreign key (gear_param_id) references paf_gear_param (gear_param_id));


create table paf_device_outputs (
	device_outputs_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null
,constraint paf_deviceoutspk primary key (device_outputs_id));


create table paf_device_output (
	device_output_id	varchar2(40)	not null,
	type	varchar2(10)	not null,
	url	varchar2(254)	null
,constraint paf_deviceoutpk primary key (device_output_id,type)
,constraint paf_device_out1_f foreign key (device_output_id) references paf_device_outputs (device_outputs_id));


create table paf_display_modes (
	display_modes_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	shared_mode	varchar2(40)	null,
	full_mode	varchar2(40)	null,
	popup_mode	varchar2(40)	null
,constraint paf_displaymodespk primary key (display_modes_id)
,constraint paf_displaymode1_f foreign key (shared_mode) references paf_device_outputs (device_outputs_id)
,constraint paf_displaymode2_f foreign key (full_mode) references paf_device_outputs (device_outputs_id)
,constraint paf_displaymode3_f foreign key (popup_mode) references paf_device_outputs (device_outputs_id));

create index paf_dmsmdlix on paf_display_modes (shared_mode);
create index paf_dmfmdlix on paf_display_modes (full_mode);
create index paf_dmpmdlix on paf_display_modes (popup_mode);

create table paf_title_template (
	title_template_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	servlet_context	varchar2(254)	not null,
	template_dm	varchar2(40)	null,
	pre_template_dm	varchar2(40)	null,
	post_template_dm	varchar2(40)	null,
	small_image_url	varchar2(254)	null,
	small_image_alt	varchar2(254)	null,
	large_image_url	varchar2(254)	null,
	large_image_alt	varchar2(254)	null
,constraint paf_titletmplpk primary key (title_template_id)
,constraint paf_title_templ1_u unique (name)
,constraint paf_title_templ1_f foreign key (template_dm) references paf_display_modes (display_modes_id)
,constraint paf_title_templ2_f foreign key (pre_template_dm) references paf_display_modes (display_modes_id)
,constraint paf_title_templ3_f foreign key (post_template_dm) references paf_display_modes (display_modes_id));

create index paf_ttmptmpldlix on paf_title_template (template_dm);
create index paf_ttmppredlix on paf_title_template (pre_template_dm);
create index paf_ttmppstdlix on paf_title_template (post_template_dm);

create table paf_gear_modes (
	gear_modes_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	content_mode	varchar2(40)	null,
	help_mode	varchar2(40)	null,
	about_mode	varchar2(40)	null,
	preview_mode	varchar2(40)	null,
	user_cfg_mode	varchar2(40)	null,
	instance_cfg_mode	varchar2(40)	null,
	initial_cfg_mode	varchar2(40)	null,
	install_cfg_mode	varchar2(40)	null
,constraint paf_gearmodespk primary key (gear_modes_id)
,constraint paf_gear_modes1_f foreign key (content_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes2_f foreign key (help_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes3_f foreign key (about_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes4_f foreign key (preview_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes5_f foreign key (user_cfg_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes6_f foreign key (instance_cfg_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes7_f foreign key (initial_cfg_mode) references paf_display_modes (display_modes_id)
,constraint paf_gear_modes8_f foreign key (install_cfg_mode) references paf_display_modes (display_modes_id));

create index paf_gdcmdlix on paf_gear_modes (content_mode);
create index paf_gdhmdlix on paf_gear_modes (help_mode);
create index paf_gdamdlix on paf_gear_modes (about_mode);
create index paf_gmpredlix on paf_gear_modes (preview_mode);
create index paf_gmusercmdlix on paf_gear_modes (user_cfg_mode);
create index paf_gmancecmdlix on paf_gear_modes (instance_cfg_mode);
create index paf_gminitcmdlix on paf_gear_modes (initial_cfg_mode);
create index paf_gminstcmdlix on paf_gear_modes (install_cfg_mode);

create table paf_gear_def (
	gear_def_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	parent_folder	varchar2(40)	not null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	hide	number(1,0)	not null,
	timeout	number(19,0)	not null,
	jsr168	number(1,0)	default 0 not null,
	portlet_guid	varchar2(254)	null,
	render_async	number(1,0)	not null,
	should_cache	number(1,0)	not null,
	cache_timeout	number(19,0)	null,
	intercept_errors	number(1,0)	not null,
	cover_err_cache	number(1,0)	not null,
	servlet_context	varchar2(254)	not null,
	sharable	number(1,0)	not null,
	width	number(1,0)	not null,
	height	number(1,0)	not null,
	small_image_url	varchar2(254)	null,
	small_image_alt	varchar2(254)	null,
	large_image_url	varchar2(254)	null,
	large_image_alt	varchar2(254)	null,
	gear_modes	varchar2(40)	null
,constraint paf_geardefpk primary key (gear_def_id)
,constraint paf_gear_def1_f foreign key (parent_folder) references paf_folder (folder_id)
,constraint paf_gear_def2_f foreign key (gear_modes) references paf_gear_modes (gear_modes_id)
,constraint gear_asyncbool check (render_async in (0,1))
,constraint gear_cachebool check (should_cache in (0,1))
,constraint gear_errcachebool check (cover_err_cache in (0,1))
,constraint gear_errorsbool check (intercept_errors in (0,1))
,constraint gear_heightenum check (height in (0,1,2))
,constraint gear_hidebool check (hide in (0,1))
,constraint gear_widthenum check (width in (0,1,2)));

create index paf_gdpfdlix on paf_gear_def (parent_folder);
create index paf_gdgmdlix on paf_gear_def (gear_modes);

create table paf_gd_cprops (
	gear_def_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	name	varchar2(254)	not null
,constraint paf_gdcpropspk primary key (gear_def_id,sequence_num)
,constraint paf_gd_cprops1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id));


create table paf_gd_iparams (
	gear_def_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	gear_param_id	varchar2(40)	not null
,constraint paf_gdiparamspk primary key (gear_def_id,gear_param_id)
,constraint paf_gd_iparams1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id)
,constraint paf_gd_iparams2_f foreign key (gear_param_id) references paf_gear_param (gear_param_id));

create index paf_gdipiddlix on paf_gd_iparams (gear_param_id);

create table paf_gd_uparams (
	gear_def_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	gear_param_id	varchar2(40)	not null
,constraint paf_gduparamspk primary key (gear_def_id,gear_param_id)
,constraint paf_gd_uparams1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id)
,constraint paf_gd_uparams2_f foreign key (gear_param_id) references paf_gear_param (gear_param_id));

create index paf_gdupiddlix on paf_gd_uparams (gear_param_id);

create table paf_gd_l10n_names (
	gear_def_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_gd_l10nnamespk primary key (gear_def_id,locale)
,constraint paf_gd_l10nname1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id));


create table paf_gd_l10n_descs (
	gear_def_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_gd_l10ndescspk primary key (gear_def_id,locale)
,constraint paf_gd_l10ndesc1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id));


create table paf_gear (
	gear_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	name	varchar2(254)	null,
	description	varchar2(254)	null,
	gear_definition	varchar2(40)	not null,
	access_level	number(1,0)	not null,
	show_title_bars	number(1,0)	not null,
	parent_comm_id	varchar2(40)	not null,
	is_shared	number(1,0)	not null
,constraint paf_gearpk primary key (gear_id)
,constraint paf_gear1_f foreign key (gear_definition) references paf_gear_def (gear_def_id)
,constraint gear_titlebarsbool check (show_title_bars in (0,1)));

create index paf_geargddlix on paf_gear (gear_definition);

create table paf_gear_acl (
	id	varchar2(254)	not null,
	indx	number(10)	not null,
	acl	varchar2(254)	null);


create table paf_gear_iparams (
	gear_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	iparam_value	varchar2(254)	null
,constraint paf_geariparamspk primary key (gear_id,tag)
,constraint paf_geariparams1_f foreign key (gear_id) references paf_gear (gear_id));


create table paf_gear_ln_names (
	gear_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_gear_lnnamespk primary key (gear_id,locale)
,constraint paf_gearlnnames1_f foreign key (gear_id) references paf_gear (gear_id));


create table paf_gear_ln_descs (
	gear_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_gear_lndescspk primary key (gear_id,locale)
,constraint paf_gearlndescs1_f foreign key (gear_id) references paf_gear (gear_id));


create table paf_region_def (
	region_def_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	name	varchar2(254)	not null,
	width	number(1,0)	not null,
	height	number(1,0)	not null
,constraint paf_regiondefpk primary key (region_def_id)
,constraint paf_regiondefuk unique (name)
,constraint paf_regionhtbool check (height in (0,1))
,constraint paf_regionwithbool check (width in (0,1)));

-- Do not use REFERENCES paf_page(page_id) here because of circular references

create table paf_region (
	region_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	definition	varchar2(40)	not null,
	parent_page_id	varchar2(40)	not null,
	fixed	number(1,0)	not null
,constraint paf_regionpk primary key (region_id)
,constraint paf_region1_f foreign key (definition) references paf_region_def (region_def_id)
,constraint regionfixedbool check (fixed in (0,1)));

create index paf_regdefdlix on paf_region (definition);

create table paf_region_gears (
	region_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	gear_id	varchar2(40)	not null
,constraint paf_regiongearspk primary key (region_id,sequence_num)
,constraint paf_regiongears2_f foreign key (gear_id) references paf_gear (gear_id)
,constraint paf_regiongears1_f foreign key (region_id) references paf_region (region_id));

create index paf_reggriddlix on paf_region_gears (gear_id);

create table paf_style (
	style_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	servlet_context	varchar2(254)	not null,
	css_url	varchar2(254)	not null
,constraint paf_stylepk primary key (style_id)
,constraint paf_style1_u unique (name));


create table paf_styl_ln_names (
	style_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_styl_lnnamespk primary key (style_id,locale)
,constraint paf_styllnnames1_f foreign key (style_id) references paf_style (style_id));


create table paf_styl_ln_descs (
	style_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_styl_lndescspk primary key (style_id,locale)
,constraint paf_styllndescs1_f foreign key (style_id) references paf_style (style_id));


create table paf_col_palette (
	palette_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	servlet_context	varchar2(254)	not null,
	small_image_url	varchar2(254)	null,
	small_image_alt	varchar2(254)	null,
	large_image_url	varchar2(254)	null,
	large_image_alt	varchar2(254)	null,
	pg_bg_image_url	varchar2(254)	null,
	pg_bg_color	char(6)	null,
	pg_text_color	char(6)	null,
	pg_link_color	char(6)	null,
	pg_alink_color	char(6)	null,
	pg_vlink_color	char(6)	null,
	gt_bg_color	char(6)	null,
	gt_text_color	char(6)	null,
	gear_bg_color	char(6)	null,
	gear_text_color	char(6)	null,
	hl_bg_color	char(6)	null,
	hl_text_color	char(6)	null
,constraint paf_colpalettepk primary key (palette_id)
,constraint paf_col_palette1_u unique (name));


create table paf_cpal_ln_names (
	palette_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_cpal_lnnamespk primary key (palette_id,locale)
,constraint paf_cpallnnames1_f foreign key (palette_id) references paf_col_palette (palette_id));


create table paf_cpal_ln_descs (
	palette_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_cpal_lndescspk primary key (palette_id,locale)
,constraint paf_cpallndescs1_f foreign key (palette_id) references paf_col_palette (palette_id));


create table paf_layout (
	layout_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	not null,
	internal_version	number(10)	null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	small_image_url	varchar2(254)	null,
	small_image_alt	varchar2(254)	null,
	large_image_url	varchar2(254)	null,
	large_image_alt	varchar2(254)	null,
	servlet_context	varchar2(254)	not null,
	display_modes	varchar2(40)	not null
,constraint paf_layoutpk primary key (layout_id)
,constraint paf_layout1_u unique (name)
,constraint paf_layout1_f foreign key (display_modes) references paf_display_modes (display_modes_id));

create index paf_lytdmdlix on paf_layout (display_modes);

create table paf_layout_regdefs (
	layout_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	region_def_id	varchar2(40)	not null
,constraint paf_layoutregdfpk primary key (layout_id,sequence_num)
,constraint paf_layoutregdf1_f foreign key (layout_id) references paf_layout (layout_id)
,constraint paf_layoutregdf2_f foreign key (region_def_id) references paf_region_def (region_def_id));

create index paf_lytregddlix on paf_layout_regdefs (region_def_id);

create table paf_page_template (
	page_template_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	small_image_url	varchar2(254)	null,
	small_image_alt	varchar2(254)	null,
	large_image_url	varchar2(254)	null,
	large_image_alt	varchar2(254)	null,
	servlet_context	varchar2(254)	not null,
	display_modes	varchar2(40)	not null
,constraint paf_pagetmplpk primary key (page_template_id)
,constraint paf_pagetmplate1_u unique (name)
,constraint paf_pagetmplate1_f foreign key (display_modes) references paf_display_modes (display_modes_id));

create index paf_pagetmdmdlix on paf_page_template (display_modes);

create table paf_ptpl_ln_names (
	page_template_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_ptpl_lnnamespk primary key (page_template_id,locale)
,constraint paf_ptpllnnames1_f foreign key (page_template_id) references paf_page_template (page_template_id));


create table paf_ptpl_ln_descs (
	page_template_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_ptpl_lndescspk primary key (page_template_id,locale)
,constraint paf_ptpllndescs1_f foreign key (page_template_id) references paf_page_template (page_template_id));


create table paf_template (
	template_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	author	varchar2(254)	null,
	version	varchar2(254)	null,
	small_image_url	varchar2(254)	null,
	small_image_alt	varchar2(254)	null,
	large_image_url	varchar2(254)	null,
	large_image_alt	varchar2(254)	null,
	servlet_context	varchar2(254)	not null,
	device_outputs	varchar2(40)	not null
,constraint paf_tmplpk primary key (template_id)
,constraint paf_tmplate1_u unique (name)
,constraint paf_tmplate1_f foreign key (device_outputs) references paf_device_outputs (device_outputs_id));

create index paf_tmpdodlix on paf_template (device_outputs);
-- Cannot have default_page REFERENCES paf_page(page_id) because this is circular

create table paf_community (
	community_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	url_name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	null,
	internal_version	number(10)	null,
	enabled	number(1,0)	not null,
	access_level	number(1,0)	not null,
	parent_folder	varchar2(40)	not null,
	page_folder	varchar2(40)	not null,
	default_page	varchar2(40)	null,
	personalization	number(1,0)	not null,
	membership_req	number(1,0)	not null,
	page_template	varchar2(40)	null,
	title_template	varchar2(40)	null,
	li_template	varchar2(40)	null,
	lo_template	varchar2(40)	null,
	ad_template	varchar2(40)	null,
	rg_template	varchar2(40)	null,
	up_template	varchar2(40)	null,
	ia_template	varchar2(40)	null,
	page_style	varchar2(40)	null
,constraint paf_communitypk primary key (community_id)
,constraint paf_community1_f foreign key (parent_folder) references paf_folder (folder_id)
,constraint paf_community2_f foreign key (page_folder) references paf_folder (folder_id)
,constraint paf_community3_f foreign key (page_template) references paf_page_template (page_template_id)
,constraint paf_community5_f foreign key (page_style) references paf_style (style_id)
,constraint paf_community10_f foreign key (up_template) references paf_template (template_id)
,constraint paf_community8_f foreign key (ad_template) references paf_template (template_id)
,constraint paf_community9_f foreign key (rg_template) references paf_template (template_id)
,constraint paf_community7_f foreign key (lo_template) references paf_template (template_id)
,constraint paf_community11_f foreign key (ia_template) references paf_template (template_id)
,constraint paf_community6_f foreign key (li_template) references paf_template (template_id)
,constraint paf_community4_f foreign key (title_template) references paf_title_template (title_template_id)
,constraint commenabledbool check (enabled in (0,1))
,constraint membershipreqenum check (membership_req in (0,1,2))
,constraint pers_enum check (personalization in (0,1,2)));

create index paf_commpfdlix on paf_community (parent_folder);
create index paf_commpgfdlix on paf_community (page_folder);
create index paf_commtmpldlix on paf_community (page_template);
create index paf_commstydlix on paf_community (page_style);
create index paf_comntuptmpl_ix on paf_community (up_template);
create index paf_comntadtmpl_ix on paf_community (ad_template);
create index paf_comntrgtmpl_ix on paf_community (rg_template);
create index paf_comntlotmpl_ix on paf_community (lo_template);
create index paf_comntiatmpl_ix on paf_community (ia_template);
create index paf_comntlitmpl_ix on paf_community (li_template);
create index paf_commttmpldlix on paf_community (title_template);

create table paf_comm_gears (
	community_id	varchar2(40)	not null,
	gear_id	varchar2(40)	not null
,constraint paf_commgearspk primary key (community_id,gear_id)
,constraint paf_comm_gears1_f foreign key (community_id) references paf_community (community_id)
,constraint paf_comm_gears2_f foreign key (gear_id) references paf_gear (gear_id));

create index paf_commgriddlix on paf_comm_gears (gear_id);

create table paf_comm_gfldrs (
	community_id	varchar2(40)	not null,
	gear_def_fldr_id	varchar2(40)	not null
,constraint paf_commgfldrpk primary key (community_id,gear_def_fldr_id)
,constraint paf_comm_gfldrs1_f foreign key (community_id) references paf_community (community_id)
,constraint paf_comm_gfldrs2_f foreign key (gear_def_fldr_id) references paf_folder (folder_id));

create index paf_comm_gfldrs1_i on paf_comm_gfldrs (gear_def_fldr_id);

create table paf_comm_roles (
	community_id	varchar2(40)	not null,
	role_name	varchar2(254)	not null,
	role_id	varchar2(40)	not null
,constraint paf_comm_roles_pk primary key (community_id,role_name)
,constraint paf_comm_roles_fk foreign key (community_id) references paf_community (community_id));


create table paf_base_comm_role (
	id	varchar2(40)	not null,
	role_name	varchar2(254)	not null,
	category	varchar2(254)	not null
,constraint paf_basecomrole_pk primary key (role_name));


create table paf_gear_roles (
	gear_id	varchar2(40)	not null,
	role_name	varchar2(254)	not null,
	role_id	varchar2(40)	not null
,constraint paf_gear_roles_pk primary key (gear_id,role_name)
,constraint paf_gear_roles_fk foreign key (gear_id) references paf_gear (gear_id));


create table paf_base_gear_role (
	gear_def_id	varchar2(40)	not null,
	role_name	varchar2(254)	not null
,constraint paf_basegearrolepk primary key (gear_def_id,role_name));


create table paf_community_acl (
	id	varchar2(254)	not null,
	indx	number(10)	not null,
	acl	varchar2(254)	null);


create table paf_comm_lnames (
	community_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_commlnamespk primary key (community_id,locale)
,constraint paf_comm_lnames1_f foreign key (community_id) references paf_community (community_id));


create table paf_comm_ldescs (
	community_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_commldescspk primary key (community_id,locale)
,constraint paf_comm_ldescs1_f foreign key (community_id) references paf_community (community_id));


create table paf_page (
	page_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	url_name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	not null,
	internal_version	number(10)	null,
	access_level	number(1,0)	not null,
	parent_folder	varchar2(40)	not null,
	parent_comm_id	varchar2(40)	not null,
	layout_id	varchar2(40)	not null,
	allow_layout_chgs	number(1,0)	not null,
	palette_id	varchar2(40)	null,
	fixed	number(1,0)	not null,
	wireless_enabled	number(1,0)	not null
,constraint paf_pagepk primary key (page_id)
,constraint paf_page3_f foreign key (palette_id) references paf_col_palette (palette_id)
,constraint paf_page2_f foreign key (parent_comm_id) references paf_community (community_id)
,constraint paf_page1_f foreign key (parent_folder) references paf_folder (folder_id)
,constraint paf_page4_f foreign key (layout_id) references paf_layout (layout_id)
,constraint allowchgsbool check (allow_layout_chgs in (0,1))
,constraint fixedisbool check (fixed in (0,1))
,constraint wirelessisbool check (wireless_enabled in (0,1)));

create index paf_pagepaldlix on paf_page (palette_id);
create index paf_pagecommdlix on paf_page (parent_comm_id);
create index paf_pagepfdlix on paf_page (parent_folder);
create index paf_pagelytdlix on paf_page (layout_id);

create table paf_page_ln_names (
	page_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_page_lnnamespk primary key (page_id,locale)
,constraint paf_pagelnnames1_f foreign key (page_id) references paf_page (page_id));


create table paf_page_ln_descs (
	page_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_page_lndescspk primary key (page_id,locale)
,constraint paf_pagelndescs1_f foreign key (page_id) references paf_page (page_id));


create table paf_page_acl (
	id	varchar2(254)	not null,
	indx	number(10)	not null,
	acl	varchar2(254)	null);


create table paf_page_regions (
	page_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	region_id	varchar2(40)	not null
,constraint paf_pageregionspk primary key (page_id,tag)
,constraint paf_pageregions1_f foreign key (page_id) references paf_page (page_id)
,constraint paf_pageregions2_f foreign key (region_id) references paf_region (region_id));

create index paf_pageriddlix on paf_page_regions (region_id);

create table paf_cf_child_item (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_item_id	varchar2(40)	not null
,constraint paf_cfchilditempk primary key (folder_id,child_item_id)
,constraint paf_cfchilditem2_f foreign key (child_item_id) references paf_community (community_id)
,constraint paf_cfchilditem1_f foreign key (folder_id) references paf_folder (folder_id));

create index paf_cfchlddlix on paf_cf_child_item (child_item_id);

create table paf_cf_gfldrs (
	comm_folder_id	varchar2(40)	not null,
	gear_def_fldr_id	varchar2(40)	not null
,constraint paf_cfgfldrspk primary key (comm_folder_id,gear_def_fldr_id)
,constraint paf_cf_gfldrs1_f foreign key (comm_folder_id) references paf_folder (folder_id)
,constraint paf_cf_gfldrs2_f foreign key (gear_def_fldr_id) references paf_folder (folder_id));

create index paf_cfgfldrs1_i on paf_cf_gfldrs (gear_def_fldr_id);

create table paf_pf_child_item (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_item_id	varchar2(40)	not null
,constraint paf_pfchilditempk primary key (folder_id,child_item_id)
,constraint paf_pfchilditem1_f foreign key (folder_id) references paf_folder (folder_id)
,constraint paf_pfchilditem2_f foreign key (child_item_id) references paf_page (page_id));

create index paf_pfcitemiddlix on paf_pf_child_item (child_item_id);

create table paf_gdf_child_item (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_item_id	varchar2(40)	not null
,constraint paf_gdfchilditempk primary key (folder_id,child_item_id)
,constraint paf_gdfchlditem1_f foreign key (folder_id) references paf_folder (folder_id)
,constraint paf_gdfchlditem2_f foreign key (child_item_id) references paf_gear_def (gear_def_id));

create index paf_gdfciiddlix on paf_gdf_child_item (child_item_id);

create table paf_comm_template (
	template_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	internal_version	number(10)	null,
	enabled	number(1,0)	not null,
	access_level	number(10)	not null,
	parent_folder	varchar2(40)	not null,
	page_folder	varchar2(40)	not null,
	default_page	varchar2(40)	not null,
	personalization	number(1,0)	not null,
	membership_req	number(1,0)	not null,
	page_template	varchar2(40)	not null,
	title_template	varchar2(40)	not null,
	style	varchar2(40)	not null
,constraint paf_comtemplate_p primary key (template_id)
,constraint paf_comtemplate_c1 check (enabled in (0,1))
,constraint paf_comtemplate_c2 check (personalization in (0,1,2))
,constraint paf_comtemplate_c3 check (membership_req in (0,1,2)));


create table paf_ct_folder (
	folder_id	varchar2(40)	not null,
	internal_version	number(10)	not null,
	name	varchar2(254)	not null,
	description	varchar2(254)	null,
	parent	varchar2(40)	null,
	url_name	varchar2(254)	not null
,constraint paf_ct_folder_p primary key (folder_id)
,constraint paf_ct_folder_u unique (name));

create index paf_ct_fldrpnidx on paf_ct_folder (parent,name);

create table paf_ct_child_fldr (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_folder_id	varchar2(40)	not null
,constraint paf_ctchild_fldr_p primary key (folder_id,child_folder_id));


create table paf_ct_pagefolder (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_item_id	varchar2(40)	not null
,constraint paf_ctpagefolder_p primary key (folder_id,child_item_id));


create table paf_ct_page (
	page_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	url_name	varchar2(254)	not null,
	description	varchar2(254)	null,
	creation_date	timestamp	not null,
	last_modified	timestamp	not null,
	internal_version	number(10)	null,
	access_level	number(10)	not null,
	parent_folder	varchar2(40)	not null,
	layout_id	varchar2(40)	not null,
	allow_layout_chgs	number(1,0)	not null,
	palette_id	varchar2(40)	null,
	fixed	number(1,0)	not null,
	wireless_enabled	number(1,0)	not null
,constraint paf_ct_page_p primary key (page_id)
,constraint paf_ct_page_c1 check (allow_layout_chgs in (0,1))
,constraint paf_ct_page_c2 check (fixed in (0,1))
,constraint paf_ct_page_c3 check (wireless_enabled in (0,1)));


create table paf_ct_region (
	region_id	varchar2(40)	not null,
	internal_version	number(10)	not null,
	definition	varchar2(40)	not null,
	fixed	number(1,0)	not null
,constraint paf_ct_region_p primary key (region_id)
,constraint paf_ct_region_c1 check (fixed in (0,1)));


create table paf_ct_pg_regions (
	page_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	region_id	varchar2(40)	not null
,constraint paf_ctpg_regions_p primary key (page_id,tag));


create table paf_ct_region_grs (
	region_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	gear_id	varchar2(40)	not null
,constraint paf_ctregion_grs_p primary key (region_id,sequence_num));


create table paf_ct_gear (
	gear_id	varchar2(40)	not null,
	internal_version	number(10)	not null,
	name	varchar2(254)	null,
	description	varchar2(254)	null,
	gear_definition	varchar2(40)	not null,
	access_level	number(10)	not null,
	show_title_bars	number(1,0)	not null,
	is_shared	number(1,0)	not null,
	orig_gear_id	varchar2(40)	null
,constraint paf_ct_gear_p primary key (gear_id)
,constraint paf_ct_gear_c1 check (show_title_bars in (0,1)));


create table paf_ct_gr_iparams (
	gear_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	iparam_value	varchar2(254)	not null
,constraint paf_ctgr_iparams_p primary key (gear_id,tag));


create table paf_ct_gr_ln_names (
	gear_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_name	varchar2(255)	not null
,constraint paf_ctgrln_names_p primary key (gear_id,locale));


create table paf_ct_gr_ln_descs (
	gear_id	varchar2(40)	not null,
	locale	varchar2(30)	not null,
	localized_desc	varchar2(255)	not null
,constraint paf_ctgrln_descs_p primary key (gear_id,locale));


create table paf_ct_gr_fldrs (
	template_id	varchar2(40)	not null,
	gear_def_folder_id	varchar2(40)	not null
,constraint paf_ct_gr_fldrs_p primary key (template_id,gear_def_folder_id));


create table paf_ct_gears (
	template_id	varchar2(40)	not null,
	gear_id	varchar2(40)	not null
,constraint paf_ct_gears_p primary key (template_id,gear_id));


create table paf_ct_alt_gear (
	id	varchar2(40)	not null,
	source_id	varchar2(40)	not null,
	source_type	varchar2(40)	not null,
	version	number(10)	not null,
	message_type	varchar2(255)	not null,
	name	varchar2(40)	not null,
	value	varchar2(40)	not null,
	resource_bundle	varchar2(255)	not null
,constraint paf_ct_alt_gear_p primary key (id));


create table paf_ct_alt_gr_rel (
	id	varchar2(40)	not null,
	name	varchar2(40)	not null,
	gear_id	varchar2(40)	not null
,constraint paf_ctalt_gr_rel_p primary key (id,gear_id));


create table paf_ct_roles (
	template_id	varchar2(40)	not null,
	role_name	varchar2(254)	not null,
	role_id	varchar2(40)	not null
,constraint paf_ct_roles_pk primary key (template_id,role_name)
,constraint paf_ct_roles_fk foreign key (template_id) references paf_comm_template (template_id));


create table paf_ct_gr_acl (
	id	varchar2(254)	not null,
	indx	number(10)	not null,
	acl	varchar2(254)	not null);


create table paf_ct_gr_roles (
	gear_id	varchar2(40)	not null,
	role_name	varchar2(254)	not null,
	role_id	varchar2(40)	not null
,constraint paf_ct_gr_roles_pk primary key (gear_id,role_name)
,constraint paf_ct_gr_roles_fk foreign key (gear_id) references paf_ct_gear (gear_id));





-- the source for this section is 
-- profile_ddl.sql





create table paf_gear_user (
	gear_user_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null,
	gear_id	varchar2(40)	not null,
	user_id	varchar2(40)	not null
,constraint paf_gearuserpk primary key (gear_user_id));

create index paf_gu_ugix on paf_gear_user (user_id,gear_id);

create table paf_gu_params (
	gear_user_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	uparam_value	varchar2(254)	null
,constraint paf_guparamspk primary key (gear_user_id,tag));


create table paf_user_param (
	user_param_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null
,constraint paf_userparampk primary key (user_param_id));


create table paf_gr_uparams (
	gear_user_id	varchar2(40)	not null,
	name	varchar2(254)	not null,
	user_param_id	varchar2(40)	not null
,constraint paf_gruparamspk primary key (gear_user_id,user_param_id)
,constraint paf_gr_uparams1_f foreign key (gear_user_id) references paf_gear_user (gear_user_id)
,constraint paf_gr_uparams2_f foreign key (user_param_id) references paf_user_param (user_param_id));

create index paf_grupiddlix on paf_gr_uparams (user_param_id);

create table paf_user_prmvals (
	user_param_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	param_value	varchar2(254)	null
,constraint paf_uprmvalspk primary key (user_param_id,sequence_num)
,constraint paf_uprmvals1_f foreign key (user_param_id) references paf_user_param (user_param_id));


create table paf_usr_rgn (
	region_id	varchar2(40)	not null,
	definition_id	varchar2(40)	not null,
	internal_version	number(10)	default 0 not null
,constraint paf_usrrgnpk primary key (region_id));


create table paf_usr_rgn_gr (
	region_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	gear_id	varchar2(40)	not null
,constraint paf_usrrgngrpk primary key (region_id,sequence_num));


create table paf_usr_pg (
	page_id	varchar2(40)	not null,
	user_id	varchar2(40)	not null,
	source_page_id	varchar2(40)	null,
	name	varchar2(254)	null,
	url_name	varchar2(254)	null,
	folder_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	description	varchar2(254)	null,
	layout_id	varchar2(40)	null,
	palette_id	varchar2(40)	null,
	deleted	number(1,0)	not null,
	internal_version	number(10)	default 0 not null,
	creation_date	timestamp	null,
	last_modified	timestamp	null
,constraint paf_usrrgpk primary key (page_id)
,constraint paf_usrrgdeleted check (deleted in (0,1)));

create index paf_usr_pgusix on paf_usr_pg (user_id,source_page_id);

create table paf_usr_pg_rgn (
	page_id	varchar2(40)	not null,
	tag	varchar2(42)	not null,
	region_id	varchar2(40)	not null
,constraint paf_usrpgrgn primary key (page_id,tag));


create table paf_usr_pgfld (
	folder_id	varchar2(40)	not null,
	parent_id	varchar2(40)	null,
	name	varchar2(254)	not null,
	url_name	varchar2(254)	not null,
	description	varchar2(254)	null,
	internal_version	number(1,0)	default 0 not null,
	creation_date	timestamp	null,
	last_modified	timestamp	null
,constraint paf_usrpgfldpk primary key (folder_id));


create table paf_usr_cpgfld (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	child_folder_id	varchar2(40)	not null
,constraint paf_usrcpgfldpk primary key (folder_id,child_folder_id));


create table paf_usr_ppgfld (
	folder_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	page_id	varchar2(40)	not null
,constraint paf_usrppgfldpk primary key (folder_id,page_id));


create table paf_usr_cm (
	community_id	varchar2(40)	not null,
	user_id	varchar2(40)	not null,
	source_cm_id	varchar2(40)	null,
	page_folder_id	varchar2(40)	not null,
	default_page_id	varchar2(40)	null,
	internal_version	number(10)	null,
	creation_date	timestamp	null,
	last_modified	timestamp	null
,constraint paf_usrcmpk primary key (community_id));

create index paf_usr_cmusix on paf_usr_cm (user_id,source_cm_id);

create table paf_reg_url (
	id	varchar2(40)	not null,
	regURL	varchar2(72)	null
,constraint paf_reg_urlpk primary key (id));





-- the source for this section is 
-- communities_ddl.sql





create table fcg_usercomm_rel (
	id	varchar2(40)	not null,
	community_id	varchar2(40)	not null,
	sequence_num	number(20,0)	not null
,constraint fcg_usercomm_pk primary key (id,community_id));


create table fcg_added_mapper (
	id	varchar2(40)	not null,
	tstamp	date	null,
	favorite_name	varchar2(255)	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index fcg_addmap_comid on fcg_added_mapper (community_id);
create index fcg_addmap_gearid on fcg_added_mapper (gear_id);
create index fcg_addmap_usrid on fcg_added_mapper (user_id);

create table fcg_remove_mapper (
	id	varchar2(40)	not null,
	tstamp	date	null,
	favorite_name	varchar2(255)	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index fcg_remmap_comid on fcg_remove_mapper (community_id);
create index fcg_remmap_gearid on fcg_remove_mapper (gear_id);
create index fcg_remmap_usrid on fcg_remove_mapper (user_id);




-- the source for this section is 
-- docexch_ddl.sql





create table dex_document (
	document_id	varchar2(40)	not null,
	version	number(10)	default 0 not null,
	title	varchar2(254)	null,
	description	varchar2(400)	null,
	filename	varchar2(254)	null,
	author	varchar2(400)	null,
	filedatasize	number(10)	null,
	mimetype	varchar2(100)	null,
	creation_date	timestamp	null,
	gear_instance_ref	varchar2(40)	null,
	annotation_ref	varchar2(40)	null,
	status	number(10)	null,
	file_data	blob	null
,constraint dex_documentpk primary key (document_id));

create index gear_inst_ref_idx on dex_document (gear_instance_ref);

create table dex_viewed_mapper (
	id	varchar2(40)	not null,
	tstamp	date	null,
	doc_name	varchar2(255)	null,
	author_name	varchar2(255)	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index dex_vewmap_comid on dex_viewed_mapper (community_id);
create index dex_vewmap_gearid on dex_viewed_mapper (gear_id);
create index dex_vewmap_usrid on dex_viewed_mapper (user_id);

create table dex_split_doc (
	document_id	varchar2(40)	not null,
	version	number(10)	not null,
	title	varchar2(254)	null,
	description	varchar2(400)	null,
	filename	varchar2(254)	null,
	author	varchar2(400)	null,
	filedatasize	number(10)	null,
	mimetype	varchar2(100)	null,
	creation_date	timestamp	null,
	gear_instance_ref	varchar2(40)	null,
	annotation_ref	varchar2(40)	null,
	status	number(10)	null
,constraint dex_split_doc_pk primary key (document_id));

create index gear_spl_ref_idx on dex_split_doc (gear_instance_ref);

create table dex_split_file (
	document_id	varchar2(40)	not null,
	file_data	blob	null
,constraint dex_split_file_pk primary key (document_id));





-- the source for this section is 
-- soapclient_ddl.sql





create table soap_serv_conf (
	service_config_id	varchar2(40)	not null,
	version	number(10)	null,
	target_service_url	varchar2(254)	null,
	target_method_name	varchar2(254)	null,
	namespace_url	varchar2(254)	null,
	soap_action_uri	varchar2(254)	null,
	username	varchar2(40)	null,
	password	varchar2(40)	null
,constraint soap_serv_conf_p primary key (service_config_id));


create table soap_serv_param (
	serv_param_id	varchar2(40)	not null,
	param_name	varchar2(254)	null,
	param_type	varchar2(40)	null,
	param_value	varchar2(254)	null,
	version	number(10)	null
,constraint soap_serv_param_p primary key (serv_param_id));


create table soap_conf_param (
	service_config_id	varchar2(40)	not null,
	sequence_num	number(10)	not null,
	service_params	varchar2(40)	null
,constraint soap_conf_param_p primary key (service_config_id,sequence_num)
,constraint soap_conf_param1_f foreign key (service_config_id) references soap_serv_conf (service_config_id)
,constraint soap_conf_param2_f foreign key (service_params) references soap_serv_param (serv_param_id));

create index soap_conf_param1_i on soap_conf_param (service_params);

create table soap_install_conf (
	install_serv_id	varchar2(40)	not null,
	gear_def_id	varchar2(40)	not null,
	service_config_id	varchar2(40)	null,
	version	number(10)	null
,constraint soap_install_con_p primary key (install_serv_id)
,constraint soap_install_con_u unique (gear_def_id));


create table soap_instn_conf (
	instn_serv_id	varchar2(40)	not null,
	gear_instance_id	varchar2(40)	not null,
	service_config_id	varchar2(40)	null,
	version	number(10)	null
,constraint soap_instn_conf_p primary key (instn_serv_id)
,constraint soap_instn_conf_u unique (gear_instance_id));


create table soap_user_conf (
	user_serv_id	varchar2(40)	not null,
	user_id	varchar2(40)	null,
	gear_def_id	varchar2(40)	null,
	version	number(10)	null,
	gear_instance_id	varchar2(40)	null,
	service_config_id	varchar2(40)	null
,constraint soap_user_conf_p primary key (user_serv_id));

create index soap_user_conf_idx on soap_user_conf (user_id,gear_instance_id);




-- the source for this section is 
-- calendar_ddl.sql





create table cal_base_event (
	id	varchar2(40)	not null,
	name	varchar2(60)	not null,
	description	varchar2(255)	null,
	ignore_time	number(1,0)	null,
	gear_id	varchar2(40)	null,
	owner	varchar2(40)	null,
	item_acl	varchar2(1024)	null,
	version	number(10)	default 0 not null,
	start_date	timestamp	null,
	start_time	timestamp	not null,
	end_date	timestamp	null,
	end_time	timestamp	not null,
	local_start_time	timestamp	null,
	local_end_time	timestamp	null,
	time_zone	varchar2(5)	null,
	event_type	number(10)	not null,
	public_event	number(1,0)	not null
,constraint cal_base_event_pk primary key (id)
,constraint cal_base_event_c1 check (ignore_time in (0,1))
,constraint cal_base_event_c2 check (public_event in (0,1)));


create table cal_detail_event (
	event_id	varchar2(40)	not null,
	address1	varchar2(80)	null,
	address2	varchar2(80)	null,
	address3	varchar2(80)	null,
	city	varchar2(80)	null,
	state	varchar2(32)	null,
	country	varchar2(80)	null,
	postal_code	varchar2(10)	null,
	contact_name	varchar2(80)	null,
	contact_phone	varchar2(80)	null,
	contact_email	varchar2(255)	null,
	url	varchar2(254)	null
,constraint cal_detail_eventpk primary key (event_id)
,constraint cal_detail_eventfk foreign key (event_id) references cal_base_event (id));


create table cal_event_mapper (
	id	varchar2(40)	not null,
	tstamp	date	null,
	event_name	varchar2(255)	null,
	community_name	varchar2(255)	null,
	start_date	varchar2(80)	null,
	city	varchar2(80)	null,
	state	varchar2(32)	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index cal_evtmap_comid on cal_event_mapper (community_id);
create index cal_evtmap_gearid on cal_event_mapper (gear_id);
create index cal_evtmap_usrid on cal_event_mapper (user_id);




-- the source for this section is 
-- bookmarks_ddl.sql





create table bmg_bookmark_node (
	id	varchar2(40)	not null,
	version	number(10)	not null,
	type	number(20,0)	null,
	name	varchar2(100)	null,
	description	varchar2(500)	null,
	add_date	timestamp	null,
	last_visit	timestamp	null,
	last_modified	timestamp	null
,constraint bmg_bookmarknodepk primary key (id));


create table bmg_folder_child (
	folder_id	varchar2(40)	not null,
	sequence_num	number(20,0)	not null,
	child	varchar2(40)	null
,constraint bmg_folderchildpk primary key (folder_id,sequence_num)
,constraint bmg_folder_chil1_f foreign key (child) references bmg_bookmark_node (id)
,constraint bmg_folder_chil2_f foreign key (folder_id) references bmg_bookmark_node (id));

create index bmg_fdchildchildix on bmg_folder_child (child);

create table bmg_bookmark (
	id	varchar2(40)	not null,
	link	varchar2(300)	not null
,constraint bmg_bookmarkpk primary key (id)
,constraint bmg_bookmark1_f foreign key (id) references bmg_bookmark_node (id));





-- the source for this section is 
-- poll_ddl.sql





create table plg_poll (
	id	varchar2(40)	not null,
	title	varchar2(100)	not null,
	question_text	varchar2(500)	null,
	creation_date	date	not null,
	version	number(10)	default 0 not null
,constraint plg_poll_pk primary key (id));


create table plg_poll_response (
	id	varchar2(40)	not null,
	poll_id	varchar2(40)	not null,
	response_text	varchar2(200)	not null,
	short_name	varchar2(50)	null,
	bar_color	varchar2(6)	null,
	sort_order	number(10)	null,
	response_count	number(10)	null,
	version	number(10)	default 0 not null
,constraint plg_poll_rsp_pk primary key (id)
,constraint plg_poll_rsp_fk foreign key (poll_id) references plg_poll (id));

create index plg_pollrespix on plg_poll_response (poll_id);

create table plg_gear_poll_rel (
	id	varchar2(40)	not null,
	gear_id	varchar2(40)	not null,
	poll_id	varchar2(40)	not null,
	version	number(10)	default 0 not null
,constraint plg_poll_rel_pk primary key (poll_id,gear_id)
,constraint plg_poll_rel_fk foreign key (poll_id) references plg_poll (id));


create table plg_vote_mapper (
	id	varchar2(40)	not null,
	tstamp	date	null,
	poll_id	varchar2(40)	null,
	poll_selection	varchar2(40)	null,
	gear_id	varchar2(40)	null,
	community_id	varchar2(40)	null,
	user_id	varchar2(40)	null,
	msg_type	varchar2(255)	null);

create index plg_vtmp_comid on plg_vote_mapper (community_id);
create index plg_vtmp_gearid on plg_vote_mapper (gear_id);
create index plg_vtmp_usrid on plg_vote_mapper (user_id);




-- the source for this section is 
-- discussion_ddl.sql





create table dtg_board (
	id	varchar2(40)	not null,
	name	varchar2(50)	not null,
	description	varchar2(255)	null,
	owner	varchar2(40)	null,
	delete_flag	number(1,0)	not null,
	board_type	number(10)	not null,
	num_posts	number(10)	not null,
	last_post_time	timestamp	not null,
	creation_date	timestamp	not null,
	version	number(10)	default 0 not null
,constraint dtg_boardpk primary key (id)
,constraint dlt_flag_is_bool check (delete_flag in (0,1)));


create table dtg_thread (
	id	varchar2(40)	not null,
	userid	varchar2(40)	null,
	subject	varchar2(100)	not null,
	content	varchar2(2000)	null,
	message_board	varchar2(40)	not null,
	parent_thread	varchar2(40)	null,
	ultimate_thread	varchar2(40)	null,
	children_qty	number(10)	null,
	topic_resp_flag	number(1,0)	not null,
	delete_flag	number(1,0)	not null,
	creation_date	timestamp	not null,
	version	number(10)	default 0 not null
,constraint dtg_thread_p primary key (id)
,constraint dtg_thread1_f foreign key (message_board) references dtg_board (id)
,constraint dtg_thread2_f foreign key (parent_thread) references dtg_thread (id)
,constraint dtg_thread3_f foreign key (ultimate_thread) references dtg_thread (id)
,constraint resp_flag_enum check (topic_resp_flag in (0,1,2))
,constraint thr_dlt_flag_bool check (delete_flag in (0,1)));

create index dtg_threadboardix on dtg_thread (message_board);
create index dtg_threadparentix on dtg_thread (parent_thread);
create index dtg_threadultix on dtg_thread (ultimate_thread);

create table dtg_gear_boards (
	id	varchar2(40)	not null,
	gear_id	varchar2(40)	not null,
	message_board_id	varchar2(40)	not null
,constraint dtg_gearboardspk primary key (gear_id,message_board_id)
,constraint dtg_gear_boards1_f foreign key (message_board_id) references dtg_board (id));

create index dtg_gearboardix on dtg_gear_boards (message_board_id);

create table dtg_usr_gear_board (
	id	varchar2(40)	not null,
	gear_id	varchar2(40)	not null,
	message_board_id	varchar2(40)	not null,
	user_id	varchar2(40)	not null
,constraint dtg_usrgearbrdpk primary key (user_id,gear_id,message_board_id)
,constraint dtg_usr_gear_bo1_f foreign key (message_board_id) references dtg_board (id));

create index dtg_usrgrbrdbrdix on dtg_usr_gear_board (message_board_id);
create or replace view dtg_view_search
(gear_id,id,userid,subject,content,message_board,parent_thread,ultimate_thread,children_qty,topic_resp_flag,delete_flag,creation_date)
as
   SELECT b.gear_id, t.id, t.userid, t.subject, t.content, t.message_board,
   t. parent_thread,t. ultimate_thread, t.children_qty, t.topic_resp_flag ,
   t.delete_flag, t.creation_date
   FROM
     dtg_thread t, dtg_gear_boards b WHERE t.message_board = b.message_board_id
         ;




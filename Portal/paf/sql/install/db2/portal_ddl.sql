


--  @version $Id: //app/portal/version/10.0.3/paf/sql/portal_ddl.xml#2 $$Change: 651448 $

create table paf_folder (
	folder_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	type	numeric(1,0)	not null,
	parent	varchar(40)	default null,
	url_name	varchar(254)	not null
,constraint paf_folderpk primary key (folder_id)
,constraint paf_folder1_f foreign key (parent) references paf_folder (folder_id)
,constraint type_enum check (type in (0,1,2)));

create index paf_folderpnidx on paf_folder (parent,name);

create table paf_folder_acl (
	id	varchar(254)	not null,
	indx	integer	not null,
	acl	varchar(254)	default null);


create table paf_child_folder (
	folder_id	varchar(40)	not null,
	sequence_num	integer	not null,
	child_folder_id	varchar(40)	not null
,constraint paf_childfolderpk primary key (folder_id,child_folder_id)
,constraint paf_childfolder1_f foreign key (folder_id) references paf_folder (folder_id)
,constraint paf_childfolder2_f foreign key (child_folder_id) references paf_folder (folder_id));

create index paf_cfchldflddlix on paf_child_folder (child_folder_id);

create table paf_fldr_ln_names (
	folder_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_fldr_lnnamespk primary key (folder_id,locale)
,constraint paf_fldrlnnames1_f foreign key (folder_id) references paf_folder (folder_id));


create table paf_fldr_ln_descs (
	folder_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_fldr_lndescspk primary key (folder_id,locale)
,constraint paf_fldrlndescs1_f foreign key (folder_id) references paf_folder (folder_id));


create table paf_gear_param (
	gear_param_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	description	varchar(254)	default null,
	default_value	varchar(254)	default null,
	required	numeric(1,0)	not null,
	isreadonly	numeric(1,0)	default 0 not null
,constraint paf_gearparampk primary key (gear_param_id)
,constraint required_bool check (required in (0,1))
,constraint isreadonly_bool check (isreadonly in (0,1)));


create table paf_gear_prmvals (
	gear_param_id	varchar(40)	not null,
	sequence_num	integer	not null,
	param_value	varchar(254)	default null
,constraint paf_gprmvalspk primary key (gear_param_id,sequence_num)
,constraint paf_gprmvals1_f foreign key (gear_param_id) references paf_gear_param (gear_param_id));


create table paf_device_outputs (
	device_outputs_id	varchar(40)	not null,
	internal_version	integer	default 0 not null
,constraint paf_deviceoutspk primary key (device_outputs_id));


create table paf_device_output (
	device_output_id	varchar(40)	not null,
	type	varchar(10)	not null,
	url	varchar(254)	default null
,constraint paf_deviceoutpk primary key (device_output_id,type)
,constraint paf_device_out1_f foreign key (device_output_id) references paf_device_outputs (device_outputs_id));


create table paf_display_modes (
	display_modes_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	shared_mode	varchar(40)	default null,
	full_mode	varchar(40)	default null,
	popup_mode	varchar(40)	default null
,constraint paf_displaymodespk primary key (display_modes_id)
,constraint paf_displaymode1_f foreign key (shared_mode) references paf_device_outputs (device_outputs_id)
,constraint paf_displaymode2_f foreign key (full_mode) references paf_device_outputs (device_outputs_id)
,constraint paf_displaymode3_f foreign key (popup_mode) references paf_device_outputs (device_outputs_id));

create index paf_dmsmdlix on paf_display_modes (shared_mode);
create index paf_dmfmdlix on paf_display_modes (full_mode);
create index paf_dmpmdlix on paf_display_modes (popup_mode);

create table paf_title_template (
	title_template_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	servlet_context	varchar(254)	not null,
	template_dm	varchar(40)	default null,
	pre_template_dm	varchar(40)	default null,
	post_template_dm	varchar(40)	default null,
	small_image_url	varchar(254)	default null,
	small_image_alt	varchar(254)	default null,
	large_image_url	varchar(254)	default null,
	large_image_alt	varchar(254)	default null
,constraint paf_titletmplpk primary key (title_template_id)
,constraint paf_title_templ1_u unique (name)
,constraint paf_title_templ1_f foreign key (template_dm) references paf_display_modes (display_modes_id)
,constraint paf_title_templ2_f foreign key (pre_template_dm) references paf_display_modes (display_modes_id)
,constraint paf_title_templ3_f foreign key (post_template_dm) references paf_display_modes (display_modes_id));

create index paf_ttmptmpldlix on paf_title_template (template_dm);
create index paf_ttmppredlix on paf_title_template (pre_template_dm);
create index paf_ttmppstdlix on paf_title_template (post_template_dm);

create table paf_gear_modes (
	gear_modes_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	content_mode	varchar(40)	default null,
	help_mode	varchar(40)	default null,
	about_mode	varchar(40)	default null,
	preview_mode	varchar(40)	default null,
	user_cfg_mode	varchar(40)	default null,
	instance_cfg_mode	varchar(40)	default null,
	initial_cfg_mode	varchar(40)	default null,
	install_cfg_mode	varchar(40)	default null
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
	gear_def_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	parent_folder	varchar(40)	not null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	hide	numeric(1,0)	not null,
	timeout	numeric(19,0)	not null,
	jsr168	numeric(1,0)	default 0 not null,
	portlet_guid	varchar(254)	default null,
	render_async	numeric(1,0)	not null,
	should_cache	numeric(1,0)	not null,
	cache_timeout	numeric(19,0)	default null,
	intercept_errors	numeric(1,0)	not null,
	cover_err_cache	numeric(1,0)	not null,
	servlet_context	varchar(254)	not null,
	sharable	numeric(1,0)	not null,
	width	numeric(1,0)	not null,
	height	numeric(1,0)	not null,
	small_image_url	varchar(254)	default null,
	small_image_alt	varchar(254)	default null,
	large_image_url	varchar(254)	default null,
	large_image_alt	varchar(254)	default null,
	gear_modes	varchar(40)	default null
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
	gear_def_id	varchar(40)	not null,
	sequence_num	integer	not null,
	name	varchar(254)	not null
,constraint paf_gdcpropspk primary key (gear_def_id,sequence_num)
,constraint paf_gd_cprops1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id));


create table paf_gd_iparams (
	gear_def_id	varchar(40)	not null,
	name	varchar(254)	not null,
	gear_param_id	varchar(40)	not null
,constraint paf_gdiparamspk primary key (gear_def_id,gear_param_id)
,constraint paf_gd_iparams1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id)
,constraint paf_gd_iparams2_f foreign key (gear_param_id) references paf_gear_param (gear_param_id));

create index paf_gdipiddlix on paf_gd_iparams (gear_param_id);

create table paf_gd_uparams (
	gear_def_id	varchar(40)	not null,
	name	varchar(254)	not null,
	gear_param_id	varchar(40)	not null
,constraint paf_gduparamspk primary key (gear_def_id,gear_param_id)
,constraint paf_gd_uparams1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id)
,constraint paf_gd_uparams2_f foreign key (gear_param_id) references paf_gear_param (gear_param_id));

create index paf_gdupiddlix on paf_gd_uparams (gear_param_id);

create table paf_gd_l10n_names (
	gear_def_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_gd_l10nnamespk primary key (gear_def_id,locale)
,constraint paf_gd_l10nname1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id));


create table paf_gd_l10n_descs (
	gear_def_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_gd_l10ndescspk primary key (gear_def_id,locale)
,constraint paf_gd_l10ndesc1_f foreign key (gear_def_id) references paf_gear_def (gear_def_id));


create table paf_gear (
	gear_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	name	varchar(254)	default null,
	description	varchar(254)	default null,
	gear_definition	varchar(40)	not null,
	access_level	numeric(1,0)	not null,
	show_title_bars	numeric(1,0)	not null,
	parent_comm_id	varchar(40)	not null,
	is_shared	numeric(1,0)	not null
,constraint paf_gearpk primary key (gear_id)
,constraint paf_gear1_f foreign key (gear_definition) references paf_gear_def (gear_def_id)
,constraint gear_titlebarsbool check (show_title_bars in (0,1)));

create index paf_geargddlix on paf_gear (gear_definition);

create table paf_gear_acl (
	id	varchar(254)	not null,
	indx	integer	not null,
	acl	varchar(254)	default null);


create table paf_gear_iparams (
	gear_id	varchar(40)	not null,
	tag	varchar(42)	not null,
	iparam_value	varchar(254)	default null
,constraint paf_geariparamspk primary key (gear_id,tag)
,constraint paf_geariparams1_f foreign key (gear_id) references paf_gear (gear_id));


create table paf_gear_ln_names (
	gear_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_gear_lnnamespk primary key (gear_id,locale)
,constraint paf_gearlnnames1_f foreign key (gear_id) references paf_gear (gear_id));


create table paf_gear_ln_descs (
	gear_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_gear_lndescspk primary key (gear_id,locale)
,constraint paf_gearlndescs1_f foreign key (gear_id) references paf_gear (gear_id));


create table paf_region_def (
	region_def_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	name	varchar(254)	not null,
	width	numeric(1,0)	not null,
	height	numeric(1,0)	not null
,constraint paf_regiondefpk primary key (region_def_id)
,constraint paf_regiondefuk unique (name)
,constraint paf_regionhtbool check (height in (0,1))
,constraint paf_regionwithbool check (width in (0,1)));

-- Do not use REFERENCES paf_page(page_id) here because of circular references

create table paf_region (
	region_id	varchar(40)	not null,
	internal_version	integer	default 0 not null,
	definition	varchar(40)	not null,
	parent_page_id	varchar(40)	not null,
	fixed	numeric(1,0)	not null
,constraint paf_regionpk primary key (region_id)
,constraint paf_region1_f foreign key (definition) references paf_region_def (region_def_id)
,constraint regionfixedbool check (fixed in (0,1)));

create index paf_regdefdlix on paf_region (definition);

create table paf_region_gears (
	region_id	varchar(40)	not null,
	sequence_num	integer	not null,
	gear_id	varchar(40)	not null
,constraint paf_regiongearspk primary key (region_id,sequence_num)
,constraint paf_regiongears2_f foreign key (gear_id) references paf_gear (gear_id)
,constraint paf_regiongears1_f foreign key (region_id) references paf_region (region_id));

create index paf_reggriddlix on paf_region_gears (gear_id);

create table paf_style (
	style_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	servlet_context	varchar(254)	not null,
	css_url	varchar(254)	not null
,constraint paf_stylepk primary key (style_id)
,constraint paf_style1_u unique (name));


create table paf_styl_ln_names (
	style_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_styl_lnnamespk primary key (style_id,locale)
,constraint paf_styllnnames1_f foreign key (style_id) references paf_style (style_id));


create table paf_styl_ln_descs (
	style_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_styl_lndescspk primary key (style_id,locale)
,constraint paf_styllndescs1_f foreign key (style_id) references paf_style (style_id));


create table paf_col_palette (
	palette_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	servlet_context	varchar(254)	not null,
	small_image_url	varchar(254)	default null,
	small_image_alt	varchar(254)	default null,
	large_image_url	varchar(254)	default null,
	large_image_alt	varchar(254)	default null,
	pg_bg_image_url	varchar(254)	default null,
	pg_bg_color	char(6)	default null,
	pg_text_color	char(6)	default null,
	pg_link_color	char(6)	default null,
	pg_alink_color	char(6)	default null,
	pg_vlink_color	char(6)	default null,
	gt_bg_color	char(6)	default null,
	gt_text_color	char(6)	default null,
	gear_bg_color	char(6)	default null,
	gear_text_color	char(6)	default null,
	hl_bg_color	char(6)	default null,
	hl_text_color	char(6)	default null
,constraint paf_colpalettepk primary key (palette_id)
,constraint paf_col_palette1_u unique (name));


create table paf_cpal_ln_names (
	palette_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_cpal_lnnamespk primary key (palette_id,locale)
,constraint paf_cpallnnames1_f foreign key (palette_id) references paf_col_palette (palette_id));


create table paf_cpal_ln_descs (
	palette_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_cpal_lndescspk primary key (palette_id,locale)
,constraint paf_cpallndescs1_f foreign key (palette_id) references paf_col_palette (palette_id));


create table paf_layout (
	layout_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	not null,
	internal_version	integer	default null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	small_image_url	varchar(254)	default null,
	small_image_alt	varchar(254)	default null,
	large_image_url	varchar(254)	default null,
	large_image_alt	varchar(254)	default null,
	servlet_context	varchar(254)	not null,
	display_modes	varchar(40)	not null
,constraint paf_layoutpk primary key (layout_id)
,constraint paf_layout1_u unique (name)
,constraint paf_layout1_f foreign key (display_modes) references paf_display_modes (display_modes_id));

create index paf_lytdmdlix on paf_layout (display_modes);

create table paf_layout_regdefs (
	layout_id	varchar(40)	not null,
	sequence_num	integer	not null,
	region_def_id	varchar(40)	not null
,constraint paf_layoutregdfpk primary key (layout_id,sequence_num)
,constraint paf_layoutregdf1_f foreign key (layout_id) references paf_layout (layout_id)
,constraint paf_layoutregdf2_f foreign key (region_def_id) references paf_region_def (region_def_id));

create index paf_lytregddlix on paf_layout_regdefs (region_def_id);

create table paf_page_template (
	page_template_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	small_image_url	varchar(254)	default null,
	small_image_alt	varchar(254)	default null,
	large_image_url	varchar(254)	default null,
	large_image_alt	varchar(254)	default null,
	servlet_context	varchar(254)	not null,
	display_modes	varchar(40)	not null
,constraint paf_pagetmplpk primary key (page_template_id)
,constraint paf_pagetmplate1_u unique (name)
,constraint paf_pagetmplate1_f foreign key (display_modes) references paf_display_modes (display_modes_id));

create index paf_pagetmdmdlix on paf_page_template (display_modes);

create table paf_ptpl_ln_names (
	page_template_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_ptpl_lnnamespk primary key (page_template_id,locale)
,constraint paf_ptpllnnames1_f foreign key (page_template_id) references paf_page_template (page_template_id));


create table paf_ptpl_ln_descs (
	page_template_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_ptpl_lndescspk primary key (page_template_id,locale)
,constraint paf_ptpllndescs1_f foreign key (page_template_id) references paf_page_template (page_template_id));


create table paf_template (
	template_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	author	varchar(254)	default null,
	version	varchar(254)	default null,
	small_image_url	varchar(254)	default null,
	small_image_alt	varchar(254)	default null,
	large_image_url	varchar(254)	default null,
	large_image_alt	varchar(254)	default null,
	servlet_context	varchar(254)	not null,
	device_outputs	varchar(40)	not null
,constraint paf_tmplpk primary key (template_id)
,constraint paf_tmplate1_u unique (name)
,constraint paf_tmplate1_f foreign key (device_outputs) references paf_device_outputs (device_outputs_id));

create index paf_tmpdodlix on paf_template (device_outputs);
-- Cannot have default_page REFERENCES paf_page(page_id) because this is circular

create table paf_community (
	community_id	varchar(40)	not null,
	name	varchar(254)	not null,
	url_name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	default null,
	internal_version	integer	default null,
	enabled	numeric(1,0)	not null,
	access_level	numeric(1,0)	not null,
	parent_folder	varchar(40)	not null,
	page_folder	varchar(40)	not null,
	default_page	varchar(40)	default null,
	personalization	numeric(1,0)	not null,
	membership_req	numeric(1,0)	not null,
	page_template	varchar(40)	default null,
	title_template	varchar(40)	default null,
	li_template	varchar(40)	default null,
	lo_template	varchar(40)	default null,
	ad_template	varchar(40)	default null,
	rg_template	varchar(40)	default null,
	up_template	varchar(40)	default null,
	ia_template	varchar(40)	default null,
	page_style	varchar(40)	default null
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
	community_id	varchar(40)	not null,
	gear_id	varchar(40)	not null
,constraint paf_commgearspk primary key (community_id,gear_id)
,constraint paf_comm_gears1_f foreign key (community_id) references paf_community (community_id)
,constraint paf_comm_gears2_f foreign key (gear_id) references paf_gear (gear_id));

create index paf_commgriddlix on paf_comm_gears (gear_id);

create table paf_comm_gfldrs (
	community_id	varchar(40)	not null,
	gear_def_fldr_id	varchar(40)	not null
,constraint paf_commgfldrpk primary key (community_id,gear_def_fldr_id)
,constraint paf_comm_gfldrs1_f foreign key (community_id) references paf_community (community_id)
,constraint paf_comm_gfldrs2_f foreign key (gear_def_fldr_id) references paf_folder (folder_id));

create index paf_comm_gfldrs1_i on paf_comm_gfldrs (gear_def_fldr_id);

create table paf_comm_roles (
	community_id	varchar(40)	not null,
	role_name	varchar(254)	not null,
	role_id	varchar(40)	not null
,constraint paf_comm_roles_pk primary key (community_id,role_name)
,constraint paf_comm_roles_fk foreign key (community_id) references paf_community (community_id));


create table paf_base_comm_role (
	id	varchar(40)	not null,
	role_name	varchar(254)	not null,
	category	varchar(254)	not null
,constraint paf_basecomrole_pk primary key (role_name));


create table paf_gear_roles (
	gear_id	varchar(40)	not null,
	role_name	varchar(254)	not null,
	role_id	varchar(40)	not null
,constraint paf_gear_roles_pk primary key (gear_id,role_name)
,constraint paf_gear_roles_fk foreign key (gear_id) references paf_gear (gear_id));


create table paf_base_gear_role (
	gear_def_id	varchar(40)	not null,
	role_name	varchar(254)	not null
,constraint paf_basegearrolepk primary key (gear_def_id,role_name));


create table paf_community_acl (
	id	varchar(254)	not null,
	indx	integer	not null,
	acl	varchar(254)	default null);


create table paf_comm_lnames (
	community_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_commlnamespk primary key (community_id,locale)
,constraint paf_comm_lnames1_f foreign key (community_id) references paf_community (community_id));


create table paf_comm_ldescs (
	community_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_commldescspk primary key (community_id,locale)
,constraint paf_comm_ldescs1_f foreign key (community_id) references paf_community (community_id));


create table paf_page (
	page_id	varchar(40)	not null,
	name	varchar(254)	not null,
	url_name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	not null,
	internal_version	integer	default null,
	access_level	numeric(1,0)	not null,
	parent_folder	varchar(40)	not null,
	parent_comm_id	varchar(40)	not null,
	layout_id	varchar(40)	not null,
	allow_layout_chgs	numeric(1,0)	not null,
	palette_id	varchar(40)	default null,
	fixed	numeric(1,0)	not null,
	wireless_enabled	numeric(1,0)	not null
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
	page_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_page_lnnamespk primary key (page_id,locale)
,constraint paf_pagelnnames1_f foreign key (page_id) references paf_page (page_id));


create table paf_page_ln_descs (
	page_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_page_lndescspk primary key (page_id,locale)
,constraint paf_pagelndescs1_f foreign key (page_id) references paf_page (page_id));


create table paf_page_acl (
	id	varchar(254)	not null,
	indx	integer	not null,
	acl	varchar(254)	default null);


create table paf_page_regions (
	page_id	varchar(40)	not null,
	tag	varchar(42)	not null,
	region_id	varchar(40)	not null
,constraint paf_pageregionspk primary key (page_id,tag)
,constraint paf_pageregions1_f foreign key (page_id) references paf_page (page_id)
,constraint paf_pageregions2_f foreign key (region_id) references paf_region (region_id));

create index paf_pageriddlix on paf_page_regions (region_id);

create table paf_cf_child_item (
	folder_id	varchar(40)	not null,
	sequence_num	integer	not null,
	child_item_id	varchar(40)	not null
,constraint paf_cfchilditempk primary key (folder_id,child_item_id)
,constraint paf_cfchilditem2_f foreign key (child_item_id) references paf_community (community_id)
,constraint paf_cfchilditem1_f foreign key (folder_id) references paf_folder (folder_id));

create index paf_cfchlddlix on paf_cf_child_item (child_item_id);

create table paf_cf_gfldrs (
	comm_folder_id	varchar(40)	not null,
	gear_def_fldr_id	varchar(40)	not null
,constraint paf_cfgfldrspk primary key (comm_folder_id,gear_def_fldr_id)
,constraint paf_cf_gfldrs1_f foreign key (comm_folder_id) references paf_folder (folder_id)
,constraint paf_cf_gfldrs2_f foreign key (gear_def_fldr_id) references paf_folder (folder_id));

create index paf_cfgfldrs1_i on paf_cf_gfldrs (gear_def_fldr_id);

create table paf_pf_child_item (
	folder_id	varchar(40)	not null,
	sequence_num	integer	not null,
	child_item_id	varchar(40)	not null
,constraint paf_pfchilditempk primary key (folder_id,child_item_id)
,constraint paf_pfchilditem1_f foreign key (folder_id) references paf_folder (folder_id)
,constraint paf_pfchilditem2_f foreign key (child_item_id) references paf_page (page_id));

create index paf_pfcitemiddlix on paf_pf_child_item (child_item_id);

create table paf_gdf_child_item (
	folder_id	varchar(40)	not null,
	sequence_num	integer	not null,
	child_item_id	varchar(40)	not null
,constraint paf_gdfchilditempk primary key (folder_id,child_item_id)
,constraint paf_gdfchlditem1_f foreign key (folder_id) references paf_folder (folder_id)
,constraint paf_gdfchlditem2_f foreign key (child_item_id) references paf_gear_def (gear_def_id));

create index paf_gdfciiddlix on paf_gdf_child_item (child_item_id);

create table paf_comm_template (
	template_id	varchar(40)	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	internal_version	numeric(10,0)	default null,
	enabled	numeric(1,0)	not null,
	access_level	numeric(10,0)	not null,
	parent_folder	varchar(40)	not null,
	page_folder	varchar(40)	not null,
	default_page	varchar(40)	not null,
	personalization	numeric(1,0)	not null,
	membership_req	numeric(1,0)	not null,
	page_template	varchar(40)	not null,
	title_template	varchar(40)	not null,
	style	varchar(40)	not null
,constraint paf_comtemplate_p primary key (template_id)
,constraint paf_comtemplate_c1 check (enabled in (0,1))
,constraint paf_comtemplate_c2 check (personalization in (0,1,2))
,constraint paf_comtemplate_c3 check (membership_req in (0,1,2)));


create table paf_ct_folder (
	folder_id	varchar(40)	not null,
	internal_version	integer	not null,
	name	varchar(254)	not null,
	description	varchar(254)	default null,
	parent	varchar(40)	default null,
	url_name	varchar(254)	not null
,constraint paf_ct_folder_p primary key (folder_id)
,constraint paf_ct_folder_u unique (name));

create index paf_ct_fldrpnidx on paf_ct_folder (parent,name);

create table paf_ct_child_fldr (
	folder_id	varchar(40)	not null,
	sequence_num	integer	not null,
	child_folder_id	varchar(40)	not null
,constraint paf_ctchild_fldr_p primary key (folder_id,child_folder_id));


create table paf_ct_pagefolder (
	folder_id	varchar(40)	not null,
	sequence_num	integer	not null,
	child_item_id	varchar(40)	not null
,constraint paf_ctpagefolder_p primary key (folder_id,child_item_id));


create table paf_ct_page (
	page_id	varchar(40)	not null,
	name	varchar(254)	not null,
	url_name	varchar(254)	not null,
	description	varchar(254)	default null,
	creation_date	timestamp	not null,
	last_modified	timestamp	not null,
	internal_version	integer	default null,
	access_level	integer	not null,
	parent_folder	varchar(40)	not null,
	layout_id	varchar(40)	not null,
	allow_layout_chgs	numeric(1,0)	not null,
	palette_id	varchar(40)	default null,
	fixed	numeric(1,0)	not null,
	wireless_enabled	numeric(1,0)	not null
,constraint paf_ct_page_p primary key (page_id)
,constraint paf_ct_page_c1 check (allow_layout_chgs in (0,1))
,constraint paf_ct_page_c2 check (fixed in (0,1))
,constraint paf_ct_page_c3 check (wireless_enabled in (0,1)));


create table paf_ct_region (
	region_id	varchar(40)	not null,
	internal_version	integer	not null,
	definition	varchar(40)	not null,
	fixed	numeric(1,0)	not null
,constraint paf_ct_region_p primary key (region_id)
,constraint paf_ct_region_c1 check (fixed in (0,1)));


create table paf_ct_pg_regions (
	page_id	varchar(40)	not null,
	tag	varchar(42)	not null,
	region_id	varchar(40)	not null
,constraint paf_ctpg_regions_p primary key (page_id,tag));


create table paf_ct_region_grs (
	region_id	varchar(40)	not null,
	sequence_num	integer	not null,
	gear_id	varchar(40)	not null
,constraint paf_ctregion_grs_p primary key (region_id,sequence_num));


create table paf_ct_gear (
	gear_id	varchar(40)	not null,
	internal_version	integer	not null,
	name	varchar(254)	default null,
	description	varchar(254)	default null,
	gear_definition	varchar(40)	not null,
	access_level	integer	not null,
	show_title_bars	numeric(1,0)	not null,
	is_shared	numeric(1,0)	not null,
	orig_gear_id	varchar(40)	default null
,constraint paf_ct_gear_p primary key (gear_id)
,constraint paf_ct_gear_c1 check (show_title_bars in (0,1)));


create table paf_ct_gr_iparams (
	gear_id	varchar(40)	not null,
	tag	varchar(42)	not null,
	iparam_value	varchar(254)	not null
,constraint paf_ctgr_iparams_p primary key (gear_id,tag));


create table paf_ct_gr_ln_names (
	gear_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_name	varchar(255)	not null
,constraint paf_ctgrln_names_p primary key (gear_id,locale));


create table paf_ct_gr_ln_descs (
	gear_id	varchar(40)	not null,
	locale	varchar(30)	not null,
	localized_desc	varchar(255)	not null
,constraint paf_ctgrln_descs_p primary key (gear_id,locale));


create table paf_ct_gr_fldrs (
	template_id	varchar(40)	not null,
	gear_def_folder_id	varchar(40)	not null
,constraint paf_ct_gr_fldrs_p primary key (template_id,gear_def_folder_id));


create table paf_ct_gears (
	template_id	varchar(40)	not null,
	gear_id	varchar(40)	not null
,constraint paf_ct_gears_p primary key (template_id,gear_id));


create table paf_ct_alt_gear (
	id	varchar(40)	not null,
	source_id	varchar(40)	not null,
	source_type	varchar(40)	not null,
	version	integer	not null,
	message_type	varchar(255)	not null,
	name	varchar(40)	not null,
	value	varchar(40)	not null,
	resource_bundle	varchar(255)	not null
,constraint paf_ct_alt_gear_p primary key (id));


create table paf_ct_alt_gr_rel (
	id	varchar(40)	not null,
	name	varchar(40)	not null,
	gear_id	varchar(40)	not null
,constraint paf_ctalt_gr_rel_p primary key (id,gear_id));


create table paf_ct_roles (
	template_id	varchar(40)	not null,
	role_name	varchar(254)	not null,
	role_id	varchar(40)	not null
,constraint paf_ct_roles_pk primary key (template_id,role_name)
,constraint paf_ct_roles_fk foreign key (template_id) references paf_comm_template (template_id));


create table paf_ct_gr_acl (
	id	varchar(254)	not null,
	indx	integer	not null,
	acl	varchar(254)	not null);


create table paf_ct_gr_roles (
	gear_id	varchar(40)	not null,
	role_name	varchar(254)	not null,
	role_id	varchar(40)	not null
,constraint paf_ct_gr_roles_pk primary key (gear_id,role_name)
,constraint paf_ct_gr_roles_fk foreign key (gear_id) references paf_ct_gear (gear_id));

commit;



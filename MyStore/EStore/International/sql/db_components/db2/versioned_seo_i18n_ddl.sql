


-- @version $Id: //edu/ILT-Courses/main/COMM/StudentFiles/COM/setup/copy-files/apps/MyStore/EStore/International/sql/db_components/db2/versioned_seo_i18n_ddl.sql#3 $$Change: 635816 $

create table crs_seo_xlate (
	asset_version	numeric(19)	not null,
	workspace_id	varchar(40)	not null,
	branch_id	varchar(40)	not null,
	is_head	numeric(1)	not null,
	version_deleted	numeric(1)	not null,
	version_editable	numeric(1)	not null,
	pred_version	numeric(19)	default null,
	checkin_date	timestamp	default null,
	translation_id	varchar(40)	not null,
	title	varchar(254)	default null,
	display_name	varchar(254)	default null,
	description	varchar(254)	default null,
	keywords	varchar(254)	default null
,constraint crs_seo_xlate_pk primary key (translation_id,asset_version));

create index crs_seo_xlate_wsx on crs_seo_xlate (workspace_id);
create index crs_seo_xlate_cix on crs_seo_xlate (checkin_date);

create table crs_seo_seo_xlate (
	asset_version	numeric(19)	not null,
	seo_tag_id	varchar(40)	not null,
	locale	varchar(40)	not null,
	translation_id	varchar(40)	not null
,constraint crs_seo_tag_xlt_pk primary key (seo_tag_id,locale,asset_version));

commit;



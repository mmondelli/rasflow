create table script_run (
	script_run_id	   text primary key,
        script_filename    text,
	log_filename       text,
	hostname	   text,
	script_run_dir	   text,
        swift_version      text,
        final_state        text,
        start_time         text,
        duration           real
);

create table script_run_argument (
			script_run_id		text references script_run (script_run_id),
			arg				text,
			value			text
);

create table script_run_annot_text (
			app_exec_id		text references script_run (script_run_id),
			key				text,
			value			text
);

create table script_run_annot_numeric (
			app_exec_id		text references script_run (script_run_id),
			key				text,
			value			numeric
);

create table app_exec (
	app_exec_id			text primary key,
  script_run_id   		text references script_run(script_run_id),
	app_name			text,
	execution_site			text,
	start_time			text,
	duration			real,
	staging_in_duration		real,
	staging_out_duration		real,
	work_directory			text
);

create table app_exec_annot_text (
			app_exec_id		text references app_exec (app_exec_id),
			key				text,
			value			text
);

create table app_exec_annot_numeric (
			app_exec_id		text references app_exec (app_exec_id),
			key				text,
			value			numeric
);

create table app_exec_argument (
	app_exec_id			text references app_exec (app_exec_id),
	arg_position			integer,
	app_exec_arg			text
);

create table resource_usage (
       app_exec_id	    		text primary key references app_exec (app_exec_id),
       real_secs	       		real,
       kernel_secs             		real,
       user_secs	       		real,
       percent_cpu             		integer,
       max_rss	       	       		integer,
       avg_rss	       			integer,
       avg_tot_vm	       		integer,
       avg_priv_data     		integer,
       avg_priv_stack    		integer,
       avg_shared_text   		integer,
       page_size	       		integer,
       major_pgfaults    		integer,
       minor_pgfaults    		integer,
       swaps	       			integer,
       invol_context_switches		integer,
       vol_waits			integer,
       fs_reads				integer,
       fs_writes			integer,
       sock_recv			integer,
       sock_send			integer,
       signals				integer,
       exit_status			integer
);

create table file (
       file_id		text primary key,
       host		text,
       name		text,
       size		integer,
       modify		integer
);

create table file_annot_text (
			file_id		text references file (file_id),
			key				text,
			value			text
);

create table file_annot_numeric (
			file_id		text references file (file_id),
			key				text,
			value			numeric
);

create table staged_in (
       app_exec_id			text references app_exec (app_exec_id),
       file_id 				text references file (file_id)
);

create table staged_out (
       app_exec_id			text references app_exec (app_exec_id),
       file_id				text references file (file_id)
);

create view provenance_graph_edge as
	select app_exec_id as parent, file_id as child from staged_out
	union
	select file_id as parent, app_exec_id as child from staged_in;

create table vcf (file_id text references file (file_id), 
	chrom integer, 
	pos integer, 
	ref  varchar, 
	alt varchar, 
	vartype varchar, 
	dp integer, 
	mq integer, 
	af, 
	effect varchar, 
	impact varchar, 
	codon varchar, 
	aa varchar, 
	gene varchar, 
	trid varchar, 
	filter varchar
);

create table gff( 
	file_id text references file (file_id),
	id varchar,
	name varchar,
	parent varchar,
	biotype varchar,
	ccdsid varchar,
	description varchar,
	end varchar,
	feature varchar,
	frame varchar,
	gene_id varchar,
	havana_gene varchar,
	havana_transcript varchar,
	havana_version varchar,
	logic_name varchar,
	score varchar,
	seqname varchar,
	source varchar,
	start varchar,
	strand varchar,
	tag varchar,
	transcript_id varchar,
	transcript_support_level varchar,
	version varchar
);

create table input(
	script_run_id text references script_run (script_run_id),
	lib_forward varchar,
	lib_reverse varchar
);

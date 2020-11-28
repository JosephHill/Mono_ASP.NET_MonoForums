--
-- PostgreSQL database dump
--

-- \connect - postgres

--
-- TOC entry 1 (OID 0)
-- Name: aspnetforums; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE aspnetforums WITH TEMPLATE = template0 ENCODING = 0;


\connect aspnetforums 
-- postgres

SET search_path = public, pg_catalog;

--
-- TOC entry 117 (OID 16976)
-- Name: plpgsql_call_handler (); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION plpgsql_call_handler () RETURNS language_handler
    AS '$libdir/plpgsql', 'plpgsql_call_handler'
    LANGUAGE c;


--
-- TOC entry 116 (OID 16977)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: public; Owner: 
--

CREATE TRUSTED PROCEDURAL LANGUAGE plpgsql HANDLER plpgsql_call_handler;


-- \connect - pgadmin

SET search_path = public, pg_catalog;

--
-- TOC entry 59 (OID 24684)
-- Name: emails_emailid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE emails_emailid_seq
    START 10
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 66 (OID 24686)
-- Name: emails; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE emails (
    emailid integer DEFAULT nextval('"emails_emailid_seq"'::text) NOT NULL,
    subject character varying(128) NOT NULL,
    importance integer DEFAULT 1 NOT NULL,
    fromaddress character varying(75) NOT NULL,
    description character varying(200) DEFAULT '' NOT NULL,
    message text DEFAULT '' NOT NULL
);


--
-- TOC entry 60 (OID 24703)
-- Name: forumgroups_forumgroupid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE forumgroups_forumgroupid_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 67 (OID 24705)
-- Name: forumgroups; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE forumgroups (
    forumgroupid integer DEFAULT nextval('"forumgroups_forumgroupid_seq"'::text) NOT NULL,
    name character varying(256) NOT NULL,
    sortorder integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 61 (OID 24712)
-- Name: forums_forumid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE forums_forumid_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 68 (OID 24714)
-- Name: forums; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE forums (
    forumid integer DEFAULT nextval('"forums_forumid_seq"'::text) NOT NULL,
    forumgroupid integer NOT NULL,
    parentid integer DEFAULT 0 NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(3000) NOT NULL,
    datecreated timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    moderated boolean DEFAULT false NOT NULL,
    daystoview integer DEFAULT 30 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    sortorder integer DEFAULT 0 NOT NULL,
    totalposts integer DEFAULT 0 NOT NULL,
    totalthreads integer DEFAULT 0 NOT NULL,
    mostrecentpostid integer DEFAULT 0 NOT NULL,
    mostrecentthreadid integer DEFAULT 0 NOT NULL,
    mostrecentpostdate timestamp without time zone,
    mostrecentpostauthor character varying(50) DEFAULT '' NOT NULL,
    displaymask bytea DEFAULT '\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000' NOT NULL
);


--
-- TOC entry 69 (OID 24726)
-- Name: forumsread; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE forumsread (
    forumid integer NOT NULL,
    username character varying(50) NOT NULL,
    markreadafter integer DEFAULT 0 NOT NULL,
    lastactivity timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL
);


--
-- TOC entry 62 (OID 24730)
-- Name: messages_messageid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE messages_messageid_seq
    START 17
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 70 (OID 24732)
-- Name: messages; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE messages (
    messageid integer DEFAULT nextval('"messages_messageid_seq"'::text) NOT NULL,
    title character varying(250) NOT NULL,
    body character varying(3000) NOT NULL
);


--
-- TOC entry 71 (OID 24754)
-- Name: moderationaction; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE moderationaction (
    moderationaction integer NOT NULL,
    description character varying(256) NOT NULL
);


--
-- TOC entry 72 (OID 24757)
-- Name: moderationaudit; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE moderationaudit (
    moderatedon timestamp without time zone NOT NULL,
    postid integer NOT NULL,
    moderatedby character varying(50),
    moderationaction integer NOT NULL,
    notes character varying(1024)
);


--
-- TOC entry 73 (OID 24759)
-- Name: moderators; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE moderators (
    username character varying(50) NOT NULL,
    forumid integer NOT NULL,
    datecreated timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    emailnotification boolean DEFAULT false NOT NULL
);


--
-- TOC entry 63 (OID 24764)
-- Name: post_archive_postid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE post_archive_postid_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 74 (OID 24766)
-- Name: post_archive; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE post_archive (
    postid integer DEFAULT nextval('"post_archive_postid_seq"'::text) NOT NULL,
    threadid integer NOT NULL,
    parentid integer NOT NULL,
    postlevel integer NOT NULL,
    sortorder integer NOT NULL,
    subject character varying(256) NOT NULL,
    postdate timestamp without time zone NOT NULL,
    approved boolean NOT NULL,
    forumid integer NOT NULL,
    username character varying(50) NOT NULL,
    threaddate timestamp without time zone NOT NULL,
    totalviews integer NOT NULL,
    islocked boolean NOT NULL,
    ispinned boolean NOT NULL,
    pinneddate timestamp without time zone NOT NULL,
    body text NOT NULL
);


--
-- TOC entry 64 (OID 24772)
-- Name: posts_postid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE posts_postid_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 75 (OID 24774)
-- Name: posts; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE posts (
    postid integer DEFAULT nextval('"posts_postid_seq"'::text) NOT NULL,
    threadid integer DEFAULT 0 NOT NULL,
    parentid integer DEFAULT 0 NOT NULL,
    postlevel integer DEFAULT 0 NOT NULL,
    sortorder integer DEFAULT 0 NOT NULL,
    subject character varying(256) NOT NULL,
    postdate timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    forumid integer DEFAULT 0 NOT NULL,
    username character varying(50) NOT NULL,
    threaddate timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    totalviews integer DEFAULT 0 NOT NULL,
    islocked boolean DEFAULT false NOT NULL,
    ispinned boolean DEFAULT false NOT NULL,
    pinneddate timestamp without time zone NOT NULL,
    body text NOT NULL,
    posttype integer DEFAULT 0 NOT NULL
);


--
-- TOC entry 76 (OID 24792)
-- Name: postsread; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE postsread (
    username character varying(50) NOT NULL,
    postid integer NOT NULL,
    hasread boolean DEFAULT true NOT NULL
);


--
-- TOC entry 77 (OID 24797)
-- Name: privateforums; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE privateforums (
    forumid integer NOT NULL,
    rolename character varying(256) NOT NULL
);


--
-- TOC entry 78 (OID 24801)
-- Name: threadtrackings; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE threadtrackings (
    threadid integer NOT NULL,
    username character varying(50) NOT NULL,
    datecreated timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL
);


--
-- TOC entry 79 (OID 24805)
-- Name: userroles; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE userroles (
    rolename character varying(256) NOT NULL,
    description character varying(512) NOT NULL
);


--
-- TOC entry 65 (OID 24810)
-- Name: users_userid_seq; Type: SEQUENCE; Schema: public; Owner: pgadmin
--

CREATE SEQUENCE users_userid_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


--
-- TOC entry 80 (OID 24812)
-- Name: users; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE users (
    username character varying(50) NOT NULL,
    userid integer DEFAULT nextval('"users_userid_seq"'::text) NOT NULL,
    screenname character varying(50),
    "password" character varying(50) NOT NULL,
    email character varying(75) NOT NULL,
    forumview integer DEFAULT 2 NOT NULL,
    profileapproved boolean DEFAULT true NOT NULL,
    approved boolean DEFAULT true NOT NULL,
    "trusted" boolean DEFAULT false NOT NULL,
    fakeemail character varying(75) DEFAULT '' NOT NULL,
    url character varying(100) DEFAULT '' NOT NULL,
    signature character varying(256) DEFAULT '',
    datecreated timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    trackyourposts boolean DEFAULT false NOT NULL,
    lastlogin timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    lastactivity timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL,
    timezone integer DEFAULT -5 NOT NULL,
    "location" character varying(100) DEFAULT '' NOT NULL,
    occupation character varying(100) DEFAULT '' NOT NULL,
    interests character varying(100) DEFAULT '' NOT NULL,
    msn character varying(50) DEFAULT '' NOT NULL,
    yahoo character varying(50) DEFAULT '' NOT NULL,
    aim character varying(50) DEFAULT '' NOT NULL,
    icq character varying(50) DEFAULT '' NOT NULL,
    totalposts integer DEFAULT 0 NOT NULL,
    hasavatar boolean DEFAULT false NOT NULL,
    showunreadtopicsonly boolean DEFAULT false NOT NULL,
    style character varying(20) DEFAULT 'default'::bpchar NOT NULL,
    showavatar boolean DEFAULT false NOT NULL,
    dateformat character varying(10) DEFAULT 'MM-dd-yyyy'::bpchar NOT NULL,
    postvieworder boolean DEFAULT false NOT NULL,
    flatview boolean DEFAULT true NOT NULL,
    displayinmemberlist boolean DEFAULT true NOT NULL,
    avatarurl character varying(256) DEFAULT '' NOT NULL,
    avatartype integer DEFAULT 1 NOT NULL,
    attributes bytea DEFAULT '\\000\\000\\000\\000' NOT NULL
);


--
-- TOC entry 81 (OID 24821)
-- Name: usersinroles; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE usersinroles (
    username character varying(50) NOT NULL,
    rolename character varying(256) NOT NULL
);


--
-- TOC entry 82 (OID 24827)
-- Name: vote; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE vote (
    postid integer NOT NULL,
    vote character varying(2) NOT NULL,
    votecount integer NOT NULL
);


--
-- TOC entry 83 (OID 25051)
-- Name: forums_forum; Type: VIEW; Schema: public; Owner: pgadmin
--

CREATE VIEW forums_forum AS
    SELECT forums.forumid, forums.forumgroupid, forums.parentid, forums.name, forums.description, forums.datecreated, forums.daystoview, forums.moderated, forums.totalposts, forums.totalthreads AS totaltopics, forums.mostrecentpostid, forums.mostrecentthreadid, forums.mostrecentpostdate, forums.mostrecentpostauthor, forums.active, forums.sortorder, forums.displaymask FROM forums;


--
-- TOC entry 84 (OID 25054)
-- Name: forums_post; Type: VIEW; Schema: public; Owner: pgadmin
--

CREATE VIEW forums_post AS
    SELECT p.subject, p.body, p.postid, p.threadid, p.parentid, p.totalviews, p.islocked, p.ispinned, p.threaddate, p.pinneddate, p.username, p.forumid, p.postlevel, p.sortorder, p.approved, p.posttype, p.postdate, (SELECT forums.name FROM forums WHERE (forums.forumid = p.forumid)) AS forumname, (SELECT count(*) AS count FROM posts WHERE (((p.threadid = posts.threadid) AND (posts.approved = true)) AND (posts.postlevel <> 1))) AS replies, (SELECT posts.username FROM posts WHERE ((p.threadid = posts.threadid) AND (posts.approved = true)) ORDER BY posts.postdate DESC LIMIT 1) AS mostrecentpostauthor, (SELECT posts.postid FROM posts WHERE ((p.threadid = posts.threadid) AND (posts.approved = true)) ORDER BY posts.postdate DESC LIMIT 1) AS mostrecentpostid FROM posts p;


--
-- TOC entry 85 (OID 25058)
-- Name: forums_user; Type: VIEW; Schema: public; Owner: pgadmin
--

CREATE VIEW forums_user AS
    SELECT users.username, users."password", users.email, users.forumview, users.approved, users.profileapproved, users."trusted", users.fakeemail, users.url, users.signature, users.datecreated, users.trackyourposts, users.lastlogin, users.lastactivity, users.timezone, users."location", users.occupation, users.interests, users.msn, users.yahoo, users.aim, users.icq, users.totalposts, users.hasavatar, users.showunreadtopicsonly, users.style, users.avatartype, users.showavatar, users.dateformat, users.postvieworder, users.avatarurl, (SELECT count(*) AS count FROM moderators WHERE (moderators.username = users.username)) AS ismoderator, users.flatview, users.attributes FROM users;


--
-- TOC entry 86 (OID 25073)
-- Name: anonymoususers; Type: TABLE; Schema: public; Owner: pgadmin
--

CREATE TABLE anonymoususers (
    userid character(36) NOT NULL,
    lastlogin timestamp without time zone DEFAULT ('now'::text)::timestamp(3) with time zone NOT NULL
);


--
-- TOC entry 360 (OID 25828)
-- Name: dateadd (character varying, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION dateadd (character varying, integer, timestamp with time zone) RETURNS timestamp with time zone
    AS '
declare
	_datepart alias for $1;
	_number alias for $2;
	_date alias for $3;
	_interval varchar(100);
begin
    
    if _datepart ilike ''y%'' then
        _interval   := cast(_number as varchar)   || '' years'';
    end if;
    if _datepart ilike ''w%'' then
        _interval   := cast(_number as varchar)  || '' weeks'';
    end if;
    if _datepart ilike ''d%'' then
        _interval   := cast(_number as varchar)  || '' days'';
    end if;
    if _datepart ilike ''h%'' then
        _interval   := cast(_number as varchar)   || '' hours'';
    end if;
    if _datepart ilike ''n%'' then
        _interval   := cast(_number as varchar)   || '' minutes'';
    end if;
    if _datepart ilike ''mi%'' then
        _interval   := cast(_number as varchar)   || '' minutes'';
    else    
        if _datepart ilike ''m%'' then
            _interval   := cast(_number as varchar)   || '' months'';
        end if;
    end if;
    if _datepart ilike ''s%'' then
        _interval   := cast(_number as varchar)   || '' seconds'';
    end if;
    return _date + _interval::text::INTERVAL;
    
end;'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 361 (OID 25828)
-- Name: dateadd (character varying, integer, timestamp with time zone); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION dateadd (character varying, integer, timestamp with time zone) FROM PUBLIC;
GRANT ALL ON FUNCTION dateadd (character varying, integer, timestamp with time zone) TO PUBLIC;


--
-- TOC entry 118 (OID 27792)
-- Name: hasreadpost (character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION hasreadpost (character varying, integer, integer) RETURNS boolean
    AS '
DECLARE 
	_username alias for $1;
	_postid alias for $2;
	_forumid alias for $3;
	_hasread bool;
	_readafter int;
BEGIN
	_hasread := false;

	-- Do we have topics marked as read?
	SELECT into
		_readafter 
		MarkReadAfter 
	FROM ForumsRead 
	WHERE 
		username ilike _username AND 
		forumid = _forumid;

	if _readafter IS NOT NULL then
		if _readafter > _postid then
			RETURN true;
		end if;
	end if;
	
	SELECT INTO _hasread
		EXISTS (SELECT hasread FROM postsread WHERE username ilike _username AND postid = _postid);
	  
RETURN _hasread; 
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 119 (OID 27792)
-- Name: hasreadpost (character varying, integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION hasreadpost (character varying, integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION hasreadpost (character varying, integer, integer) TO PUBLIC;


--
-- TOC entry 120 (OID 27793)
-- Name: statistics_updateforumstatistics (integer, integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION statistics_updateforumstatistics (integer, integer, integer) RETURNS integer
    AS '
declare 
	_forumid alias for $1;
	_threadid alias for $2;
	_postid alias for $3;
	_username varchar(50);
	_postdate timestamp;
	_totalposts int;
	_totalthreads int;
begin
-- get values necessary to update the forum statistics
select into _username, _postdate, _totalposts, _totalthreads
	username, 
        postdate, 
	(select cast(count(*) as int4) from posts p2 where p2.forumid = p.forumid and p2.approved=true),
	(select cast(count(*) as int4) from posts p2 where p2.forumid = p.forumid and p2.approved=true and p2.postlevel=1)
from
	posts p
where
	postid = _postid;

-- do the update within a transaction

	update 
		forums
	set
		totalposts = _totalposts,
		totalthreads = _totalthreads,
		mostrecentpostid = _postid,
		mostrecentthreadid = _threadid,
		mostrecentpostdate = _postdate,
		mostrecentpostauthor = _username
	where
		forumid = _forumid;
    return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 121 (OID 27793)
-- Name: statistics_updateforumstatistics (integer, integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION statistics_updateforumstatistics (integer, integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION statistics_updateforumstatistics (integer, integer, integer) TO PUBLIC;


--
-- TOC entry 122 (OID 27794)
-- Name: maintenance_cleanforumsread (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION maintenance_cleanforumsread (integer) RETURNS integer
    AS '
	delete from forumsread
	where
		markreadafter = 0 and
		forumid = $1; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 123 (OID 27794)
-- Name: maintenance_cleanforumsread (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION maintenance_cleanforumsread (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION maintenance_cleanforumsread (integer) TO PUBLIC;


--
-- TOC entry 124 (OID 27795)
-- Name: maintenance_resetforumgroupsforinsert (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION maintenance_resetforumgroupsforinsert () RETURNS integer
    AS '
declare 
	_sortordercount int;
	_forumgroupid int;
	_sortorder int;
begin
	-- set our seed value
	_sortordercount := 1;
	-- use a temp table so we don''t get duplicate values
	perform 1 from pg_class where
	  relname = ''t_sortforumgroups'' and pg_table_is_visible(oid);
	if not found then
	    create temp table t_sortforumgroups (
		forumgroupid int,
		sortorder int
	    );
	end if;
	insert into t_sortforumgroups
	select forumgroupid, sortorder from forumgroups order by sortorder;
	-- get the lowest value
	select into _sortorder, _forumgroupid
	            sortorder, forumgroupid 
	from t_sortforumgroups 
	where sortorder >= 0 
	order by sortorder limit 1;
	while _sortordercount < (select cast(count(*) as int4) from forumgroups) loop
	  -- update the forum groups table
	  update forumgroups set sortorder = _sortordercount where forumgroupid = _forumgroupid;
	  -- increment our count
	  _sortordercount := _sortordercount + 1;
	  -- get the next forumgroupid to modify
	  select into _sortorder, _forumgroupid
	              sortorder, forumgroupid  
	  from t_sortforumgroups 
	  where sortorder > _sortorder 
	  order by sortorder limit 1; 
	end loop;
	delete from t_sortforumgroups;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 125 (OID 27795)
-- Name: maintenance_resetforumgroupsforinsert (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION maintenance_resetforumgroupsforinsert () FROM PUBLIC;
GRANT ALL ON FUNCTION maintenance_resetforumgroupsforinsert () TO PUBLIC;


--
-- TOC entry 2 (OID 27797)
-- Name: posthistory; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE posthistory AS (moderatedon timestamp without time zone,
	moderatedby character varying(50),
	description character varying(256),
	notes character varying(1024));


--
-- TOC entry 126 (OID 27798)
-- Name: moderate_getposthistory (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION moderate_getposthistory (integer, character varying) RETURNS SETOF posthistory
    AS '
select
	moderatedon,
	moderatedby,
	description,
	notes
from
	moderationaction,
	moderationaudit
where
	moderationaction.moderationaction = moderationaudit.moderationaction and
	postid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 127 (OID 27798)
-- Name: moderate_getposthistory (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION moderate_getposthistory (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION moderate_getposthistory (integer, character varying) TO PUBLIC;


--
-- TOC entry 3 (OID 27800)
-- Name: uservisitsbyday; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE uservisitsbyday AS (statdate timestamp without time zone,
	usercount integer,
	postcount integer,
	avgpostperuser numeric(5,2),
	postcountaspnetteam integer,
	percentagepostsaspnetteam numeric(5,2));


--
-- TOC entry 128 (OID 27801)
-- Name: reports_uservisitsbyday (integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION reports_uservisitsbyday (integer, boolean) RETURNS SETOF uservisitsbyday
    AS '
declare 
	_daysbackin alias for $1;
	_sumdaycount alias for $2;
	_usercount int4;
	_postcount int4;
	_aspnetteampostcount int4;
	_averagepostperuser decimal(5,2);
	_percentagepostsaspnetteam decimal(5,2);
	_forumstartdate timestamp;
	_rec uservisitsbyday%ROWTYPE;
	_daysback int4;
begin
	_daysback := _daysbackin;
	if (_daysback > 0) then
		select into _forumstartdate postdate from posts order by postdate limit 1;
		_daysback := current_timestamp(3)::date - _forumstartdate::date;
	end if;
	-- create a temporary table to insert results into
	
	perform 1 from pg_class where
	  relname = ''t_uservisitsbyday'' and pg_table_is_visible(oid);
	if not found then
	    create temp table t_uservisitsbyday (
		statdate timestamp,
		usercount int,
		postcount int,
		avgpostperuser decimal(5,2),
		postcountaspnetteam int,
		percentagepostsaspnetteam decimal(5,2)
	    );
	end if;
-- do for each day
while _daysback <= 0 loop
	if _sumdaycount = true and _daysback < -1 then
		-- users visited in last day
		select into _usercount cast(count(*) as int4) 
		from users 
		where 
			extract(doy from lastactivity) >= extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', lastactivity) >= date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3)));
		
		-- users posted in last day
		select into _postcount cast(count(*) as int4) 
		from posts 
		where 
			extract(doy from postdate) >= extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', postdate) >= date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3)));
			
                -- aspnet team post count
		select into _aspnetteampostcount cast(count(*) as int4) 
		from posts 
		where 
			extract(doy from postdate) >= extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', postdate) >= date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3))) and 
			username in (select username from usersinroles where rolename = ''aspnetteam'');
			
	else
		-- users visited in last day
		select into _usercount cast(count(*) as int4) 
		from users 
		where 
			extract(doy from lastactivity) = extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', lastactivity) = date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3)));
		
		-- users posted in last day
		select into _postcount cast(count(*) as int4) 
		from posts 
		where 
			extract(doy from postdate) = extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', postdate) = date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3)));
			
                -- aspnet team post count
		select into _aspnetteampostcount cast(count(*) as int4) 
		from posts 
		where 
			extract(doy from postdate) = extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', postdate) = date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3))) and 
			username in (select username from usersinroles where rolename = ''aspnetteam'');
	end if;
	
	-- calculate avg. post/user
	_averagepostperuser := cast(_postcount as decimal) / cast(_usercount as decimal);
	-- calculate avg. post/user from asp.net team
	_percentagepostsaspnetteam := cast(_aspnetteampostcount as decimal) / cast(_postcount as decimal);
	insert into 
		t_uservisitsbyday
	values (
		dateadd(''dd'', _daysback, current_timestamp(3)), 
		_usercount,
		_postcount,
		_averagepostperuser,
		_aspnetteampostcount,
		_percentagepostsaspnetteam
		);
	_daysback := _daysback + 1;
end loop;
for _rec in
select 
	statdate,
	usercount,
	postcount,
	avgpostperuser,
	postcountaspnetteam,
	percentagepostsaspnetteam
from
	t_uservisitsbyday
order by
	statdate desc		
loop
	return next _rec;
end loop;
delete from t_uservisitsbyday;
return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 129 (OID 27801)
-- Name: reports_uservisitsbyday (integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION reports_uservisitsbyday (integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION reports_uservisitsbyday (integer, boolean) TO PUBLIC;


--
-- TOC entry 4 (OID 27803)
-- Name: foruser; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE foruser AS (postid integer,
	parentid integer,
	threadid integer,
	postlevel integer,
	sortorder integer,
	username character varying(50),
	subject character varying(256),
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	approved boolean,
	forumid integer,
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	hasread boolean);


--
-- TOC entry 130 (OID 27804)
-- Name: search_foruser (integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION search_foruser (integer, integer, character varying, character varying) RETURNS SETOF foruser
    AS '
declare 
	_pageindex alias for $1;
	_pagesize alias for $2;
	_usernametosearchfor alias for $3;
	_username alias for $4;
	_rec foruser%ROWTYPE;
	_pagelowerbound int;
begin
-- set the page bounds
_pagelowerbound := _pagesize * _pageindex;

-- select into the table
if _username is null then
	for _rec in
	select
		postid,
		parentid,
		threadid,
		postlevel,
		sortorder,
		username,
		subject,
		postdate,
		threaddate,
		approved,
		forumid,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
		body,
		totalviews,
		islocked,
		false as hasread -- not used
	from
		posts p
	where
		username ilike _usernametosearchfor and
		forumid not in (select forumid from privateforums)
	order by
		postdate desc
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
else
	for _rec in
	select
		postid,
		parentid,
		threadid,
		postlevel,
		sortorder,
		username,
		subject,
		postdate,
		threaddate,
		approved,
		forumid,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
		body,
		totalviews,
		islocked,
		false as hasread -- not used
	from
		posts p
	where
		username ilike _usernametosearchfor and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
	order by
		postdate desc
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
end if;
return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 131 (OID 27804)
-- Name: search_foruser (integer, integer, character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION search_foruser (integer, integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION search_foruser (integer, integer, character varying, character varying) TO PUBLIC;


--
-- TOC entry 5 (OID 27806)
-- Name: totalmoderationactions; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE totalmoderationactions AS (description character varying(256),
	totalactions integer);


--
-- TOC entry 132 (OID 27807)
-- Name: statistics_getmoderationactions (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION statistics_getmoderationactions () RETURNS SETOF totalmoderationactions
    AS '
select distinct
	description, 
	(select cast(count(moderationaction) as int4) from moderationaudit m2 where m2.moderationaction = m.moderationaction) as totalactions
from 
	moderationaudit m, 
	moderationaction a 
where 
	m.moderationaction = a.moderationaction 
order by 
	totalactions desc 
--exec statistics_getmostactivemoderators; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 133 (OID 27807)
-- Name: statistics_getmoderationactions (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION statistics_getmoderationactions () FROM PUBLIC;
GRANT ALL ON FUNCTION statistics_getmoderationactions () TO PUBLIC;


--
-- TOC entry 6 (OID 27809)
-- Name: mostactivemoderators; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE mostactivemoderators AS (username character varying(50),
	postsmoderated integer);


--
-- TOC entry 134 (OID 27810)
-- Name: statistics_getmostactivemoderators (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION statistics_getmostactivemoderators () RETURNS SETOF mostactivemoderators
    AS '
select distinct 
	moderatedby as username, 
	(select cast(count(moderationaction) as int4) from moderationaudit m2 where m2.moderatedby = m.moderatedby) as postsmoderated
from 
	moderationaudit m 
order by 
	postsmoderated desc limit 10; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 135 (OID 27810)
-- Name: statistics_getmostactivemoderators (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION statistics_getmostactivemoderators () FROM PUBLIC;
GRANT ALL ON FUNCTION statistics_getmostactivemoderators () TO PUBLIC;


--
-- TOC entry 7 (OID 27812)
-- Name: mostactiveusers; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE mostactiveusers AS (username character varying,
	totalposts integer);


--
-- TOC entry 136 (OID 27813)
-- Name: statistics_getmostactiveusers (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION statistics_getmostactiveusers () RETURNS SETOF mostactiveusers
    AS '
select 
	username,
	totalposts
from
	users
where
	username not in (select username from usersinroles where rolename = ''aspnetteam'')
order by
	totalposts desc limit 3;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 137 (OID 27813)
-- Name: statistics_getmostactiveusers (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION statistics_getmostactiveusers () FROM PUBLIC;
GRANT ALL ON FUNCTION statistics_getmostactiveusers () TO PUBLIC;


--
-- TOC entry 138 (OID 27814)
-- Name: statistics_resetforumstatistics (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION statistics_resetforumstatistics (integer) RETURNS integer
    AS '
declare 
	_forumid alias for $1;
	_forumcount int;
	_threadid int;
	_postid int;
	t_found int;
begin
	_forumcount := 1;
	if _forumid = 0 then
	  while _forumcount < (select max(forumid) from forums) loop
		select into t_found 1 from forums where forumid = _forumcount;
		if found then
			select into 	_threadid, _postid 
					threadid, postid
			from posts where forumid = _forumcount and approved = true order by postid desc limit 1;
			if _threadid is not null then
				perform statistics_updateforumstatistics (_forumcount, _threadid, _postid);
			end if;
		end if;
		_forumcount := _forumcount + 1;
		_threadid := null;
	  end loop;
	else
		select into 	_threadid, _postid 
				threadid, postid 
		from posts where forumid = _forumid and approved = true order by postid desc limit 1;
		perform statistics_updateforumstatistics(_forumid, _threadid, _postid);
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 139 (OID 27814)
-- Name: statistics_resetforumstatistics (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION statistics_resetforumstatistics (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION statistics_resetforumstatistics (integer) TO PUBLIC;


--
-- TOC entry 358 (OID 27815)
-- Name: statistics_resettopposters (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION statistics_resettopposters () RETURNS integer
    AS '
declare 
	_usercount int;
	_loopcounter int;
	_rec RECORD;
begin
	_loopcounter := 1;
	for _rec in
	select
		username
	from
		users
	order by totalposts desc limit 500 loop
		
		update users
 		set attributes = decode(lpad(to_hex(encode(attributes, ''hex'')::int8 & x''fffffff3''::int8), 8, ''0''), ''hex'')
		where username = _rec.username;

		-- top 25 poster
		if (_loopcounter < 26) then
			update users
			set attributes = decode(lpad(to_hex((encode(attributes, ''hex'')::int8 ^ 4)::int8), 8, ''0''), ''hex'')
			where username = _rec.username;
		end if;
		-- top 50 poster
		if (_loopcounter > 25) and (_loopcounter < 51) then
			update users
			set attributes = decode(lpad(to_hex((encode(attributes, ''hex'')::int8 ^ 8)::int8), 8, ''0''), ''hex'')
			where username = _rec.username;
		end if;
		-- top 100 poster
		if (_loopcounter > 50) and (_loopcounter < 101) then
			update users
			set attributes = decode(lpad(to_hex((encode(attributes, ''hex'')::int8 ^ 16)::int8), 8, ''0''), ''hex'')
			where username = _rec.username;
		end if;
		_loopcounter := _loopcounter + 1;
	end loop;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 359 (OID 27815)
-- Name: statistics_resettopposters (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION statistics_resettopposters () FROM PUBLIC;
GRANT ALL ON FUNCTION statistics_resettopposters () TO PUBLIC;


--
-- TOC entry 140 (OID 27816)
-- Name: forums_addforum (character varying, character varying, integer, boolean, integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_addforum (character varying, character varying, integer, boolean, integer, boolean) RETURNS integer
    AS '
	-- insert a new forum
	insert into forums (forumgroupid, name, description, moderated, daystoview, active)
	values ($3, $1, $2, $4, $5, $6); 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 141 (OID 27816)
-- Name: forums_addforum (character varying, character varying, integer, boolean, integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_addforum (character varying, character varying, integer, boolean, integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_addforum (character varying, character varying, integer, boolean, integer, boolean) TO PUBLIC;


--
-- TOC entry 142 (OID 27817)
-- Name: forums_addforumgroup (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_addforumgroup (character varying) RETURNS integer
    AS '
	-- insert a new forum
	insert into 
		forumgroups 
		(name)
	values 
		($1);
	-- reset the sort order
	select maintenance_resetforumgroupsforinsert(); 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 143 (OID 27817)
-- Name: forums_addforumgroup (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_addforumgroup (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_addforumgroup (character varying) TO PUBLIC;


--
-- TOC entry 346 (OID 27818)
-- Name: forums_addforumtorole (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_addforumtorole (integer, character varying) RETURNS integer
    AS '
declare
	_forumid alias for $1;
	_rolename alias for $2;
	t_found int;
begin
    select into t_found 1 
	where   (select 1 from privateforums where forumid=_forumid and rolename ilike _rolename) = 1 and
		(select 1 from forums where forumid=_forumid) = 1 and
		(select 1 from userroles where rolename ilike _rolename) = 1;
    if not found then
        insert into
            privateforums(forumid, rolename)
        values
            (_forumid, _rolename); 
    end if;
    return 1;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 347 (OID 27818)
-- Name: forums_addforumtorole (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_addforumtorole (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_addforumtorole (integer, character varying) TO PUBLIC;


--
-- TOC entry 144 (OID 27819)
-- Name: forums_addmoderatedforumforuser (character varying, integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_addmoderatedforumforuser (character varying, integer, boolean) RETURNS integer
    AS '
	-- add a row to the moderators table
	-- if the user wants to add all forums, ahead and delete all of the other forums
	delete from moderators where username ilike $1 and $2 = 0;
	-- now insert the new row into the table
	insert into moderators (username, forumid, emailnotification)
	values ($1, $2, $3); 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 145 (OID 27819)
-- Name: forums_addmoderatedforumforuser (character varying, integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_addmoderatedforumforuser (character varying, integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_addmoderatedforumforuser (character varying, integer, boolean) TO PUBLIC;


--
-- TOC entry 270 (OID 27820)
-- Name: forums_addpost (integer, integer, character varying, character varying, text, boolean, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_addpost (integer, integer, character varying, character varying, text, boolean, timestamp without time zone) RETURNS integer
    AS '
declare 
	_forumidin alias for $1;
	_replytopostid alias for $2;
	_subject alias for $3;
	_usernamein alias for $4;
	_body alias for $5;
	_islocked alias for $6;
	_pinnedin alias for $7;
	_forumid int;
        _pinned timestamp;
	_maxsortorder int;
	_parentlevel int;
	_threadid int;
	_parentsortorder int;
	_nextsortorder int;
	_newpostid int;
	_approvedpost bool;
	_moderatedforum bool;
	_ispinned bool;
	t_found int;
	_trackthread bool;
	_postcount int;
	_username varchar(50);
begin
  select into _username username from users where username ilike _usernamein;
  -- is the post pinned?
  _pinned := _pinnedin;
  _forumid := _forumidin;
  if _pinned is null then
	_ispinned := 0;
	_pinned := current_timestamp(3);
  else
	_ispinned := 1;
  end if;

  -- is this forum moderated?
  if _forumid = 0 and _replytopostid != 0 then
	-- we need to get the forum id
	select into _forumid  forumid from posts where postid = _replytopostid;
  end if;
  select into _moderatedforum moderated from forums where forumid = _forumid;

  -- determine if this post will be approved
  -- if the forum is not moderated, then the post will be approved
  if _moderatedforum = false then
	_approvedpost := true;
  else
	-- ok, this is a moderated forum.  is this user trusted?  if he is, then the post is approved ; else it is not
	if (select trusted from users where username ilike _username) = true then
		_approvedpost := true;
	else
		_approvedpost := false;
        end if;
  end if;
  if _replytopostid = 0 then -- new post
    -- do insert into posts table
    insert into
	posts ( forumid, threadid, parentid, postlevel, sortorder, subject, pinneddate, ispinned, username, approved, body, islocked )
    values 
	(_forumid, 0, 0, 1, 1, _subject, _pinned, _ispinned, _username, _approvedpost, _body, _islocked);
    -- get the new post id
    select into _newpostid cast(currval(''posts_postid_seq'') AS int4);

    -- update posts with the new post id
    update 
	posts
    set 
	threadid = _newpostid,
        parentid = _newpostid
    where 
	postid = _newpostid;
   
    -- do we need to track the threads for this user?
    _threadid := _newpostid;
  else -- _replytoid <> 0 means reply to an existing post
    -- get post information for what we are replying to
    select into _parentlevel, _threadid, _parentsortorder, _forumid
		postlevel, threadid, sortorder, forumid
    from 
	   posts
    where 
           postid = _replytopostid;

    -- is there another post at the same level or higher
    select into t_found 1 
               from posts 
               where postlevel <= _parentlevel 
               and sortorder > _parentsortorder
               and threadid = _threadid;
    if found then
        -- find the next post at the same level or higher
        select into _nextsortorder
		    min(sortorder)
        from 
		posts
        where 
		postlevel <= _parentlevel 
        	and sortorder > _parentsortorder
	        and threadid = _threadid;

        -- move the existing posts down
	update 
		posts
        set 
		sortorder = sortorder + 1
        where 
		threadid = _threadid
	        and sortorder >= _nextsortorder;

        --  and put this one into place
        insert into
		posts (forumid, threadid, parentid, postlevel, sortorder, subject, postdate, ispinned, username, approved, body, islocked )
        values 
		(_forumid, _threadid, _replytopostid, _parentlevel + 1, _nextsortorder, _subject, _pinned, _ispinned, _username, _approvedpost, _body, _islocked );
	-- clean up postsread
	delete from postsread where postid = _threadid and username not ilike _username;
    else -- there are no posts at this level or above
    	-- find the highest sort order for this parent
    	select into _maxsortorder
			max(sortorder)
    	from 
		posts
    	where 
		threadid = _threadid;

	-- insert the new post
    	insert into
		posts (forumid, threadid, parentid, postlevel, sortorder, subject, pinneddate, ispinned, username, approved, body, islocked )
    	values 
		(_forumid, _threadid, _replytopostid, _parentlevel + 1, _maxsortorder + 1, _subject, _pinned, _ispinned, _username, _approvedpost, _body, _islocked );

	-- clean up postsread
	delete from postsread where postid = _threadid and username not ilike _username;
     end if;
     
     select into _newpostid cast(currval(''posts_postid_seq'') AS int4);
     
     -- if this message is approved, update the thread date
     if _approvedpost = true then
	update 
		posts 
	set 
		threaddate = current_timestamp(3)
	where 
		threadid = _threadid;
     end if;
  end if;
  -- update the users tracking for the new post (if needed)

  select into _trackthread
		trackyourposts
  from 
	users
  where 
	username ilike _username;

  if _trackthread = true then
	-- if a row already exists to track this thread for this user, do nothing - otherwise add the row
	select into t_found 1 from threadtrackings where threadid = _threadid and username ilike _username;
        if not found then
		insert into threadtrackings (threadid, username)
		values(_threadid, _username);
        end if;
  end if;

  -- update the user''s post count
 
  -- get the current number of posts
  select into _postcount totalposts from users where username ilike _username;
  -- update value
  _postcount := _postcount + 1;
  update users set totalposts = _postcount where username ilike _username;
  -- update the forum statitics
  if _approvedpost = true then
     perform statistics_updateforumstatistics(_forumid, _threadid, _newpostid);
     -- clean up unnecessary columns in forumsread
     perform maintenance_cleanforumsread(_forumid);
  end if;
  return _newpostid; 
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 271 (OID 27820)
-- Name: forums_addpost (integer, integer, character varying, character varying, text, boolean, timestamp without time zone); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_addpost (integer, integer, character varying, character varying, text, boolean, timestamp without time zone) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_addpost (integer, integer, character varying, character varying, text, boolean, timestamp without time zone) TO PUBLIC;


--
-- TOC entry 344 (OID 27822)
-- Name: forums_addusertorole (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_addusertorole (character varying, character varying) RETURNS integer
    AS '
declare
	_username alias for $1;
	_rolename alias for $2;
	t_found int;
begin
  select into t_found 1 from usersinroles where username ilike _username and rolename ilike _rolename;
  if not found then
    insert into
	usersinroles
    values
	(_username, _rolename); 
  end if;
  return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 345 (OID 27822)
-- Name: forums_addusertorole (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_addusertorole (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_addusertorole (character varying, character varying) TO PUBLIC;


--
-- TOC entry 336 (OID 27823)
-- Name: forums_approvemoderatedpost (integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_approvemoderatedpost (integer, character varying, character varying) RETURNS integer
    AS '
declare 
	_postid alias for $1;
	_approvedby alias for $2;
	_trusted alias for $3;
	_forumid int;
	_threadid int;
begin
	-- first make sure that the post is already non-approved
	if (select approved from posts where postid = _postid limit 1) = true then
		-- its already been approved, return 0
		return 0;
	else
		-- approve the post
		update 
			posts
		set 
			approved = true
		where 
			postid = _postid;

		-- get details about the thread and forum this post belongs in
		select into 	_forumid, _threadid
				forumid, threadid
		from
			posts
		where
			postid = _postid;

		-- update the thread date
		update 
			posts
		set 
			threaddate = current_timestamp(3)
		where 
			threadid = _threadid;

		-- update the moderationaudit table
		insert into
			moderationaudit
		values
			(current_timestamp(3), _postid, _approvedby, 1, null);

		-- update the forums statistics
		perform statistics_resetforumstatistics (_forumid);
		-- are we updating the status of a user?
		if (_trusted is not null) then
			-- mark the user as trusted
			update
				users
			set
				trusted = true
			where
				username ilike _trusted;
			-- update the moderationaudit table
			insert into
				moderationaudit
			values
				(current_timestamp(3), _postid, _approvedby, 5, null);
		end if;
		-- send back a success code
		return 1; 
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 337 (OID 27823)
-- Name: forums_approvemoderatedpost (integer, character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_approvemoderatedpost (integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_approvemoderatedpost (integer, character varying, character varying) TO PUBLIC;


--
-- TOC entry 146 (OID 27824)
-- Name: forums_approvepost (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_approvepost (integer) RETURNS integer
    AS '
declare 
	_postid alias for $1;
	_forumid int;
	_threadid int;
begin
	-- first make sure that the post is already non-approved
	if (select approved from posts where postid = _postid limit 1) = true then
		-- its already been approved, return 0
		return 0;
	else
		-- approve the post
		update 
			posts
		set 
			approved = true
		where 
			postid = _postid;

		-- get details about the thread and forum this post belongs in
		select into 	_forumid, _threadid
				forumid, threadid
		from
			posts
		where
			postid = _postid;

		-- update the thread date
		update 
			posts
		set 
			threaddate = current_timestamp(3)
		where 
			threadid = _threadid;

		-- update the moderationaudit table
		insert into
			moderationaudit
		values
			(current_timestamp(3), _postid, ''undone'', 1, null);
		-- update the forums statistics
		perform statistics_resetforumstatistics (_forumid);
		-- send back a success code
		return 1; 
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 147 (OID 27824)
-- Name: forums_approvepost (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_approvepost (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_approvepost (integer) TO PUBLIC;


--
-- TOC entry 8 (OID 27826)
-- Name: canmoderate; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE canmoderate AS (canmoderate integer);


--
-- TOC entry 326 (OID 27827)
-- Name: forums_canmoderate (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_canmoderate (character varying) RETURNS SETOF canmoderate
    AS '
declare
	_username alias for $1;
	_rec canmoderate%ROWTYPE;
	t_found int;
begin
	select into t_found 1 from moderators where username ilike _username;
	-- determine whether or not this user can moderate
	if found then 
		for _rec in 
		select 1 as canmoderate
		loop
			return next _rec;
		end loop;
	else
		for _rec in 
		select 0 as canmoderate
		loop
			return next _rec;
		end loop;
	end if;
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 327 (OID 27827)
-- Name: forums_canmoderate (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_canmoderate (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_canmoderate (character varying) TO PUBLIC;

--
-- TOC entry 354 (OID 27828)
-- Name: forums_canmoderateforum (character varying, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_canmoderateforum (character varying, integer) RETURNS SETOF canmoderate
    AS '
declare
	_username alias for $1;
	_forumid alias for $2;
	_rec canmoderate%ROWTYPE;
	t_found int;
begin
  select into t_found 1 from moderators where username ilike _username and forumid = 0;
  if found then
    _rec.canmoderate := 1; 
  else
    select into t_found 1 from moderators where username ilike _username and forumid = _forumid;
    if found then
      _rec.canmoderate := 1; 
    else
      _rec.canmoderate := 0; 
    end if;
  end if;
  return next _rec;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 355 (OID 27828)
-- Name: forums_canmoderateforum (character varying, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_canmoderateforum (character varying, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_canmoderateforum (character varying, integer) TO PUBLIC;


--
-- TOC entry 148 (OID 27829)
-- Name: forums_changeuserpassword (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_changeuserpassword (character varying, character varying) RETURNS integer
    AS '
update
	users
set
	password = $2
where
	username ilike $1; 
SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 149 (OID 27829)
-- Name: forums_changeuserpassword (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_changeuserpassword (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_changeuserpassword (character varying, character varying) TO PUBLIC;


--
-- TOC entry 150 (OID 27830)
-- Name: forums_checkusercredentials (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_checkusercredentials (character varying, character varying) RETURNS integer
    AS '
declare
	_username alias for $1;
	_password alias for $2;
	t_found int;
begin
	select into t_found 1 from users where username ilike _username and password = _password and approved=true;
	if found then
		-- update the time the user last logged in
		update users
			set lastlogin = current_timestamp(3)
		where username ilike _username;
		return 1;
	else
		return 0; 
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 151 (OID 27830)
-- Name: forums_checkusercredentials (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_checkusercredentials (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_checkusercredentials (character varying, character varying) TO PUBLIC;


--
-- TOC entry 352 (OID 27831)
-- Name: forums_createnewrole (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_createnewrole (character varying, character varying) RETURNS integer
    AS '
declare
	_rolename alias for $1;
	_description alias for $2;
	t_found int;
begin
    select into t_found 1 from userroles where rolename ilike _rolename;
    if not found then
            insert into userroles (rolename, description)
            values(_rolename, _description); 
    end if;
    return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 353 (OID 27831)
-- Name: forums_createnewrole (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_createnewrole (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_createnewrole (character varying, character varying) TO PUBLIC;


--
-- TOC entry 152 (OID 27832)
-- Name: forums_deleteforum (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_deleteforum (integer) RETURNS integer
    AS '
	-- delete the specified forum and all of its posts
	-- first we must remove all the thread tracking rows
	delete from threadtrackings
	where threadid in (select distinct threadid from posts where forumid = $1);
	-- we must remove all of the moderators for this forum
	delete from moderators
	where forumid = $1;
	-- now we must remove all of the posts
	delete from posts
	where forumid = $1;
	-- finally we can delete the actual forum
	delete from forums
	where forumid = $1; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 153 (OID 27832)
-- Name: forums_deleteforum (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_deleteforum (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_deleteforum (integer) TO PUBLIC;


--
-- TOC entry 356 (OID 27833)
-- Name: forums_deleterole (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_deleterole (character varying) RETURNS integer
    AS '
declare
	_rolename alias for $1;
	t_found int;
begin
    select into t_found 1 from userroles where rolename ilike _rolename;
    if found then
	delete from privateforums where rolename ilike _rolename;
	delete from usersinroles where rolename ilike _rolename;
	delete from userroles where rolename ilike _rolename; 
    end if;
    return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 357 (OID 27833)
-- Name: forums_deleterole (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_deleterole (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_deleterole (character varying) TO PUBLIC;


--
-- TOC entry 154 (OID 27834)
-- Name: forums_getallbutoneforum (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallbutoneforum (integer) RETURNS SETOF forums
    AS '
	-- get all of the forums except for the forum that postid exists in
	select
		*
	from forums 
	where not (forumid = (select forumid from posts where postid = $1)) and active = true; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 155 (OID 27834)
-- Name: forums_getallbutoneforum (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallbutoneforum (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallbutoneforum (integer) TO PUBLIC;


--
-- TOC entry 156 (OID 27835)
-- Name: forums_getallforumgroups (boolean, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallforumgroups (boolean, character varying) RETURNS SETOF forumgroups
    AS '
declare 
	_getallforumsgroups alias for $1;
	_username alias for $2;
	_rec forumgroups%ROWTYPE;
	t_found int;
begin
	if _getallforumsgroups = false then
        	if _username is not null then
			SELECT 1 INTO t_found
			from
				forums
                        join forumgroups on forumgroups.forumgroupid = forums.forumgroupid
			where
				forums.active = true and
				(forumid not in (select forumid from privateforums) or
				forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)));

			for _rec in 
				select 
					forumgroupid,
					name,
					sortorder
				from
					forumgroups
				where
					t_found = 1 loop
				return next _rec;
				end loop;
			return;
				
		else
			SELECT 1 INTO t_found
			from
				forums
                        join forumgroups on forumgroups.forumgroupid = forums.forumgroupid
			where
				forums.active = true and
				forumid not in (select forumid from privateforums);

			for _rec in 
				select 
					forumgroupid,
					name,
					sortorder
				from
					forumgroups
				where
					t_found = 1 loop
				return next _rec;
				end loop;
			return;
		end if;
	else
		for _rec in 
			select 
				*
			from
				forumgroups loop
			return next _rec;
			end loop;
		return;
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 157 (OID 27835)
-- Name: forums_getallforumgroups (boolean, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallforumgroups (boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallforumgroups (boolean, character varying) TO PUBLIC;

--
-- TOC entry 9 (OID 27837)
-- Name: allforums; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE allforums AS (forumid integer,
	forumgroupid integer,
	parentid integer,
	name character varying(100),
	description character varying(3000),
	datecreated timestamp without time zone,
	daystoview integer,
	moderated boolean,
	totalposts integer,
	totaltopics integer,
	mostrecentpostid integer,
	mostrecentthreadid integer,
	mostrecentpostdate timestamp without time zone,
	mostrecentpostauthor character varying(50),
	active boolean,
	lastuseractivity timestamp without time zone,
	sortorder integer,
	isprivate boolean,
	displaymask bytea);




--
-- TOC entry 158 (OID 27838)
-- Name: forums_getallforums (boolean, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallforums (boolean, character varying) RETURNS SETOF allforums
    AS '
declare 
	_getallforums alias for $1;
	_username alias for $2;
	_rec allforums%ROWTYPE;
	t_found int;
begin
	-- return all of the columns in all of the forums
	if _getallforums = false then
                -- is a user specified?
                if _username is not null then
			-- get just the active forums
			for _rec in 
			select
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				true as active,
				(select lastactivity from forumsread where username ilike _username and forumid = f.forumid limit 1) as lastuseractivity,
				sortorder,
				coalesce((select true from privateforums where forumid = f.forumid limit 1), false) as isprivate,
				displaymask
			from
				forums f
			where
				active = true and
				forumid not in (select forumid from privateforums) or
				forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))
			order by
				name 
                            loop
				return next _rec;
			    end loop;
			return;
                else
			-- get just the active forums
			for _rec in 
			select 
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				true as active,
				null as lastuseractivity,
				sortorder,
				false as isprivate,
				displaymask
			from
				forums f
			where
				active = true and
				forumid not in (select forumid from privateforums)
			order by
				name 
                            loop
				return next _rec;
			    end loop;
			return;
		   end if;
		else
                -- is a user specified?
                if _username is not null then
			-- get all of the forums
			for _rec in 
			select
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				active,
				(select lastactivity from forumsread where username ilike _username and forumid = f.forumid limit 1) as lastuseractivity,
				sortorder,
				coalesce((select true from privateforums where forumid = f.forumid limit 1), false) as isprivate,
				displaymask
			from
				forums f
			where
				(forumid not in (select forumid from privateforums) or
				forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
			order by
				name 
                            loop
				return next _rec;
			    end loop;
			return;
                else
			-- get just the active forums
			for _rec in 	
			select 
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				true as active,
				null as lastuseractivity,
				sortorder,
				false as isprivate,
				displaymask
			from
				forums f
			where
				forumid not in (select forumid from privateforums)
			order by
				name 
                            loop
				return next _rec;
			    end loop;
			return;
		end if;
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 159 (OID 27838)
-- Name: forums_getallforums (boolean, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallforums (boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallforums (boolean, character varying) TO PUBLIC;


--
-- TOC entry 10 (OID 27840)
-- Name: roles; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE roles AS (rolename character varying(256));


--
-- TOC entry 160 (OID 27841)
-- Name: forums_getallroles (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallroles () RETURNS SETOF roles
    AS '
    select 
        rolename 
    from 
        userroles; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 161 (OID 27841)
-- Name: forums_getallroles (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallroles () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallroles () TO PUBLIC;


--
-- TOC entry 11 (OID 27843)
-- Name: alltopicspaged; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE alltopicspaged AS (subject character varying(256),
	body text,
	postid integer,
	threadid integer,
	parentid integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	pinneddate timestamp without time zone,
	username character varying(50),
	replies integer,
	totalviews integer,
	islocked boolean,
	ispinned boolean,
	hasread boolean,
	mostrecentpostauthor character varying(50),
	mostrecentpostid integer);


--
-- TOC entry 162 (OID 27844)
-- Name: forums_getalltopicspaged (integer, integer, integer, timestamp without time zone, character varying, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getalltopicspaged (integer, integer, integer, timestamp without time zone, character varying, boolean) RETURNS SETOF alltopicspaged
    AS '
declare 
	_forumid alias for $1;
	_pagesize alias for $2;
	_pageindex alias for $3;
	_datefilter alias for $4;
	_username alias for $5;
	_unreadtopicsonly alias for $6;
	_pagelowerbound int;
	_rec alltopicspaged%ROWTYPE;
	t_found int;
begin
-- set the page bounds
_pagelowerbound := _pagesize * _pageindex;
if _username is null then
	for _rec in 
	select 
		subject,
		body,
		postid,
		threadid,
		parentid,
		(select max(postdate) from posts where threadid = p.threadid) as postdate,
		threaddate,
		pinneddate,
		username,
		(select cast(count(*) as int4) from posts where threadid = p.threadid and postlevel != 1 and approved = true) as replies,
		totalviews,
		islocked,
		ispinned,
		false as hasread,
		(select username from posts where threadid = p.threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
		(select postid from posts where threadid = p.threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
	from 
		posts p
	where 
		postlevel = 1 and 
		forumid = _forumid and 
		approved = true and
		threaddate >= _datefilter
	order by 
		(select max(pinneddate) from posts where threadid = threadid) desc
	offset _pagelowerbound
	limit _pagesize
        loop
		return next _rec;
	end loop;
    else
	if _unreadtopicsonly = true then
		-- get unread topics only
  		for _rec in 
		select 
			subject,
			body,
			postid,
			threadid,
			parentid,
   			(select max(postdate) from posts where threadid = p.threadid) as postdate,
			threaddate,
			pinneddate,
			username,
			(select cast(count(*) as int4) from posts where threadid = p.threadid and approved = true and postlevel != 1) as replies,
			totalviews,
			islocked,
			ispinned,
			(select hasreadpost(_username, postid, forumid)) as hasread,
			(select username from posts where threadid = p.threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
			(select postid from posts where threadid = p.threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
		from 
			posts p
		where 
			postlevel = 1 and 
			forumid = _forumid and 
			approved = true and
			threaddate >= _datefilter and
			postid not in (select postsread.postid from postsread where postsread.username ilike _username)
		order by 
			(select max(pinneddate) from posts where threadid = threadid) desc
		offset _pagelowerbound
		limit _pagesize
		loop
			return next _rec;
		end loop;
	else
  		for _rec in 
		select 
			subject,
			body,
			postid,
			threadid,
			parentid,
			(select max(postdate) from posts where threadid = p.threadid) as postdate,
			threaddate,
			pinneddate,
			username,
			(select cast(count(*) as int4) from posts where threadid = p.threadid and approved = true and postlevel != 1) as replies,
			totalviews,
			islocked,
			ispinned,
			(select hasreadpost(_username, postid, forumid)) as hasread,
			(select username from posts where threadid = p.threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
			(select postid from posts where threadid = p.threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
		from 
			posts p
		where 
			postlevel = 1 and 
			forumid = _forumid and 
			approved = true and
			threaddate >= _datefilter
		order by 
			(select max(pinneddate) from posts where threadid = threadid) desc
		offset _pagelowerbound
		limit _pagesize
		loop
			return next _rec;
		end loop;
	end if;
	-- update forum view date
	select into t_found 1 from forumsread where forumid = _forumid and username ilike _username;
	if found then
		-- row exists, update
		update 
			forumsread
		set
			lastactivity = current_timestamp(3)
		where
			forumid = _forumid and
			username ilike _username;
	else
		-- row does not exist, insert
		insert into
			forumsread
			(forumid, username, markreadafter, lastactivity)
		values
			(_forumid, _username, 0, current_timestamp(3)); 
	end if;
    end if;
    return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 163 (OID 27844)
-- Name: forums_getalltopicspaged (integer, integer, integer, timestamp without time zone, character varying, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getalltopicspaged (integer, integer, integer, timestamp without time zone, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getalltopicspaged (integer, integer, integer, timestamp without time zone, character varying, boolean) TO PUBLIC;


--
-- TOC entry 12 (OID 27846)
-- Name: allusers; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE allusers AS (username character varying(50),
	"password" character varying(50),
	email character varying(75),
	forumview integer,
	approved boolean,
	profileapproved boolean,
	"trusted" boolean,
	fakeemail character varying(75),
	url character varying(100),
	signature character varying(256),
	datecreated timestamp without time zone,
	trackyourposts boolean,
	lastlogin timestamp without time zone,
	lastactivity timestamp without time zone,
	timezone integer,
	"location" character varying(100),
	occupation character varying(100),
	interests character varying(100),
	msn character varying(50),
	yahoo character varying(50),
	aim character varying(50),
	icq character varying(50),
	totalposts integer,
	hasavatar boolean,
	showunreadtopicsonly boolean,
	style character varying(20),
	avatartype integer,
	showavatar boolean,
	dateformat character varying(10),
	postvieworder boolean,
	flatview boolean,
	ismoderator boolean,
	avatarurl character varying(256),
	attributes bytea);


--
-- TOC entry 164 (OID 27847)
-- Name: forums_getallusers (integer, integer, integer, boolean, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallusers (integer, integer, integer, boolean, character varying) RETURNS SETOF allusers
    AS '
declare
	_pageindex alias for $1;
	_pagesize alias for $2;
	_sortby alias for $3;
	_sortorder alias for $4;
	_usernamebeginswith alias for $5;
	_pagelowerbound int;
	_rec allusers%ROWTYPE;
begin
	_pagelowerbound := _pagesize * _pageindex;
/* TODO Map sortby to columns
if _sortby = 0 datecreated
    
if _sortby = 1 username
  
if _sortby = 2 url 
   
if _sortby = 3 lastactivity 

if _sortby = 4 totalposts
*/
if _sortorder = false then
    if _usernamebeginswith is null then
	for _rec in
	select
		u.username,
		password,
		email,
		forumview,
		approved,
		profileapproved,
		trusted,
		fakeemail,
		url,
		signature,
		datecreated,
		trackyourposts,
		lastlogin,
		lastactivity,
		timezone,
		location,
		occupation,
		interests,
		msn,
		yahoo,
		aim,
		icq,
		totalposts,
		hasavatar,
		showunreadtopicsonly,
		style,
		avatartype,
		showavatar,
		dateformat,
		postvieworder,
		flatview,
		(select cast(count(*) as int4) from moderators where username ilike u.username) as ismoderator,
		avatarurl,
		attributes
	from 
		users u
	where 
		approved = true and 
		displayinmemberlist = true
	order by _sortby
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
    else
	for _rec in
	select
		u.username,
		password,
		email,
		forumview,
		approved,
		profileapproved,
		trusted,
		fakeemail,
		url,
		signature,
		datecreated,
		trackyourposts,
		lastlogin,
		lastactivity,
		timezone,
		location,
		occupation,
		interests,
		msn,
		yahoo,
		aim,
		icq,
		totalposts,
		hasavatar,
		showunreadtopicsonly,
		style,
		avatartype,
		showavatar,
		dateformat,
		postvieworder,
		flatview,
		(select cast(count(*) as int4) from moderators where username = u.username) as ismoderator,
		avatarurl,
		attributes
	from 
		users u
	where 
		approved = true and 
		displayinmemberlist = true and 
		lower(substring(username from 1 for 1)) = lower(_usernamebeginswith)
	order by _sortby
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
    end if;
else
    if _usernamebeginswith is null then
	for _rec in
	select
		u.username,
		password,
		email,
		forumview,
		approved,
		profileapproved,
		trusted,
		fakeemail,
		url,
		signature,
		datecreated,
		trackyourposts,
		lastlogin,
		lastactivity,
		timezone,
		location,
		occupation,
		interests,
		msn,
		yahoo,
		aim,
		icq,
		totalposts,
		hasavatar,
		showunreadtopicsonly,
		style,
		avatartype,
		showavatar,
		dateformat,
		postvieworder,
		flatview,
		(select cast(count(*) as int4) from moderators where username = u.username) as ismoderator,
		avatarurl,
		attributes
	from 
		users u
	where 
		approved = true and 
		displayinmemberlist = true
	order by _sortby desc
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
    else
	for _rec in
	select
		u.username,
		password,
		email,
		forumview,
		approved,
		profileapproved,
		trusted,
		fakeemail,
		url,
		signature,
		datecreated,
		trackyourposts,
		lastlogin,
		lastactivity,
		timezone,
		location,
		occupation,
		interests,
		msn,
		yahoo,
		aim,
		icq,
		totalposts,
		hasavatar,
		showunreadtopicsonly,
		style,
		avatartype,
		showavatar,
		dateformat,
		postvieworder,
		flatview,
		(select cast(count(*) as int4) from moderators where username = u.username) as ismoderator,
		avatarurl,
		attributes
	from 
		users u
	where 
		approved = true and 
		displayinmemberlist = true and 
		lower(substring(username from 1 for 1)) = lower(_usernamebeginswith)
	order by _sortby desc
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
    end if;
end if;
return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 165 (OID 27847)
-- Name: forums_getallusers (integer, integer, integer, boolean, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallusers (integer, integer, integer, boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallusers (integer, integer, integer, boolean, character varying) TO PUBLIC;


--
-- TOC entry 13 (OID 27849)
-- Name: anonymoususersonline; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE anonymoususersonline AS (anonymoususercount integer);


--
-- TOC entry 166 (OID 27850)
-- Name: forums_getanonymoususersonline (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getanonymoususersonline () RETURNS SETOF anonymoususersonline
    AS '
	select cast(count(*) as int4) from anonymoususers as anonymoususercount; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 167 (OID 27850)
-- Name: forums_getanonymoususersonline (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getanonymoususersonline () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getanonymoususersonline () TO PUBLIC;


--
-- TOC entry 14 (OID 27852)
-- Name: bannedusers; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE bannedusers AS (username character varying(50),
	email character varying(75),
	datecreated timestamp without time zone);


--
-- TOC entry 168 (OID 27853)
-- Name: forums_getbannedusers (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getbannedusers () RETURNS SETOF bannedusers
    AS '
	-- return all of the banned users
	select
		username,
		email,
		datecreated
	from users
	where approved = false
	order by username; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 169 (OID 27853)
-- Name: forums_getbannedusers (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getbannedusers () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getbannedusers () TO PUBLIC;


--
-- TOC entry 170 (OID 27854)
-- Name: forums_getemailinfo (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getemailinfo (integer) RETURNS SETOF emails
    AS '
	-- return information about a row in the email table
	select
		emailid,
		subject,
		importance,
		fromaddress,
		description,
		message
	from emails
	where emailid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 171 (OID 27854)
-- Name: forums_getemailinfo (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getemailinfo (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getemailinfo (integer) TO PUBLIC;


--
-- TOC entry 172 (OID 27855)
-- Name: forums_getemaillist (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getemaillist () RETURNS SETOF emails
    AS '
	-- get all of the emails
	select
		emailid,
		subject,
		importance,
		fromaddress,
		description,
		message
	from emails
	order by description; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 173 (OID 27855)
-- Name: forums_getemaillist (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getemaillist () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getemaillist () TO PUBLIC;


--
-- TOC entry 15 (OID 27857)
-- Name: forumbypostid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumbypostid AS (forumid integer,
	forumgroupid integer,
	parentid integer,
	name character varying(100),
	description character varying(3000),
	datecreated timestamp without time zone,
	moderated boolean,
	daystoview integer,
	active boolean,
	sortorder integer,
	isprivate boolean,
	displaymask bytea);


--
-- TOC entry 174 (OID 27858)
-- Name: forums_getforumbypostid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumbypostid (integer) RETURNS SETOF forumbypostid
    AS '
	-- get the forum id for a particular post
	select
		forumid,
		forumgroupid,
		parentid,
		name,
		description,
		datecreated,
		moderated,
		daystoview,
		active,
		sortorder,
		coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate,
		displaymask
	from forums f
	where forumid = (select forumid from posts where postid = $1); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 175 (OID 27858)
-- Name: forums_getforumbypostid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumbypostid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumbypostid (integer) TO PUBLIC;


--
-- TOC entry 16 (OID 27860)
-- Name: forumbythreadid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumbythreadid AS (forumid integer,
	forumgroupid integer,
	name character varying(100),
	description character varying(3000),
	datecreated timestamp without time zone,
	moderated boolean,
	daystoview integer,
	active boolean,
	sortorder integer,
	isprivate boolean);


--
-- TOC entry 176 (OID 27861)
-- Name: forums_getforumbythreadid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumbythreadid (integer) RETURNS SETOF forumbythreadid
    AS '
	-- get the forum id for a particular post
	select
		forumid,
		forumgroupid,
		name,
		description,
		datecreated,
		moderated,
		daystoview,
		active,
		sortorder,
		coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate
	from forums f 
	where forumid = (select distinct forumid from posts where threadid = $1); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 177 (OID 27861)
-- Name: forums_getforumbythreadid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumbythreadid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumbythreadid (integer) TO PUBLIC;


--
-- TOC entry 178 (OID 27862)
-- Name: forums_getforumgroupbyforumid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumgroupbyforumid (integer) RETURNS SETOF forumgroups
    AS '
	select 
		forumgroups.forumgroupid,
		forumgroups.name,
		forumgroups.sortorder
	from
		forumgroups, forums
	where
		forums.forumgroupid = forumgroups.forumgroupid and
		forums.forumid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 179 (OID 27862)
-- Name: forums_getforumgroupbyforumid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumgroupbyforumid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumgroupbyforumid (integer) TO PUBLIC;


--
-- TOC entry 17 (OID 27864)
-- Name: forumgroupnamebyid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumgroupnamebyid AS (name character varying(256),
	sortorder integer);


--
-- TOC entry 180 (OID 27865)
-- Name: forums_getforumgroupnamebyid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumgroupnamebyid (integer) RETURNS SETOF forumgroupnamebyid
    AS '
	select 
		forumgroups.name,
		forumgroups.sortorder
	from
		forumgroups, forums
	where
		forums.forumgroupid = forumgroups.forumgroupid and
		forums.forumid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 181 (OID 27865)
-- Name: forums_getforumgroupnamebyid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumgroupnamebyid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumgroupnamebyid (integer) TO PUBLIC;


--
-- TOC entry 182 (OID 27869)
-- Name: forums_getforummessagetemplatelist (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforummessagetemplatelist () RETURNS SETOF messages
    AS '
select 
	messageid,
	title,
	body
from
	messages; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 183 (OID 27869)
-- Name: forums_getforummessagetemplatelist (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforummessagetemplatelist () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforummessagetemplatelist () TO PUBLIC;


--
-- TOC entry 18 (OID 27871)
-- Name: forummoderators; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forummoderators AS (username character varying(50),
	emailnotification boolean,
	datecreated timestamp without time zone);


--
-- TOC entry 184 (OID 27872)
-- Name: forums_getforummoderators (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforummoderators (integer) RETURNS SETOF forummoderators
    AS '
	-- get a list of forum moderators
	select 
		username, 
		emailnotification, 
		datecreated
	from 
		moderators
	where 
		forumid = $1 or forumid = 0; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 185 (OID 27872)
-- Name: forums_getforummoderators (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforummoderators (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforummoderators (integer) TO PUBLIC;


--
-- TOC entry 19 (OID 27874)
-- Name: forumviewbyusername; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumviewbyusername AS (forumview integer);


--
-- TOC entry 186 (OID 27875)
-- Name: forums_getforumviewbyusername (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumviewbyusername (character varying) RETURNS SETOF forumviewbyusername
    AS '
	-- get the forumview for the user
	select
		forumview
	from users
	where username ilike $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 187 (OID 27875)
-- Name: forums_getforumviewbyusername (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumviewbyusername (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumviewbyusername (character varying) TO PUBLIC;


--
-- TOC entry 20 (OID 27877)
-- Name: forumsbyforumgroupid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumsbyforumgroupid AS (forumid integer,
	forumgroupid integer,
	parentid integer,
	name character varying(100),
	description character varying(3000),
	datecreated timestamp without time zone,
	daystoview integer,
	moderated boolean,
	totalposts integer,
	totaltopics integer,
	mostrecentpostid integer,
	mostrecentthreadid integer,
	mostrecentpostdate timestamp without time zone,
	mostrecentpostauthor character varying(50),
	active boolean,
	lastuseractivity timestamp without time zone,
	sortorder integer,
	isprivate boolean,
	displaymask bytea);


--
-- TOC entry 188 (OID 27878)
-- Name: forums_getforumsbyforumgroupid (integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumsbyforumgroupid (integer, integer, character varying) RETURNS SETOF forumsbyforumgroupid
    AS '
declare
	_forumgroupid alias for $1;
	_getallforums alias for $2;	
	_username alias for $3;
	_rec forumsbyforumgroupid%ROWTYPE;
	t_found int;
begin
	-- do we have a username
	if _username is not null then
		-- return all of the columns in all of the forums
		if _getallforums = 0 then
			-- get just the active forums
			for _rec in
			select
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				true as active,
				(select lastactivity from forumsread where username ilike _username and forumid = f.forumid) as lastuseractivity,
				sortorder,
				coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate,
				displaymask
			from forums f
			where active = true and
				forumgroupid = _forumgroupid
			loop
				return next _rec;
			end loop;
		else
			-- get all of the forums
			for _rec in
			select
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				active,
				(select lastactivity from forumsread where username ilike _username and forumid = f.forumid) as lastuseractivity,
				sortorder,
				coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate,
				displaymask
			from forums f
			where 
				forumgroupid = _forumgroupid
			loop
				return next _rec;
			end loop;	
		end if;
	else
		-- return all of the columns in all of the forums
		if _getallforums = 0 then
			-- get just the active forums
			for _rec in
			select
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				true as active,
				sortorder,
				coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate,
				displaymask
			from forums f
			where active = true and
				forumgroupid = _forumgroupid
			loop
				return next _rec;
			end loop;	
		else
			-- get all of the forums
			for _rec in
			select
				forumid,
				forumgroupid,
				parentid,
				name,
				description,
				datecreated,
				daystoview,
				moderated,
				totalposts,
				totalthreads as totaltopics,
				mostrecentpostid,
				mostrecentthreadid,
				mostrecentpostdate,
				mostrecentpostauthor,
				active,
				sortorder,
				coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate,
				displaymask
			from forums f
			where 
				forumgroupid = _forumgroupid
			loop
				return next _rec;
			end loop;	
		end if; 
	end if;
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 189 (OID 27878)
-- Name: forums_getforumsbyforumgroupid (integer, integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumsbyforumgroupid (integer, integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumsbyforumgroupid (integer, integer, character varying) TO PUBLIC;


--
-- TOC entry 21 (OID 27880)
-- Name: message; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE message AS (title character varying(250),
	body character varying(3000));


--
-- TOC entry 190 (OID 27881)
-- Name: forums_getmessage (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getmessage (integer) RETURNS SETOF message
    AS '
	select
		title,
		body
	from
		messages
	where
		messageid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 191 (OID 27881)
-- Name: forums_getmessage (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getmessage (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getmessage (integer) TO PUBLIC;


--
-- TOC entry 22 (OID 27883)
-- Name: moderatorsforemailnotification; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE moderatorsforemailnotification AS (username character varying(50),
	email character varying(75));


--
-- TOC entry 192 (OID 27884)
-- Name: forums_getmoderatorsforemailnotification (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getmoderatorsforemailnotification (integer) RETURNS SETOF moderatorsforemailnotification
    AS '
	select
		u.username,
		email
	from users u
		inner join moderators m on
			m.username = u.username
	where (m.forumid = (select forumid from posts where postid = $1) or m.forumid = 0) and m.emailnotification = true; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 193 (OID 27884)
-- Name: forums_getmoderatorsforemailnotification (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getmoderatorsforemailnotification (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getmoderatorsforemailnotification (integer) TO PUBLIC;


--
-- TOC entry 194 (OID 27885)
-- Name: forums_getnextpostid (integer, integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getnextpostid (integer, integer, integer) RETURNS integer
    AS '
select (coalesce((select 	postid
		  from 		posts 
		  where 	threadid = $1 and 
				forumid = $3 and 
				sortorder = $2+1 and 
				approved = true limit 1), 0));'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 195 (OID 27885)
-- Name: forums_getnextpostid (integer, integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getnextpostid (integer, integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getnextpostid (integer, integer, integer) TO PUBLIC;


--
-- TOC entry 196 (OID 27886)
-- Name: forums_getnextthreadid (integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getnextthreadid (integer, integer) RETURNS integer
    AS '
select	(coalesce((select threadid
		from 	posts
		where 	threadid > $1 and 
			forumid = $2 and 
			approved = true limit 1), 0));'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 197 (OID 27886)
-- Name: forums_getnextthreadid (integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getnextthreadid (integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getnextthreadid (integer, integer) TO PUBLIC;


--
-- TOC entry 23 (OID 27888)
-- Name: parentid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE parentid AS (parentid integer);


--
-- TOC entry 198 (OID 27889)
-- Name: forums_getparentid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getparentid (integer) RETURNS SETOF parentid
    AS '
	select parentid
	from posts
	where postid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 199 (OID 27889)
-- Name: forums_getparentid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getparentid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getparentid (integer) TO PUBLIC;


--
-- TOC entry 24 (OID 27891)
-- Name: postinfo; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE postinfo AS (subject character varying(256),
	postid integer,
	username character varying(50),
	forumid integer,
	forumname character varying(100),
	parentid integer,
	threadid integer,
	approved boolean,
	postdate timestamp without time zone,
	postlevel integer,
	sortorder integer,
	threaddate timestamp without time zone,
	replies integer,
	body text,
	totalmessagesinthread integer,
	totalviews integer,
	islocked boolean,
	hasread boolean);


--
-- TOC entry 338 (OID 27892)
-- Name: forums_getpostinfo (integer, boolean, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getpostinfo (integer, boolean, character varying) RETURNS SETOF postinfo
    AS '
declare
	_postid alias for $1;
	_trackviews alias for $2;
	_username alias for $3;
	t_views int;
	t_forumid int;
	t_postdate timestamp;
	_rec postinfo%ROWTYPE;
	t_found int;
begin
	if _trackviews = true then
		-- update the counter for the number of times this post is viewed
		select into t_views totalviews from posts where postid = _postid;
		update posts set totalviews = (t_views + 1) where postid = _postid;
	end if;
	-- if _username is null it is an anonymous user
	if _username is not null then
		
		-- mark the post as read
		-- *********************
		-- only for postlevel = 1
		select into t_found 1 from posts where postid = _postid and postlevel = 1;
		if found then
			select into t_found 1 from postsread where username ilike _username and postid = _postid;
			if not found then
				insert into postsread (username, postid) values (_username, _postid);
			end if;
		end if;
	end if;
	if _username is not null then
		for _rec in
		select
			subject,
			postid,
			username,
			p.forumid,
			(select name from forums f where f.forumid = p.forumid) as forumname,
			parentid,
			threadid,
			approved,
			postdate,
			postlevel,
			sortorder,
			threaddate,
			(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
			body,
			0 as totalmessagesinthread, -- not used
			totalviews,
			islocked,
			true as hasread
		from 
			posts p
		where 
			p.postid = _postid and
			(forumid not in (select forumid from privateforums) or
			forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
		loop
			return next _rec;
		end loop;
	else
		for _rec in
		select
			subject,
			postid,
			username,
			p.forumid,
			(select name from forums f where f.forumid = p.forumid) as forumname,
			parentid,
			threadid,
			approved,
			postdate,
			postlevel,
			sortorder,
			threaddate,
			(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
			body,
			0 as totalmessagesinthread, -- not used
			totalviews,
			islocked,
			true as hasread
		from 
			posts p
		where 
			p.postid = _postid and
			forumid not in (select forumid from privateforums)
		loop
			return next _rec;
		end loop;
	end if;
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 339 (OID 27892)
-- Name: forums_getpostinfo (integer, boolean, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getpostinfo (integer, boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getpostinfo (integer, boolean, character varying) TO PUBLIC;


--
-- TOC entry 200 (OID 27893)
-- Name: forums_getprevpostid (integer, integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getprevpostid (integer, integer, integer) RETURNS integer
    AS '
select  (coalesce((select postid
		   from	  posts
		   where  threadid = $1 and 
			  forumid = $3 and 
			  sortorder = $2-1 and 
			  approved = true limit 1), 0)); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 201 (OID 27893)
-- Name: forums_getprevpostid (integer, integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getprevpostid (integer, integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getprevpostid (integer, integer, integer) TO PUBLIC;


--
-- TOC entry 202 (OID 27894)
-- Name: forums_getprevthreadid (integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getprevthreadid (integer, integer) RETURNS integer
    AS '
select  (coalesce((select 	threadid
		   from 	posts
		   where 	threadid < $1 and 
			        forumid = $2 and 
				approved = true 
		   order by 	threadid desc limit 1), 0)); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 203 (OID 27894)
-- Name: forums_getprevthreadid (integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getprevthreadid (integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getprevthreadid (integer, integer) TO PUBLIC;


--
-- TOC entry 204 (OID 27895)
-- Name: forums_getrolesbyforum (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getrolesbyforum (integer) RETURNS SETOF roles
    AS '
    select 
        rolename
    from 
        privateforums
    where
        forumid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 205 (OID 27895)
-- Name: forums_getrolesbyforum (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getrolesbyforum (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getrolesbyforum (integer) TO PUBLIC;


--
-- TOC entry 206 (OID 27896)
-- Name: forums_getrolesbyuser (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getrolesbyuser (character varying) RETURNS SETOF roles
    AS '
	select 
		rolename 
	from 
		usersinroles
	where
		username ilike $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 207 (OID 27896)
-- Name: forums_getrolesbyuser (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getrolesbyuser (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getrolesbyuser (character varying) TO PUBLIC;


--
-- TOC entry 25 (OID 27898)
-- Name: searchresults; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE searchresults AS (postid integer,
	parentid integer,
	threadid integer,
	postlevel integer,
	sortorder integer,
	username character varying(50),
	subject character varying(256),
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	approved boolean,
	forumid integer,
	forumname character varying(100),
	morerecords integer,
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	hasread boolean);


--
-- TOC entry 208 (OID 27899)
-- Name: forums_getsearchresults (character varying, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getsearchresults (character varying, integer, integer, character varying) RETURNS SETOF searchresults
    AS '
declare
	_searchterms alias for $1;
	_page alias for $2;
	_recsperpage alias for $3;
	_username alias for $4;
	_rec searchresults%ROWTYPE;
	_sql varchar(3000);
	_pagelowerbound int4;
	_morerecords int4;
	
begin
--	execute(''CREATE TEMP TABLE tmp AS select postid from posts p inner join forums f on f.forumid = p.forumid '' ||
--			_searchterms || '' order by threaddate desc'');

	-- ok, all of the rows are inserted into the table.
	-- now, select the correct subset
	_pagelowerbound := (_page - 1) * _recsperpage;
	
--	select cast(count(*) as int4)  from tmp; -- where id >= _lastrec
	
	_sql := ''select p.postid, p.parentid, p.threadid, p.postlevel, p.sortorder, p.username, p.subject, p.postdate, p.threaddate,''
	     ||	''p.approved, p.forumid, f.name as forumname, (select cast(count(*) as int4) from posts '' || _searchterms || '') as morerecords, ''		
	     ||	''(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies, ''
	     ||	''p.body, p.totalviews, p.islocked, false as hasread '' -- not used
	     ||	''from posts p left outer join forums f on f.forumid = p.forumid ''
	     || _searchterms;
	     

	if _username is not null then
		_sql := _sql || ''and (p.forumid not in (select forumid from privateforums) ''
			     ||	''or p.forumid in (select forumid from privateforums where rolename in ''
			     || ''(select rolename from usersinroles where username ilike '''' || _username || ''''))) ''
			     || ''order by threaddate desc offset '' || _pagelowerbound::varchar(50) || '' limit  '' || _recsperpage::varchar(50);
		for _rec in
		execute _sql loop
			return next _rec;
		end loop;
	else
		_sql := _sql || '' and p.forumid not in (select forumid from privateforums) ''
			     || ''order by threaddate desc offset '' || _pagelowerbound::varchar(50) || '' limit '' || _recsperpage::varchar(50);
		for _rec in
		execute _sql loop
			return next _rec;
		end loop;
	end if; 
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 209 (OID 27899)
-- Name: forums_getsearchresults (character varying, integer, integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getsearchresults (character varying, integer, integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getsearchresults (character varying, integer, integer, character varying) TO PUBLIC;


--
-- TOC entry 26 (OID 27901)
-- Name: singlemessage; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE singlemessage AS (subject character varying(256),
	forumid integer,
	forumname character varying(100),
	threadid integer,
	parentid integer,
	postlevel integer,
	sortorder integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	fakeemail character varying(75),
	url character varying(100),
	signature character varying(256),
	approved boolean,
	replies integer,
	prevthreadid integer,
	nextthreadid integer,
	prevpostid integer,
	nextpostid integer,
	useristrackingthread boolean,
	body text,
	islocked boolean);


--
-- TOC entry 268 (OID 27902)
-- Name: forums_getsinglemessage (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getsinglemessage (integer, character varying) RETURNS SETOF singlemessage
    AS '
declare
	_postid alias for $1;
	_username alias for $2;
	_nextthreadid int; 
	_prevthreadid int;
	_nextpostid int; 
	_prevpostid int;
	_threadid int;
	_forumid int;
	_sortorder int;
	_trackingthread bool;
	t_found int4;
	_rec singlemessage%ROWTYPE;
begin
select into 
	_threadid, _forumid, _sortorder
	threadid, forumid, sortorder
from posts 
where postid = _postid;

 _nextthreadid := forums_getnextthreadid (_threadid, _forumid);
 _prevthreadid := forums_getprevthreadid (_threadid, _forumid);
 _nextpostid := forums_getnextpostid (_threadid, _sortorder, _forumid);
 _prevpostid := forums_getprevpostid (_threadid, _sortorder, _forumid);

select into t_found 1 from threadtrackings where threadid = _threadid and username ilike _username;
if found then
	_trackingthread := true;
else
	_trackingthread := false;
end if;

if _username is not null then
	for _rec in
	select
		subject,
		_forumid as forumid,
		(select name from forums where forumid = _forumid) as forumname,
		_threadid as threadid,
		parentid,
		postlevel,
		_sortorder as sortorder,
		postdate,
		threaddate,
		p.username,
		u.fakeemail,
		u.url,
		u.signature,
		p.approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
		_prevthreadid as prevthreadid,
		_nextthreadid as nextthreadid,
		_prevpostid as prevpostid,
		_nextpostid as nextpostid,
		_trackingthread as useristrackingthread,
		body,
		islocked
	from 
		posts p
	inner 
		join users u on
		u.username ilike p.username
	where 
		p.postid = _postid and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in 
		(select rolename from usersinroles where username ilike _username)))
	loop
		return next _rec;
	end loop;
else
	for _rec in
	select
		subject,
		_forumid as forumid,
		(select name from forums where forumid = _forumid) as forumname,
		_threadid as threadid,
		parentid,
		postlevel,
		_sortorder as sortorder,
		postdate,
		threaddate,
		p.username,
		u.fakeemail,
		u.url,
		u.signature,
		p.approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
		_prevthreadid as prevthreadid,
		_nextthreadid as nextthreadid,
		_prevpostid as prevpostid,
		_nextpostid as nextpostid,
		_trackingthread as useristrackingthread,
		body,
		islocked
	from 
		posts p
	inner 
		join users u on
		u.username ilike p.username
	where 
		p.postid = _postid and
		forumid not in (select forumid from privateforums)
	loop
		return next _rec;
	end loop;
end if;
return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 269 (OID 27902)
-- Name: forums_getsinglemessage (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getsinglemessage (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getsinglemessage (integer, character varying) TO PUBLIC;


--
-- TOC entry 27 (OID 27904)
-- Name: statistics; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE "statistics" AS (totalusers integer,
	totalposts integer,
	totalmoderators integer,
	totalmoderatedposts integer,
	totaltopics integer,
	daysposts integer,
	daystopics integer,
	newpostsinpast24hours integer,
	newthreadsinpast24hours integer,
	newusersinpast24hours integer,
	mostviewspostid integer,
	mostviewssubject character varying(256),
	mostactivepostid integer,
	mostactivesubject character varying(256),
	mostactiveuser character varying(50),
	mostreadpostid integer,
	mostreadsubject character varying(256),
	newestuser character varying(50));


--
-- TOC entry 316 (OID 27905)
-- Name: forums_getstatistics (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getstatistics () RETURNS "statistics"
    AS '
declare
	-- get summary information - total users, total posts, totaltopics, daysposts, and daystopics
	_rec statistics%ROWTYPE;
begin
	-- reset top posters
	perform statistics_resettopposters();

	-- total moderators
	-- ***********************************************
	select into 
		_rec.totalmoderators
		cast(count(*) as int4)  
	from 
		usersinroles 
	where 
		rolename = ''forum-moderators'';

	-- total moderated posts
	-- ***********************************************
	select into 
		_rec.totalmoderatedposts
		cast(count(*) as int4)  
	from 
		moderationaudit;
	-- most views
	-- ***********************************************
	select into 
		_rec.mostviewspostid, _rec.mostviewssubject
		postid, subject
	from 
		posts 
	where 
		threaddate > dateadd(''dd'', -2, current_timestamp(3)) and
		forumid not in (select forumid from privateforums) and
		approved = true
	order by 
		totalviews desc
	limit 1; 
	-- most active post
	-- ***********************************************
	select into 
		_rec.mostactivepostid, _rec.mostactivesubject
		postid, subject
	from 
		posts p 
	where 
		p.postlevel = 1 and 
		threaddate > dateadd(''dd'', -2, current_timestamp(3)) and
		forumid not in (select forumid from privateforums) and
		approved = true
	order by 
		(select cast(count(*) as int4) from posts p2 where p2.threadid = p.threadid) desc
	limit 1; 
	-- most active user
	-- ***********************************************
	select into 
		_rec.mostactiveuser 
		username
	from 
		users 
	order by 
		totalposts desc
	limit 1; 
	-- newest user
	-- ***********************************************
	select into 
		_rec.newestuser 
		username
	from 
		users 
	where
		displayinmemberlist = true
	order by 
		datecreated desc
	limit 1; 
	-- most read posts
	-- ***********************************************
	select into 
		_rec.mostreadpostid, _rec.mostreadsubject
		postid, subject
	from 
		posts p
	where
		forumid not in (select forumid from privateforums) and
		approved = true
	order by 
		(select cast(count(hasread) as int4) from postsread where p.postid = postsread.postid) desc
	limit 1; 
	-- other stats
	select into 
		_rec.totalusers, 
		_rec.totalposts, 
		_rec.totaltopics, 
		_rec.newpostsinpast24hours, 
		_rec.newusersinpast24hours,
		_rec.newthreadsinpast24hours
		
		-- total users
		-- ***********************************************
		(select cast(count(*) as int4) from users),
		-- total posts
		-- ***********************************************
		(select cast(count(*) as int4) from posts) + (select cast(count(*) as int4) from post_archive),
		-- total topics
		-- ***********************************************
		(select cast(count(*) as int4) from posts where parentid = postid) + (select cast(count(*) as int4) from post_archive where parentid = postid),
		-- total posts in past 24 hours
		-- ***********************************************
		(select cast(count(*) as int4) from posts
				where postdate > dateadd(''dd'',(0-1),current_timestamp(3))),
		-- total users in past 24 hours
		-- ***********************************************
		(select cast(count(*) as int4) from users
				where datecreated > dateadd(''dd'',-1,current_timestamp(3))),
		-- total topics in past 24 hours
		-- ***********************************************
		(select cast(count(*) as int4) from posts
				where parentid = postid and postdate > dateadd(''dd'',-1,current_timestamp(3)));
	
	-- test for null values
	if _rec.mostviewspostid is null then
		_rec.mostviewspostid := 0;
	end if;
	if _rec.mostviewssubject is null then
		_rec.mostviewssubject := ''no posts available'';
	end if;
	if _rec.mostactivepostid is null then
		_rec.mostactivepostid := 0;
	end if;
	if _rec.mostactivesubject is null then
		_rec.mostactivesubject := ''no posts available'';
	end if;
	if _rec.mostactiveuser is null then
		_rec.mostactiveuser := ''no posts available'';
	end if;
	if _rec.mostreadpostid is null then
		_rec.mostreadpostid := 0;
	end if;
	if _rec.mostreadsubject is null then
		_rec.mostreadsubject := ''no posts available'';
	end if;
   return _rec;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 317 (OID 27905)
-- Name: forums_getstatistics (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getstatistics () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getstatistics () TO PUBLIC;


--
-- TOC entry 28 (OID 27907)
-- Name: thread; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE thread AS (postid integer,
	forumid integer,
	subject character varying(256),
	parentid integer,
	threadid integer,
	postlevel integer,
	sortorder integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	approved boolean,
	replies integer,
	body text);


--
-- TOC entry 210 (OID 27908)
-- Name: forums_getthread (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getthread (integer) RETURNS SETOF thread
    AS '
select
	postid,
	forumid,
	subject,
	parentid,
	threadid,
	postlevel,
	sortorder,
	postdate,
	threaddate,
	username,
	approved,
	(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
	body
from posts p
where approved = true and threadid = $1
order by sortorder; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 211 (OID 27908)
-- Name: forums_getthread (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getthread (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getthread (integer) TO PUBLIC;


--
-- TOC entry 29 (OID 27910)
-- Name: threadbyparentid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE threadbyparentid AS (postid integer,
	threadid integer,
	forumid integer,
	subject character varying(256),
	parentid integer,
	postlevel integer,
	sortorder integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	approved boolean,
	replies integer,
	body text,
	totalmessagesinthread integer,
	totalviews integer,
	islocked boolean);


--
-- TOC entry 212 (OID 27911)
-- Name: forums_getthreadbyparentid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getthreadbyparentid (integer) RETURNS SETOF threadbyparentid
    AS '
	select 
		postid,
		threadid,
		forumid,
		subject,
		parentid,
		postlevel,
		sortorder,
		postdate,
		threaddate,
		username,
		approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
		body,
		0 as totalmessagesinthread, -- not used
		totalviews,
		islocked
	from
		posts p
	where
		approved = true and
		parentid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 213 (OID 27911)
-- Name: forums_getthreadbyparentid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getthreadbyparentid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getthreadbyparentid (integer) TO PUBLIC;


--
-- TOC entry 30 (OID 27913)
-- Name: threadbypostid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE threadbypostid AS (postid integer,
	threadid integer,
	forumid integer,
	forumname character varying(100),
	subject character varying(256),
	parentid integer,
	postlevel integer,
	sortorder integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	approved boolean,
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	hasread boolean);


--
-- TOC entry 214 (OID 27914)
-- Name: forums_getthreadbypostid (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getthreadbypostid (integer, character varying) RETURNS SETOF threadbypostid
    AS '
declare 
	_postid alias for $1;
	_username alias for $2;
	_threadid int;
	_rec threadbypostid%ROWTYPE;
begin
	-- get the thread id of the post
	select into _threadid threadid from posts where postid = _postid;

	-- get the thread info for this post
	if _username is not null then
		for _rec in
		select
			postid,
			threadid,
			forumid,
			(select name from forums f where f.forumid = p.forumid) as forumname,
			subject,
			parentid,
			postlevel,
			sortorder,
			postdate,
			threaddate,
			username,
			approved,
			(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
			body,
			totalviews,
			islocked,
			false as hasread -- not used
		from 
			posts p
		where 
			approved = true and 
			threadid = _threadid and
			sortorder >= (select sortorder from posts where postid = _threadid) and
			(forumid not in (select forumid from privateforums) or
			forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
		order by 
			sortorder
		loop
			return next _rec;
		end loop;
	else
		for _rec in
		select
			postid,
			threadid,
			forumid,
			(select name from forums f where f.forumid = p.forumid) as forumname,
			subject,
			parentid,
			postlevel,
			sortorder,
			postdate,
			threaddate,
			username,
			approved,
			(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
			body,
			totalviews,
			islocked,
			false as hasread -- not used
		from 
			posts p
		where 
			approved = true and 
			threadid = _threadid and
			sortorder >= (select sortorder from posts where postid = _threadid) and
			forumid not in (select forumid from privateforums)
		order by 
			sortorder
		loop
			return next _rec;
		end loop;
	end if;
	return; 
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 215 (OID 27914)
-- Name: forums_getthreadbypostid (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getthreadbypostid (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getthreadbypostid (integer, character varying) TO PUBLIC;


--
-- TOC entry 31 (OID 27916)
-- Name: threadbypostidpaged; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE threadbypostidpaged AS (postid integer,
	threadid integer,
	forumid integer,
	forumname character varying(100),
	subject character varying(256),
	parentid integer,
	postlevel integer,
	sortorder integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	approved boolean,
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	totalmessagesinthread integer,
	hasread boolean,
	posttype integer);


--
-- TOC entry 216 (OID 27917)
-- Name: forums_getthreadbypostidpaged (integer, integer, integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getthreadbypostidpaged (integer, integer, integer, integer, integer, character varying) RETURNS SETOF threadbypostidpaged
    AS '
declare
	_postid alias for $1;
	_pageindex alias for $2;
	_pagesize alias for $3;
	_sortby alias for $4;
	_sortorder alias for $5;
	_username alias for $6;
	_pagelowerbound int;

	_threadid int;
	_forumid int;
	_privateforumid int;
	_isprivateforum bool;
	_isuserapprovedforprivateforum bool;
	_rec threadbypostidpaged%ROWTYPE;
	t_found int;
begin
  -- get the forumid, the privateforumid, and the threadid
	select into 	
		_forumid, _threadid 
	
		forumid, threadid 
	from 	
		posts 
	where 
		postid = _postid;

	select into 	
		_privateforumid  
	
		forumid 
	from 
		privateforums 
	where 
		forumid = _forumid;

	-- is this a private forum?
	if _privateforumid is not null then
		-- this is a private forum
		_isprivateforum := true;
		-- does the user have access to this forum?
		if (_username is not null) then
			select forumid into t_found from privateforums 
				  where rolename in (select rolename from usersinroles where username ilike _username);
			if found then
			  _isuserapprovedforprivateforum := true;
			else
			  _isuserapprovedforprivateforum := false;
		        end if;
		else
			_isuserapprovedforprivateforum := false;
		end if;
	else
		_isprivateforum := false;
		-- let''s return here if the user is not allowed
		if _isprivateforum = true and _isuserapprovedforprivateforum = false then
			return;
		end if;
		-- set the page bounds
		_pagelowerbound := _pagesize * _pageindex;
	end if;

-- sort by post date
if _sortby = 0 and _sortorder = 0 then
	for _rec in 
	select
		postid,
		threadid,
		forumid,
		(select name from forums f where f.forumid = forumid limit 1) as forumname,
		subject,
		parentid,
		postlevel,
		sortorder,
		postdate,
		threaddate,
		username,
		approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = postid and p2.postlevel != 1) as replies,
		body,
		totalviews,
		islocked,
		0 as totalmessagesinthread, -- not used
		false as hasread, -- not used
		posttype
	from 
		posts
	where 
		approved = true and threadid = _threadid
	order by 
		postdate
	offset _pagelowerbound
	limit _pagesize
        loop
		return next _rec;
	end loop;
	return;
else
   if _sortby = 0 and _sortorder = 1 then
	for _rec in 
	select
		postid,
		threadid,
		forumid,
		(select name from forums f where f.forumid = forumid limit 1) as forumname,
		subject,
		parentid,
		postlevel,
		sortorder,
		postdate,
		threaddate,
		username,
		approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = postid and p2.postlevel != 1) as replies,
		body,
		totalviews,
		islocked,
		0 as totalmessagesinthread, -- not used
		false as hasread, -- not used
		posttype
	from 
		posts
	where 
		approved = true and threadid = _threadid
	order by 
		postdate desc
	offset _pagelowerbound
	limit _pagesize	
	loop
		return next _rec;
	end loop;
	return;
  end if;
end if;
-- sort by author
if _sortby = 1 and _sortorder = 0 then
	for _rec in 
	select
		postid,
		threadid,
		forumid,
		(select name from forums f where f.forumid = forumid limit 1) as forumname,
		subject,
		parentid,
		postlevel,
		sortorder,
		postdate,
		threaddate,
		username,
		approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = postid and p2.postlevel != 1) as replies,
		body,
		totalviews,
		islocked,
		0 as totalmessagesinthread, -- not used
		false as hasread, -- not used
		posttype
	from 
		posts
	where 
		approved = true and threadid = _threadid
	order by 
		username
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
	return;
else
  if _sortby = 1 and _sortorder = 1 then
	for _rec in 
	select
		postid,
		threadid,
		forumid,
		(select name from forums f where f.forumid = forumid limit 1) as forumname,
		subject,
		parentid,
		postlevel,
		sortorder,
		postdate,
		threaddate,
		username,
		approved,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = postid and p2.postlevel != 1) as replies,
		body,
		totalviews,
		islocked,
		0 as totalmessagesinthread, -- not used
		false as hasread, -- not used
		posttype
	from 
		posts
	where 
		approved = true and threadid = _threadid
	order by 
		username desc
	offset _pagelowerbound
	limit _pagesize
        loop
		return next _rec;
	end loop;
	return;
    end if;
end if;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 217 (OID 27917)
-- Name: forums_getthreadbypostidpaged (integer, integer, integer, integer, integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getthreadbypostidpaged (integer, integer, integer, integer, integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getthreadbypostidpaged (integer, integer, integer, integer, integer, character varying) TO PUBLIC;


--
-- TOC entry 32 (OID 27919)
-- Name: topicsuseristracking; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE topicsuseristracking AS (subject character varying(256),
	body text,
	postid integer,
	threadid integer,
	parentid integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	pinneddate timestamp without time zone,
	username character varying(50),
	replies integer,
	totalviews integer,
	islocked boolean,
	ispinned boolean,
	hasread boolean,
	mostrecentpostauthor character varying(50),
	mostrecentpostid integer);


--
-- TOC entry 218 (OID 27920)
-- Name: forums_gettopicsuseristracking (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettopicsuseristracking (character varying) RETURNS SETOF topicsuseristracking
    AS '
select 
	subject,
	body,
	p.postid,
	p.threadid,
	parentid,
	(select max(postdate) from posts where threadid = p.threadid) as postdate,
	threaddate,
	pinneddate,
	p.username,
	(select cast(count(*) as int4) from posts where p.threadid = threadid and approved = true and postlevel != 1) as replies,
	totalviews,
	islocked,
	ispinned,
	(select hasreadpost($1, p.postid, p.forumid)) as hasread,
	(select username from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
	(select postid from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
from
	posts p,
	threadtrackings t
where
	postlevel = 1 and
	approved = true and
	p.threadid = t.threadid and
        t.username ilike $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 219 (OID 27920)
-- Name: forums_gettopicsuseristracking (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettopicsuseristracking (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettopicsuseristracking (character varying) TO PUBLIC;


--
-- TOC entry 33 (OID 27922)
-- Name: topicsusermostrecentlyparticipatedin; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE topicsusermostrecentlyparticipatedin AS (subject character varying(256),
	body text,
	postid integer,
	threadid integer,
	parentid integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	pinneddate timestamp without time zone,
	username character varying(50),
	replies integer,
	totalviews integer,
	islocked boolean,
	ispinned boolean,
	hasread boolean,
	mostrecentpostauthor character varying(50),
	mostrecentpostid integer);


--
-- TOC entry 220 (OID 27923)
-- Name: forums_gettopicsusermostrecentlyparticipatedin (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettopicsusermostrecentlyparticipatedin (character varying) RETURNS SETOF topicsusermostrecentlyparticipatedin
    AS '
declare
	_username alias for $1;
	_rec topicsusermostrecentlyparticipatedin%ROWTYPE;
begin

for _rec in
select 
	subject,
	body,
	p.postid,
	p.threadid,
	parentid,
	(select max(postdate) from posts where threadid = p.threadid) as postdate,
	p.threaddate,
	pinneddate,
	p.username,
	(select cast(count(*) as int4) from posts where p.threadid = threadid and approved = true and postlevel != 1) as replies,
	totalviews,
	islocked,
	ispinned,
	(select hasreadpost(_username, p.postid, p.forumid)) as hasread,
	(select username from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
	(select postid from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
from
	posts p
where
        postid in (select threadid from (select distinct
					threadid, 
					threaddate 
				from 
					posts 
				where 
					approved = true and 
					username ilike _username
				order by
					threaddate desc limit 25) t)
	loop
		return next _rec;
	end loop;
return; 
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 221 (OID 27923)
-- Name: forums_gettopicsusermostrecentlyparticipatedin (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettopicsusermostrecentlyparticipatedin (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettopicsusermostrecentlyparticipatedin (character varying) TO PUBLIC;


--
-- TOC entry 222 (OID 27924)
-- Name: forums_gettotalnumberofforums (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettotalnumberofforums () RETURNS integer
    AS '
	select
		cast(count(*) as int4)
	from
		forums; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 223 (OID 27924)
-- Name: forums_gettotalnumberofforums (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettotalnumberofforums () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettotalnumberofforums () TO PUBLIC;


--
-- TOC entry 224 (OID 27925)
-- Name: forums_gettotalpostcount (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettotalpostcount () RETURNS integer
    AS '
	select
	 cast(count(*) as int4)
	from
	  posts; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 225 (OID 27925)
-- Name: forums_gettotalpostcount (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettotalpostcount () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettotalpostcount () TO PUBLIC;


--
-- TOC entry 34 (OID 27927)
-- Name: totalpostsforthread; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE totalpostsforthread AS (totalpostsforthread integer);


--
-- TOC entry 226 (OID 27928)
-- Name: forums_gettotalpostsforthread (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettotalpostsforthread (integer) RETURNS SETOF totalpostsforthread
    AS '
	-- get the count of posts for a given thread
	select 
		cast(count(postid) as int4) as totalpostsforthread
	from 
		posts
	where 
		threadid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 227 (OID 27928)
-- Name: forums_gettotalpostsforthread (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettotalpostsforthread (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettotalpostsforthread (integer) TO PUBLIC;


--
-- TOC entry 228 (OID 27929)
-- Name: forums_gettotalusers (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettotalusers (character varying, character varying) RETURNS integer
    AS '
declare
	_usernamebeginswith alias for $1;
	_usernametofind alias for $2;
	_return int4;
begin
    if _usernamebeginswith is null and _usernametofind is null then
	select into _return
		cast(count(*) as int4)
	from
		users
	where
		displayinmemberlist = true and
		approved = true;
    else
	if _usernametofind is null then
		select into _return
			cast(count(*) as int4)
		from
			users
		where
			displayinmemberlist = true and
			approved = true and 
			lower(substring(username from 1 for 1)) = lower(_usernamebeginswith);
	else
		select into _return
			cast(count(*) as int4)
		from
			users
		where
			displayinmemberlist = true and
			approved = true and 
			username ilike cast(''%'' as character varying) || _usernametofind || cast(''%'' as character varying); 
	end if;
    end if;
    return _return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 229 (OID 27929)
-- Name: forums_gettotalusers (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettotalusers (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettotalusers (character varying, character varying) TO PUBLIC;


--
-- TOC entry 35 (OID 27931)
-- Name: email; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE email AS (email character varying(75));


--
-- TOC entry 230 (OID 27932)
-- Name: forums_gettrackingemailsforthread (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettrackingemailsforthread (integer) RETURNS SETOF email
    AS '
	-- first get the threadid of the post
	-- declare _threadid int
	-- declare _username varchar(50)
	-- select 
	-- = threadid,  --:threadid
	-- = username  --:username
	-- from 
	-- 	posts
	-- where 
	-- 	postid = $1
	-- now, get all of the emails of the users who are tracking this thread
	select
		email
	from 
		users u,
		threadtrackings t
	where
		u.username = t.username and
		t.threadid = (select threadid from posts where postid = $1 limit 1); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 231 (OID 27932)
-- Name: forums_gettrackingemailsforthread (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettrackingemailsforthread (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettrackingemailsforthread (integer) TO PUBLIC;


--
-- TOC entry 36 (OID 27934)
-- Name: userinfo; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE userinfo AS (username character varying(50),
	"password" character varying(50),
	email character varying(75),
	forumview integer,
	approved boolean,
	profileapproved boolean,
	"trusted" boolean,
	fakeemail character varying(75),
	url character varying(100),
	signature character varying(256),
	datecreated timestamp without time zone,
	trackyourposts boolean,
	lastlogin timestamp without time zone,
	lastactivity timestamp without time zone,
	timezone integer,
	"location" character varying(100),
	occupation character varying(100),
	interests character varying(100),
	msn character varying(50),
	yahoo character varying(50),
	aim character varying(50),
	icq character varying(50),
	ismoderator boolean,
	totalposts integer,
	hasavatar boolean,
	showunreadtopicsonly boolean,
	style character varying(20),
	avatartype integer,
	showavatar boolean,
	dateformat character varying(10),
	postvieworder boolean,
	flatview boolean,
	avatarurl character varying(256),
	attributes bytea);


--
-- TOC entry 232 (OID 27935)
-- Name: forums_getuserinfo (character varying, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getuserinfo (character varying, boolean) RETURNS SETOF userinfo
    AS '
declare
	_username alias for $1;
	_updateisonline alias for $2;
	_rec userinfo%ROWTYPE;
begin

	if _updateisonline = true then
 	  -- update activity
	  update 
		users 
	  set 
		lastactivity = current_timestamp(3) 
	  where 
		username ilike $1 and
		true = $2;
	end if;
        -- get the user details
	for _rec in
	select
		username,
		password,
		email,
		forumview,
		approved,
		profileapproved,
		trusted,
		fakeemail,
		url,
		signature,
		datecreated,
		trackyourposts,
		lastlogin,
		lastactivity,
		timezone,
		location,
		occupation,
		interests,
		msn,
		yahoo,
		aim,
		icq,
		(select cast(count(*) as int4) > 0 from moderators where username ilike $1) as ismoderator,
		totalposts,
		hasavatar,
		showunreadtopicsonly,
		style,
		avatartype,
		showavatar,
		dateformat,
		postvieworder,
		flatview,
		avatarurl,
		attributes
	from 
		users 
	where 
		username ilike $1
	loop
		return next _rec;
	end loop;
return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 233 (OID 27935)
-- Name: forums_getuserinfo (character varying, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getuserinfo (character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getuserinfo (character varying, boolean) TO PUBLIC;


--
-- TOC entry 37 (OID 27937)
-- Name: username; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE username AS (username character varying(50));


--
-- TOC entry 234 (OID 27938)
-- Name: forums_getusernamefrompostid (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getusernamefrompostid (integer) RETURNS SETOF username
    AS '
	-- returns who posted a particular post
	select username
	from posts
	where postid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 235 (OID 27938)
-- Name: forums_getusernamefrompostid (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getusernamefrompostid (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getusernamefrompostid (integer) TO PUBLIC;


--
-- TOC entry 236 (OID 27939)
-- Name: forums_getusernamebyemail (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getusernamebyemail (character varying) RETURNS SETOF username
    AS '
select 
	username
from
	users
where
	email = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 237 (OID 27939)
-- Name: forums_getusernamebyemail (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getusernamebyemail (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getusernamebyemail (character varying) TO PUBLIC;


--
-- TOC entry 38 (OID 27941)
-- Name: usersbyfirstcharacter; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE usersbyfirstcharacter AS (username character varying(50),
	"password" character varying(50),
	email character varying(75),
	forumview integer,
	approved boolean,
	profileapproved boolean,
	"trusted" boolean,
	fakeemail character varying(75),
	url character varying(100),
	signature character varying(256),
	datecreated timestamp without time zone,
	trackyourposts boolean,
	lastlogin timestamp without time zone,
	lastactivity timestamp without time zone,
	timezone integer,
	"location" character varying(100),
	occupation character varying(100),
	interests character varying(100),
	msn character varying(50),
	yahoo character varying(50),
	aim character varying(50),
	icq character varying(50),
	totalposts integer,
	hasavatar boolean,
	showunreadtopicsonly boolean,
	style character varying(20),
	avatartype integer,
	avatarurl character varying(256),
	showavatar boolean,
	dateformat character varying(10),
	postvieworder boolean,
	flatview boolean,
	ismoderator boolean,
	attributes bytea);


--
-- TOC entry 238 (OID 27942)
-- Name: forums_getusersbyfirstcharacter (character); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getusersbyfirstcharacter (character) RETURNS SETOF usersbyfirstcharacter
    AS '
	--- get a list of unbanned users whose username begins with _firstchar
	select
		username,
		password,
		email,
		forumview,
		approved,
		profileapproved,
		trusted,
		fakeemail,
		url,
		signature,
		datecreated,
		trackyourposts,
		lastlogin,
		lastactivity,
		timezone,
		location,
		occupation,
		interests,
		msn,
		yahoo,
		aim,
		icq,
		totalposts,
		hasavatar,
		showunreadtopicsonly,
		style,
		avatartype,
		avatarurl,
		showavatar,
		dateformat,
		postvieworder,
		flatview,
		(select cast(count(*) as int4) > 0 from moderators where username = u.username) as ismoderator,
		attributes
	from  
		users u
	where 
		lower(substring(username from 1 for 1)) = lower($1); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 239 (OID 27942)
-- Name: forums_getusersbyfirstcharacter (character); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getusersbyfirstcharacter (character) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getusersbyfirstcharacter (character) TO PUBLIC;


--
-- TOC entry 39 (OID 27944)
-- Name: usersonline; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE usersonline AS (username character varying(50),
	administrator integer,
	ismoderator integer);


--
-- TOC entry 240 (OID 27945)
-- Name: forums_getusersonline (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getusersonline (integer) RETURNS SETOF usersonline
    AS '
	-- get online users
	select
		username,
		(select cast(count(*) as int4) from usersinroles where rolename = ''forum-administrators'' and username = u.username limit 1) as administrator,
		(select cast(count(*) as int4) from moderators where username = u.username) as ismoderator
	from
		users u
	where
		lastactivity > dateadd(''minute'', (0 - $1), current_timestamp(3)); '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 241 (OID 27945)
-- Name: forums_getusersonline (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getusersonline (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getusersonline (integer) TO PUBLIC;


--
-- TOC entry 242 (OID 27946)
-- Name: forums_getvoteresults (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getvoteresults (integer) RETURNS SETOF vote
    AS '
  select
	*
  from
	vote
  where
	postid = $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 243 (OID 27946)
-- Name: forums_getvoteresults (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getvoteresults (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getvoteresults (integer) TO PUBLIC;


--
-- TOC entry 40 (OID 27949)
-- Name: isusertrackingpost; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE isusertrackingpost AS (isusertrackingpost boolean);


--
-- TOC entry 244 (OID 27950)
-- Name: forums_isusertrackingpost (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_isusertrackingpost (integer, character varying) RETURNS SETOF isusertrackingpost
    AS '
select exists(
	select 
		threadid 
	from 
		threadtrackings 
	where 
		threadid = $1 and 
		username ilike $2) as isusertrackingpost; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 245 (OID 27950)
-- Name: forums_isusertrackingpost (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_isusertrackingpost (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_isusertrackingpost (integer, character varying) TO PUBLIC;


--
-- TOC entry 246 (OID 27951)
-- Name: forums_markpostasread (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_markpostasread (integer, character varying) RETURNS integer
    AS '
declare
	_postid alias for $1;
	_username alias for $2;
	t_found int;
begin
	-- if _username is null it is an anonymous user
	if _username is not null then
		-- mark the post as read
		-- *********************
		-- only for postlevel = 1
		select into t_found 1 from posts where postid = _postid and postlevel = 1;
		if found then
			select into t_found 1 from postsread where username ilike _username and postid = _postid;
			if not found then	
				insert into postsread (username, postid) values (_username, _postid); 
			end if;
		end if;
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 247 (OID 27951)
-- Name: forums_markpostasread (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_markpostasread (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_markpostasread (integer, character varying) TO PUBLIC;


--
-- TOC entry 248 (OID 27952)
-- Name: forums_removemoderatedforumforuser (character varying, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_removemoderatedforumforuser (character varying, integer) RETURNS integer
    AS '
	-- remove a row from the moderators table
	delete from moderators
	where username ilike $1 and forumid = $2; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 249 (OID 27952)
-- Name: forums_removemoderatedforumforuser (character varying, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_removemoderatedforumforuser (character varying, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_removemoderatedforumforuser (character varying, integer) TO PUBLIC;


--
-- TOC entry 41 (OID 27954)
-- Name: topiccountforforum; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE topiccountforforum AS (totaltopics integer);


--
-- TOC entry 250 (OID 27955)
-- Name: forums_topiccountforforum (integer, timestamp without time zone, timestamp without time zone, character varying, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_topiccountforforum (integer, timestamp without time zone, timestamp without time zone, character varying, boolean) RETURNS SETOF topiccountforforum
    AS '
declare
	_forumid alias for $1;
	_maxdate alias for $2;
	_mindate alias for $3;
	_username alias for $4;
	_unreadtopicsonly alias for $5;
	_rec topiccountforforum%ROWTYPE;
begin
	if _username = '''' or _unreadtopicsonly = false then
		for _rec in 
		select 
			cast(count(*) as int4) as totaltopics
		from 
			posts 
		where 
			postlevel = 1 and 
			forumid = _forumid and 
			approved = true and
			threaddate >= _mindate and 
			threaddate <= _maxdate
		 loop
			return next _rec;
		    end loop;
		return;
	else
		for _rec in 
		select 
			cast(count(*) as int4) as totaltopics
		from 
			posts p
		where 
			postlevel = 1 and 
			forumid = _forumid and 
			approved = true and
			threaddate >= _mindate and 
			threaddate <= _maxdate and
			p.postid not in (select postsread.postid from postsread where postsread.username ilike _username) and
			p.postid >= (select markreadafter from forumsread where username ilike _username and forumid = _forumid)
		loop
			return next _rec;
		end loop;
	    return;
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 251 (OID 27955)
-- Name: forums_topiccountforforum (integer, timestamp without time zone, timestamp without time zone, character varying, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_topiccountforforum (integer, timestamp without time zone, timestamp without time zone, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_topiccountforforum (integer, timestamp without time zone, timestamp without time zone, character varying, boolean) TO PUBLIC;


--
-- TOC entry 252 (OID 27956)
-- Name: forums_trackanonymoususers (character); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_trackanonymoususers (character) RETURNS integer
    AS '
declare
	_userid alias for $1;
	t_found int;
begin
	-- does the user already exist?
	select into t_found 1 from anonymoususers where userid ilike _userid;
	if found then
		update 
			anonymoususers
		set 
			lastlogin = current_timestamp(3)
		where
			userid = _userid;
	else
		insert into
			anonymoususers
			(userid) 
		values
			(_userid);
	end if;
	
	-- anonymous users also pay tax to clean up table
	delete from anonymoususers where lastlogin < dateadd(''minute'', -20, current_timestamp(3)); 
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 253 (OID 27956)
-- Name: forums_trackanonymoususers (character); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_trackanonymoususers (character) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_trackanonymoususers (character) TO PUBLIC;


--
-- TOC entry 254 (OID 27957)
-- Name: forums_unbanuser (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_unbanuser (character varying) RETURNS integer
    AS '
	-- unban this user
	update users set
		approved = true
	where username ilike $1; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 255 (OID 27957)
-- Name: forums_unbanuser (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_unbanuser (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_unbanuser (character varying) TO PUBLIC;


--
-- TOC entry 256 (OID 27958)
-- Name: forums_updateemailtemplate (integer, character varying, text); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updateemailtemplate (integer, character varying, text) RETURNS integer
    AS '
	-- update a particular email message
	update emails set
		subject = $2,
		message = $3
	where emailid = $1; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 257 (OID 27958)
-- Name: forums_updateemailtemplate (integer, character varying, text); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updateemailtemplate (integer, character varying, text) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updateemailtemplate (integer, character varying, text) TO PUBLIC;


--
-- TOC entry 258 (OID 27959)
-- Name: forums_updateforum (integer, integer, character varying, character varying, boolean, integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updateforum (integer, integer, character varying, character varying, boolean, integer, boolean) RETURNS integer
    AS '
	-- if we are making the forum non-moderated, remove all forum moderators for this forum
	delete from moderators
		where forumid = $1 
		and $5 = false;
			
	-- update the forum information
	update forums set
		name = $3,
		forumgroupid = $2,
		description = $4,
		moderated = $5,
		daystoview = $6,
		active = $7
	where forumid = $1; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 259 (OID 27959)
-- Name: forums_updateforum (integer, integer, character varying, character varying, boolean, integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updateforum (integer, integer, character varying, character varying, boolean, integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updateforum (integer, integer, character varying, character varying, boolean, integer, boolean) TO PUBLIC;


--
-- TOC entry 260 (OID 27960)
-- Name: forums_updatemessagetemplatelist (integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updatemessagetemplatelist (integer, character varying, character varying) RETURNS integer
    AS '
update
	messages
set
	title = $2,
	body = $3
where
	messageid = $1; 
SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 261 (OID 27960)
-- Name: forums_updatemessagetemplatelist (integer, character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updatemessagetemplatelist (integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updatemessagetemplatelist (integer, character varying, character varying) TO PUBLIC;


--
-- TOC entry 262 (OID 27961)
-- Name: forums_updatepost (integer, character varying, text, boolean, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updatepost (integer, character varying, text, boolean, character varying) RETURNS integer
    AS '
	-- this sproc updates a post (called from the moderate/admin page)
	update 
		posts 
	set
		subject = $2,
		body = $3,
		islocked = $4
	where 
		postid = $1;
	-- we want to track what happened
	insert into
		moderationaudit
	values
		(current_timestamp(3), $1, $5, 2, null); 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 263 (OID 27961)
-- Name: forums_updatepost (integer, character varying, text, boolean, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updatepost (integer, character varying, text, boolean, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updatepost (integer, character varying, text, boolean, character varying) TO PUBLIC;


--
-- TOC entry 264 (OID 27962)
-- Name: forums_updateuserfromadminpage (character varying, boolean, boolean, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updateuserfromadminpage (character varying, boolean, boolean, boolean) RETURNS integer
    AS '
	update
		users
	set 
		profileapproved = $2,
		approved = $3,
		trusted = $4
	where
		username ilike $1; 
	SELECT 1;'
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 265 (OID 27962)
-- Name: forums_updateuserfromadminpage (character varying, boolean, boolean, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updateuserfromadminpage (character varying, boolean, boolean, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updateuserfromadminpage (character varying, boolean, boolean, boolean) TO PUBLIC;


--
-- TOC entry 42 (OID 27964)
-- Name: foruminfo; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE foruminfo AS (forumid integer,
	forumgroupid integer,
	parentid integer,
	name character varying(100),
	description character varying(3000),
	moderated boolean,
	daystoview integer,
	datecreated timestamp without time zone,
	active boolean,
	totaltopics integer,
	sortorder integer,
	isprivate boolean,
	displaymask bytea);


--
-- TOC entry 266 (OID 27965)
-- Name: forums_getforuminfo (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforuminfo (integer, character varying) RETURNS SETOF foruminfo
    AS '
declare 
	_forumid alias for $1;
	_username alias for $2;
	_rec foruminfo%ROWTYPE;

begin
  if _username is not null then
      for _rec in 
	select
		_forumid as forumid,
		forumgroupid,
		parentid,
		name,
		description,
		moderated,
		daystoview,
		datecreated,
		active,
		totalthreads as totaltopics,
		sortorder,
		coalesce((select distinct true from privateforums where forumid = f.forumid), false) as isprivate,
		displaymask
	from 
		forums f
	where 
		forumid = _forumid and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
	    loop
		return next _rec;
	    end loop;
	return;
  else
      for _rec in 
	select
		_forumid as forumid,
		forumgroupid,
		parentid,
		name,
		description,
		moderated,
		daystoview,
		datecreated,
		active,
		totalthreads as totaltopics,
		sortorder,
		false as isprivate,
		displaymask
	from 
		forums f
	where 
		forumid = _forumid and
		forumid not in (select forumid from privateforums)
	    loop
		return next _rec;
	    end loop;
	return;
  end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 267 (OID 27965)
-- Name: forums_getforuminfo (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforuminfo (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforuminfo (integer, character varying) TO PUBLIC;


--
-- TOC entry 272 (OID 27973)
-- Name: forums_changeforumgroupsortorder (integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_changeforumgroupsortorder (integer, boolean) RETURNS integer
    AS '
declare 
	_forumgroupid alias for $1;
	_moveup alias for $2;
	_currentsortvalue int;
	_replacesortvalue int;
begin
	-- get the current sort order
	select into _currentsortvalue  sortorder from forumgroups where forumgroupid = _forumgroupid;

	-- move the item up or down?
	if (_moveup = true) then
	    if (_currentsortvalue != 1) then
		_replacesortvalue := _currentsortvalue - 1;
		update forumgroups set sortorder = _currentsortvalue where sortorder = _replacesortvalue;
		update forumgroups set sortorder = _replacesortvalue where forumgroupid = _forumgroupid;
	    end if;
	else
	    if (_currentsortvalue < (select max(forumgroupid) from forumgroups)) then
		_replacesortvalue := _currentsortvalue + 1;
		update forumgroups set sortorder = _currentsortvalue where sortorder = _replacesortvalue;
		update forumgroups set sortorder = _replacesortvalue where forumgroupid = _forumgroupid;
	    end if;
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 273 (OID 27973)
-- Name: forums_changeforumgroupsortorder (integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_changeforumgroupsortorder (integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_changeforumgroupsortorder (integer, boolean) TO PUBLIC;


--
-- TOC entry 324 (OID 27975)
-- Name: forums_createnewuser (character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_createnewuser (character varying, character varying, character varying) RETURNS integer
    AS '
declare
	_username alias for $1;
	_email alias for $2;
	_randompassword alias for $3;
	t_found int;
begin
	-- this sproc returns various error/success codes
		-- a return value of 1 means success
		-- a return value of 2 means a dup username
		-- a return value of 3 means a dup email address
	-- first, we need to check if the username is a dup
	select into t_found 1 from users where username ilike _username;
	if found then
		return 2;
	else
		-- we need to check if the email is a dup
		select into t_found 1 from users where email = _email;
		if found then
			return 3;
		else
			-- everything''s peachy if we get this far - insert the user
			insert into users (username, email, password)
			values(_username, _email, _randompassword);
			return 1;	-- return everything''s fine status code; 
		end if;
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 325 (OID 27975)
-- Name: forums_createnewuser (character varying, character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_createnewuser (character varying, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_createnewuser (character varying, character varying, character varying) TO PUBLIC;


--
-- TOC entry 274 (OID 27976)
-- Name: forums_deletemoderatedpost (integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_deletemoderatedpost (integer, character varying, character varying) RETURNS integer
    AS '
declare
	_postid alias for $1;
	_approvedby alias for $2;
	_reason alias for $3;
	_threadid int;
	_forumid int;
	_username varchar(50);
begin
    -- we must delete all of the posts and replies
    -- first things first, determine if this is the parent of the thread
	
    select into _threadid, _forumid, _username 
		    threadid, forumid, username 
    from posts where postid = _postid;

    if _threadid = _postid then
		-- we are dealing with the parent fo the thread
		-- delete all of the thread tracking
	delete from threadtrackings
		where 
			threadid = _threadid;
		-- delete the entire thread
	delete from posts
		where 
			threadid = _threadid;
		-- clean up the forum statistics
		perform statistics_resetforumstatistics(_forumid);
		-- update users table to decrement post count for this user
		update
			users
		set 
			totalposts = (totalposts - 1)
		where
			username ilike _username;
		-- record to our moderation audit log
		insert into
			moderationaudit
		values
			(current_timestamp(3), _postid, _approvedby, 4, _reason);
    else
		-- we must recursively delete this post and all of its children
		perform forums_deletepostandchildren(_postid); 
    end if;
    return null;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 275 (OID 27976)
-- Name: forums_deletemoderatedpost (integer, character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_deletemoderatedpost (integer, character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_deletemoderatedpost (integer, character varying, character varying) TO PUBLIC;


--
-- TOC entry 276 (OID 27977)
-- Name: forums_deletepost (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_deletepost (integer) RETURNS integer
    AS '
declare
	_postid alias for $1;
	_threadid int;
	_forumid int;
	_username varchar(50);
begin
	-- we must delete all of the posts and replies
	-- first things first, determine if this is the parent of the thread

	select into _threadid, _forumid, _username
		    threadid, forumid, username 
	from posts 
	where postid = _postid;

	if _threadid = _postid then
	  	-- we are dealing with the parent fo the thread
		-- delete all of the thread tracking
		delete from 
			threadtrackings
		where 
			threadid = _threadid;

		-- delete the entire thread
		delete from 
			posts
		where 
			threadid = _threadid;

		-- update the forum statistics
		perform statistics_resetforumstatistics(_forumid);
	else
		-- we must recursively delete this post and all of its children
		perform forums_deletepostandchildren(_postid); 
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 277 (OID 27977)
-- Name: forums_deletepost (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_deletepost (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_deletepost (integer) TO PUBLIC;


--
-- TOC entry 278 (OID 27978)
-- Name: forums_deletepostandchildren (integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_deletepostandchildren (integer) RETURNS integer
    AS '
declare 
	_postid alias for $1;
	_username varchar(50);
	_forumid int;
	_rec record;
begin
	-- build a cursor to loop through all the children of this post
	for _rec in
	select postid 
	from posts
	where parentid = _postid loop
		perform forums_deletepostandchildren(_rec.postid);
	end loop;
	-- now, ahead and delete the post
	select into _username, _forumid
		    username, forumid
	from 
		posts
	where
		postid = _postid;

	-- decrement user''s total post count
	update
		users
	set
		totalposts = (totalposts - 1)
	where
		username ilike _username;

	-- now, delete the post
	delete from posts 
	where 
		postid = _postid;

	-- update the forum statistics
	perform statistics_resetforumstatistics(_forumid); 
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 279 (OID 27978)
-- Name: forums_deletepostandchildren (integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_deletepostandchildren (integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_deletepostandchildren (integer) TO PUBLIC;


--
-- TOC entry 43 (OID 27980)
-- Name: findusersbyname; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE findusersbyname AS (username character varying(50),
	"password" character varying(50),
	email character varying(75),
	forumview integer,
	approved boolean,
	profileapproved boolean,
	"trusted" boolean,
	fakeemail character varying(75),
	url character varying(100),
	signature character varying(256),
	datecreated timestamp without time zone,
	trackyourposts boolean,
	lastlogin timestamp without time zone,
	lastactivity timestamp without time zone,
	timezone integer,
	"location" character varying(100),
	occupation character varying(100),
	interests character varying(100),
	msn character varying(50),
	yahoo character varying(50),
	aim character varying(50),
	icq character varying(50),
	totalposts integer,
	hasavatar boolean,
	showunreadtopicsonly boolean,
	style character varying(20),
	avatartype integer,
	avatarurl character varying(256),
	showavatar boolean,
	dateformat character varying(10),
	postvieworder boolean,
	ismoderator boolean,
	flatview boolean,
	attributes bytea);


--
-- TOC entry 280 (OID 27981)
-- Name: forums_findusersbyname (integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_findusersbyname (integer, integer, character varying) RETURNS SETOF findusersbyname
    AS '
declare 
	_pageindex alias for $1;
	_pagesize alias for $2;
	_usernametofind alias for $3;
	_pagelowerbound int;
	_rec findusersbyname%ROWTYPE;
begin
    -- set the page bounds
    _pagelowerbound := _pagesize * _pageindex;

    for _rec in
    select
	u.username,
	password,
	email,
	forumview,
	approved,
        profileapproved,
	trusted,
	fakeemail,
	url,
	signature,
	datecreated,
	trackyourposts,
	lastlogin,
	lastactivity,
	timezone,
	location,
	occupation,
	interests,
	msn,
	yahoo,
	aim,
	icq,
	totalposts,
	hasavatar,
	showunreadtopicsonly,
	style,
	avatartype,
	avatarurl,
	showavatar,
	dateformat,
	postvieworder,
	(select cast(count(*) as int4) > 0 from moderators where username = u.username) as ismoderator,
	flatview,
	attributes
    from 
	users u
    where 
	approved = true and 
	displayinmemberlist = true and
	username ilike cast(''%'' as character varying) || _usernametofind || cast(''%'' as character varying)
    order by 
	datecreated
    offset _pagelowerbound
    limit _pagesize
    loop
	return next _rec;
    end loop;
    return; 
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 281 (OID 27981)
-- Name: forums_findusersbyname (integer, integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_findusersbyname (integer, integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_findusersbyname (integer, integer, character varying) TO PUBLIC;


--
-- TOC entry 332 (OID 27982)
-- Name: forums_getallforumgroupsformoderation (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallforumgroupsformoderation (character varying) RETURNS SETOF forumgroups
    AS '
declare
	_username alias for $1;
	_rec forumgroups%ROWTYPE;
	t_found int;
begin
  if (0 = (select forumid from moderators where username ilike _username)) then
	-- note, we still only allow the user to moderate forums that he/she has access to
	for _rec in
	select 
		forumgroupid,
		name,
		sortorder
	from
		forumgroups
	where
		exists(
			select
				forumid
			from
				forums
			where
				forumgroups.forumgroupid = forums.forumgroupid and
				forums.active = true and
				(forumid not in (select forumid from privateforums) or
				forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))) and
				(select cast(count(*) as int4) from posts p where p.forumid = forums.forumid and p.approved = false) > 0
		) 
	loop
		return next _rec;
	end loop;
  else
	-- note, we still only allow the user to moderate forums that he/she has access to
	for _rec in
	select 
		forumgroupid,
		name,
		sortorder
	from
		forumgroups
	where
		exists(
			select
				forumid
			from
				forums
			where
				forumgroups.forumgroupid = forums.forumgroupid and
				forums.active = true and
				(forumid not in (select forumid from privateforums) or
				forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))) and
				forumid in (select forumid from moderators where username ilike _username)  and
				(select cast(count(*) as int4) from posts p where p.forumid = forums.forumid and p.approved = false) > 0
		)
	loop
		return next _rec;
	end loop;
  end if;
  return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 333 (OID 27982)
-- Name: forums_getallforumgroupsformoderation (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallforumgroupsformoderation (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallforumgroupsformoderation (character varying) TO PUBLIC;


--
-- TOC entry 44 (OID 27984)
-- Name: allforumsbyforumgroupid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE allforumsbyforumgroupid AS (forumid integer,
	forumgroupid integer,
	name character varying(50),
	description character varying(3000),
	datecreated timestamp without time zone,
	daystoview integer,
	moderated boolean,
	totalposts integer,
	totaltopics integer,
	mostrecentpostid integer,
	mostrecentpostdate timestamp without time zone,
	mostrecentpostauthor character varying(50),
	active boolean,
	sortorder integer);


--
-- TOC entry 282 (OID 27985)
-- Name: forums_getallforumsbyforumgroupid (integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallforumsbyforumgroupid (integer, boolean) RETURNS SETOF allforumsbyforumgroupid
    AS '
declare
	_forumgroupid alias for $1;
	_getallforums alias for $2;
	_rec allforumsbyforumgroupid%ROWTYPE;
begin
	-- return all of the columns in all of the forums
	if _getallforums = false then
		-- get just the active forums
		for _rec in
		select
			forumid,
			forumgroupid,
			name,
			description,
			datecreated,
			daystoview,
			moderated,
			(select cast(count(*) as int4) from posts p where p.forumid = f.forumid and p.approved=true) as totalposts,
			(select cast(count(*) as int4) from posts p2 where p2.forumid = f.forumid and p2.approved=true and p2.postlevel=1) as totaltopics,
			(select postid from posts p3 where p3.forumid = f.forumid and p3.approved=1 and postdate < current_timestamp(3) order by postdate desc limit 1) as mostrecentpostid,
			(select postdate from posts p3 where p3.forumid = f.forumid and p3.approved=1 and postdate < current_timestamp(3) order by postdate desc limit 1) as mostrecentpostdate,
			(select username from posts p3 where p3.forumid = f.forumid and p3.approved=1 and postdate < current_timestamp(3) order by postdate desc limit 1) as mostrecentpostauthor,
			true as active,
			sortorder
		from forums f
		where active = 1 and
			forumgroupid = _forumgroupid
		loop
			return next _rec;
		end loop;
	else
		-- get all of the forums
		for _rec in
		select
			forumid,
			forumgroupid,
			name,
			description,
			datecreated,
			daystoview,
			moderated,
			(select cast(count(*) as int4) from posts p where p.forumid = f.forumid and p.approved=true) as totalposts,
			(select cast(count(*) as int4) from posts p2 where p2.forumid = f.forumid and p2.approved=true and p2.postlevel=1) as totaltopics,
			(select postid from posts p3 where p3.forumid = f.forumid and p3.approved=1 and postdate < current_timestamp(3) order by postdate desc limit 1) as mostrecentpostid,
			(select postdate from posts p3 where p3.forumid = f.forumid and p3.approved=1 and postdate < current_timestamp(3) order by postdate desc limit 1) as mostrecentpostdate,
			(select username from posts p3 where p3.forumid = f.forumid and p3.approved=1 and postdate < current_timestamp(3) order by postdate desc limit 1) as mostrecentpostauthor,
			active,
			sortorder
		from forums f
		where 
			forumgroupid = _forumgroupid
		loop
			return next _rec;
		end loop;
	end if; 
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 283 (OID 27985)
-- Name: forums_getallforumsbyforumgroupid (integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallforumsbyforumgroupid (integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallforumsbyforumgroupid (integer, boolean) TO PUBLIC;


--
-- TOC entry 45 (OID 27987)
-- Name: allmessages; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE allmessages AS (subject character varying(256),
	postid integer,
	forumid integer,
	threadid integer,
	parentid integer,
	postlevel integer,
	sortorder integer,
	approved boolean,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	replies integer,
	body text,
	totalmessagesinthread integer,
	totalviews integer,
	islocked boolean);


--
-- TOC entry 284 (OID 27988)
-- Name: forums_getallmessages (integer, integer, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallmessages (integer, integer, integer) RETURNS SETOF allmessages
    AS '
-- the returned recordset depends on the viewtype option chosen
--	0 == flat display
--	1 == mixed display (just top-level posts)
--	2 == threaded display
declare 
	_forumid alias for $1;
	_viewtype alias for $2;
	_pagesback alias for $3;
	_daystoview int;
	_startdate timestamp;
	_stopdate timestamp;
	_rec allmessages%ROWTYPE;
begin
  select into _daystoview  daystoview from forums where forumid = _forumid;
  select into _startdate dateadd(''dd'', -_pagesback * _daystoview, current_timestamp(3));
  select into _stopdate  dateadd(''dd'', -_daystoview, _startdate);
  if _viewtype = 0 then
	-- flat display
	for _rec in
	select 
		subject,
		postid,
		_forumid as forumid,
		threadid,
		parentid,
		postlevel,
		sortorder,
		approved,
		postdate,
		threaddate,	
		username,
		(select cast(count(*) as int4) from posts p2 where p2.parentid = p.postid and p2.postlevel != 1) as replies,
		body,
		0 as totalmessagesinthread, -- not used
		totalviews,
		islocked
	from posts p
	where approved = true and forumid = _forumid and postdate >= _stopdate and postdate <= _startdate
	order by postdate desc
        loop
		return next _rec;
	end loop;
  else 
    if _viewtype = 1 then
	-- mixed display
	for _rec in
	select 
		subject,
		postid,
		threadid,
		parentid,
		_forumid as forumid,
		postlevel,
		sortorder,
		(select max(postdate) from posts where p.threadid = threadid) as postdate,
		approved,
		threaddate,
		username,
		(select cast(count(*) as int4) from posts where p.threadid = threadid and postlevel != 1) as replies,
		body,
		0 as totalmessagesinthread, -- not used
		totalviews,
		islocked
	from posts p
	where approved = true and forumid = _forumid and postlevel = 1 and threaddate >= _stopdate and threaddate <= _startdate
	order by postdate desc
	loop
		return next _rec;
	end loop;
    else 
      if _viewtype = 2 then
	-- threaded display
	for _rec in
	select 
		subject,
		postid,
		threadid,
		parentid,
		_forumid as forumid,
		postlevel,
		sortorder,
		approved,
		postdate,
		threaddate,
		username,
		0 as replies,
		body,
		0 as totalmessagesinthread, -- not used
		totalviews,
		islocked
	from posts p
	where approved = true and forumid = _forumid and threaddate >= _stopdate and threaddate <= _startdate
	order by threadid desc, sortorder
	loop
		return next _rec;
	end loop;
      end if;
    end if;
  end if;
  return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 285 (OID 27988)
-- Name: forums_getallmessages (integer, integer, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallmessages (integer, integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallmessages (integer, integer, integer) TO PUBLIC;


--
-- TOC entry 46 (OID 27990)
-- Name: allunmoderatedtopicspaged; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE allunmoderatedtopicspaged AS (subject character varying(256),
	postid integer,
	threadid integer,
	parentid integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	pinneddate timestamp without time zone,
	username character varying(50),
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	ispinned boolean,
	hasread boolean,
	mostrecentpostauthor character varying(50),
	mostrecentpostid integer);


--
-- TOC entry 334 (OID 27991)
-- Name: forums_getallunmoderatedtopicspaged (integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getallunmoderatedtopicspaged (integer, integer, integer, character varying) RETURNS SETOF allunmoderatedtopicspaged
    AS '
declare 
	_forumid alias for $1;
	_pagesize alias for $2;
	_pageindex alias for $3;
	_username alias for $4;
	_pagelowerbound int;
	_rec allunmoderatedtopicspaged%rowtype;
begin
	-- set the page bounds
	_pagelowerbound := _pagesize * _pageindex;

	-- now get the posts
	for _rec in
	select 
		subject,
		p.postid,
		threadid,
		parentid,
		p.postdate,
		threaddate,
		pinneddate,
		username,
		(select cast(count(*) as int4) from posts where p.threadid = threadid and postlevel != 1 and approved = true) as replies,
		body,
		totalviews,
		islocked,
		ispinned,
		false as hasread,
		'''' as mostrecentpostauthor,
		0 as mostrecentpostid
	from 
		posts p
	where 
		forumid = _forumid and 
		approved = false
	order by 
		pinneddate desc
	offset _pagelowerbound
	limit _pagesize
	loop
		return next _rec;
	end loop;
        return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 335 (OID 27991)
-- Name: forums_getallunmoderatedtopicspaged (integer, integer, integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getallunmoderatedtopicspaged (integer, integer, integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getallunmoderatedtopicspaged (integer, integer, integer, character varying) TO PUBLIC;


--
-- TOC entry 47 (OID 27993)
-- Name: forumsformoderationbyforumgroupid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumsformoderationbyforumgroupid AS (forumid integer,
	forumgroupid integer,
	name character varying(100),
	description character varying(3000),
	datecreated timestamp without time zone,
	daystoview integer,
	moderated boolean,
	totalposts integer,
	totaltopics integer,
	mostrecentpostid integer,
	mostrecentthreadid integer,
	mostrecentpostdate timestamp without time zone,
	mostrecentpostauthor character varying(50),
	totalpostsawaitingmoderation integer,
	active boolean,
	lastuseractivity timestamp without time zone,
	sortorder integer,
	isprivate boolean);


--
-- TOC entry 286 (OID 27994)
-- Name: forums_getforumsformoderationbyforumgroupid (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumsformoderationbyforumgroupid (integer, character varying) RETURNS SETOF forumsformoderationbyforumgroupid
    AS '
declare
	_forumgroupid alias for $1;
	_username alias for $2;
	_rec forumsformoderationbyforumgroupid%ROWTYPE; 
begin
  if (0 = (select forumid from moderators where username ilike _username)) then
	for _rec in
	select
		forumid,
		forumgroupid,
		name,
		description,
		datecreated,
		daystoview,
		moderated,
		totalposts,
		totalthreads as totaltopics,
		mostrecentpostid,
		mostrecentthreadid,
		mostrecentpostdate,
		mostrecentpostauthor,
		(select cast(count(*) as int4) from posts p where p.forumid = f.forumid and p.approved = false) as totalpostsawaitingmoderation,
		true as active,
		(select lastactivity from forumsread where username ilike _username and forumid = f.forumid) as lastuseractivity,
		sortorder,
		false as isprivate
	from 
		forums f
	where 
		active = true and
		forumgroupid = _forumgroupid and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))) and
		(select cast(count(*) as int4) from posts p where p.forumid = f.forumid and p.approved = false) > 0
	loop
		return next _rec;
	end loop;
  else
	for _rec in
	select
		forumid,
		forumgroupid,
		name,
		description,
		datecreated,
		daystoview,
		moderated,
		totalposts,
		totaltopics = totalthreads,
		mostrecentpostid,
		mostrecentthreadid,
		mostrecentpostdate,
		mostrecentpostauthor,
		(select cast(count(*) as int4) from posts p where p.forumid = f.forumid and p.approved = 0) as totalpostsawaitingmoderation,
		active = 1,
		(select lastactivity from forumsread where username ilike _username and forumid = f.forumid) as lastuseractivity,
		sortorder,
		isprivate = 0
	from 
		forums f
	where 
		active = true and
		forumgroupid = _forumgroupid and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))) and
		forumid in (select forumid from moderators where username ilike _username) and
		(select cast(count(*) as int4) from posts p where p.forumid = f.forumid and p.approved = false) > 0	
	loop
		return next _rec;
	end loop; 
  end if;
  return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 287 (OID 27994)
-- Name: forums_getforumsformoderationbyforumgroupid (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumsformoderationbyforumgroupid (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumsformoderationbyforumgroupid (integer, character varying) TO PUBLIC;


--
-- TOC entry 48 (OID 27996)
-- Name: forumsmoderatedbyuser; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumsmoderatedbyuser AS (forumid integer,
	emailnotification boolean,
	forumname character varying(100),
	datecreated timestamp without time zone);


--
-- TOC entry 340 (OID 27997)
-- Name: forums_getforumsmoderatedbyuser (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumsmoderatedbyuser (character varying) RETURNS SETOF forumsmoderatedbyuser
    AS '
declare
	_username alias for $1;
	_rec forumsmoderatedbyuser%ROWTYPE;
	t_found int;
begin
	-- determine if this user can moderate all forums
	select into t_found 1 from moderators where forumid = 0 and username ilike _username;
	if found then
		for _rec in
		select forumid, emailnotification, ''all forums'' as forumname, datecreated from moderators
		where forumid = 0 and username ilike _username 
		loop
			return next _rec;
		end loop;
	else
		-- get all of the forums moderated by this particular user
		for _rec in
		select
			m.forumid,
			emailnotification,
			f.name as forumname,
			m.datecreated
		from moderators m
			inner join forums f on
				f.forumid = m.forumid
		where username ilike _username
		loop
			return next _rec;
		end loop;
	end if;
	return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 341 (OID 27997)
-- Name: forums_getforumsmoderatedbyuser (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumsmoderatedbyuser (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumsmoderatedbyuser (character varying) TO PUBLIC;


--
-- TOC entry 49 (OID 27999)
-- Name: forumsnotmoderatedbyuser; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE forumsnotmoderatedbyuser AS (forumid integer,
	forumname character varying(100));


--
-- TOC entry 342 (OID 28000)
-- Name: forums_getforumsnotmoderatedbyuser (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getforumsnotmoderatedbyuser (character varying) RETURNS SETOF forumsnotmoderatedbyuser
    AS '
declare
	_username alias for $1;
	_rec forumsnotmoderatedbyuser%ROWTYPE;
	t_found int;
begin
	-- determine if this user can moderate all forums
	select into t_found 1 from moderators where forumid = 0 and username ilike _username;
	if not found then
		-- get all of the forums not moderated by this particular user
		for _rec in
		select 
			0 as forumid, 
			''all forums'' as forumname
		loop
			return next _rec;
		end loop;
		for _rec in
		select
			forumid,
			f.name as forumname
		from forums f 
		where forumid not in (select forumid from moderators where username ilike _username)
	 	loop
			return next _rec;
		end loop;
	end if;
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 343 (OID 28000)
-- Name: forums_getforumsnotmoderatedbyuser (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getforumsnotmoderatedbyuser (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getforumsnotmoderatedbyuser (character varying) TO PUBLIC;


--
-- TOC entry 50 (OID 28002)
-- Name: moderatedforums; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE moderatedforums AS (forumid integer,
	forumgroupid integer,
	name character varying(100),
	description character varying(3000),
	datecreated timestamp without time zone,
	moderated boolean,
	daystoview integer,
	active boolean,
	sortorder integer);


--
-- TOC entry 288 (OID 28003)
-- Name: forums_getmoderatedforums (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getmoderatedforums (character varying) RETURNS SETOF moderatedforums
    AS '
declare
	_username alias for $1;
	_rec moderatedforums%ROWTYPE;
	t_found int;
begin
	-- returns a list of posts awaiting moderation
	-- the posts returned are those that this user can work on
	-- if moderators.forumid = 0 for this user, then they can moderate all forums
	select into t_found 1  from moderators where username ilike _username and forumid=0;
	if found then
		-- return all posts awaiting moderation
		for _rec in
		select
			forumid,
			forumgroupid,
			name,
			description,
			datecreated,
			moderated,
			daystoview,
			active,
			sortorder
		from 
			forums
		where 	
			active = true
		order by 
			datecreated
		loop
			return next _rec;
		end loop;
	else
		-- return only those posts in the forum this user can moderate
		for _rec in
		select
			forumid,
			forumgroupid,
			name,
			description,
			datecreated,
			moderated,
			daystoview,
			active,
			sortorder
		from 
			forums
		where 
			active = true and 
			forumid in (select forumid from moderators where username ilike _username)
		order by 
			datecreated
		loop
			return next _rec;
		end loop;
	end if; 
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 289 (OID 28003)
-- Name: forums_getmoderatedforums (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getmoderatedforums (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getmoderatedforums (character varying) TO PUBLIC;


--
-- TOC entry 51 (OID 28005)
-- Name: moderatedposts; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE moderatedposts AS (postid integer,
	threadid integer,
	threaddate timestamp without time zone,
	postlevel integer,
	sortorder integer,
	parentid integer,
	subject character varying(256),
	approved boolean,
	forumid integer,
	forumname character varying(100),
	postdate timestamp without time zone,
	username character varying(50),
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	hasread boolean);


--
-- TOC entry 290 (OID 28006)
-- Name: forums_getmoderatedposts (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getmoderatedposts (character varying) RETURNS SETOF moderatedposts
    AS '
declare
	_username alias for $1;
	_rec moderatedposts%ROWTYPE;
	t_found int;
begin
	-- returns a list of posts awaiting moderation
	-- the posts returned are those that this user can work on
	-- if moderators.forumid = 0 for this user, then they can moderate all forums
	select into t_found 1 from moderators where username ilike _username and forumid=0;
	if found then
		-- return all posts awaiting moderation
		for _rec in
		select
			postid,
			threadid,
			threaddate,
			postlevel,
			p.sortorder,
			p.parentid,
			subject,
			approved,
			p.forumid,
			f.name as forumname,
			postdate,
			p.username,
			false as replies,
			body,
			totalviews,
			islocked,
			false as hasread
		from posts p
			inner join forums f on
				f.forumid = p.forumid
		where approved = 0
		order by p.forumid, postdate
		loop
			return next _rec;
		end loop;
	else
		-- return only those posts in the forum this user can moderate
		for _rec in
		select
			postid,
			p.parentid,
			approved,
			threadid,
			threaddate,
			postlevel,
			p.sortorder,
			subject,
			p.forumid,
			f.name as forumname,
			postdate,
			false as replies,
			p.username,
			body,
			totalviews,
			islocked,
			true as hasread
		from posts p
			inner join forums f on
				f.forumid = p.forumid
		where 
			approved = false and 
			p.forumid in (select forumid from moderators where username ilike _username)
		order by p.forumid, postdate
		loop
			return next _rec;
		end loop; 
	end if;
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 291 (OID 28006)
-- Name: forums_getmoderatedposts (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getmoderatedposts (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getmoderatedposts (character varying) TO PUBLIC;


--
-- TOC entry 52 (OID 28008)
-- Name: timezone; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE timezone AS (timezone integer);


--
-- TOC entry 292 (OID 28009)
-- Name: forums_gettimezonebyusername (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettimezonebyusername (character varying) RETURNS SETOF timezone
    AS '
	-- get this user''s timezone offset
	select timezone
	from users
	where username ilike $1; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 293 (OID 28009)
-- Name: forums_gettimezonebyusername (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettimezonebyusername (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettimezonebyusername (character varying) TO PUBLIC;


--
-- TOC entry 53 (OID 28011)
-- Name: top25newposts; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE top25newposts AS (subject character varying(256),
	postid integer,
	threadid integer,
	parentid integer,
	postdate timestamp without time zone,
	threaddate timestamp without time zone,
	username character varying(50),
	replies integer,
	body text,
	totalviews integer,
	islocked boolean,
	hasread boolean,
	mostrecentpostauthor character varying(50),
	mostrecentpostid integer);


--
-- TOC entry 294 (OID 28013)
-- Name: forums_gettop25newposts (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_gettop25newposts (character varying) RETURNS SETOF top25newposts
    AS '
declare
	_username alias for $1;
	_rec top25newposts%ROWTYPE;
begin
    if _username is null then
	for _rec in
	select
		subject,
		body,
		p.postid,
		threadid,
		parentid,
		(select max(postdate) from posts where p.threadid = threadid) as postdate,
		threaddate,
		username,
		(select cast(count(*) as int4) from posts where p.threadid = threadid and postlevel != 1 and approved = true) as replies,
		body,
		totalviews,
		islocked,
		false as hasread,
		(select username from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
		(select postid from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
	from 
		posts p 
	where 
		postlevel = 1 and 
		approved = true and
		forumid not in (select forumid from privateforums)
	order by 
		threaddate desc limit 25
	loop
		return next _rec;
	end loop;
    else
	for _rec in
	select
		subject,
		body,
		p.postid,
		threadid,
		parentid,
		(select max(postdate) from posts where p.threadid = threadid) as postdate,
		threaddate,
		username,
		(select cast(count(*) as int4) from posts where p.threadid = threadid and postlevel != 1 and approved = true) as replies,
		body,
		totalviews,
		islocked,
		hasread = 0,
		(select username from posts where p.threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
		mostrecentpostid = (select postid from posts where p.threadid = threadid and approved = true order by postdate desc limit 1)
	from 
		posts p
	where 
		postlevel = 1 and 
		approved = true and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
	order by 
		threaddate desc
	limit 25
	loop
		return next _rec;
	end loop; 
    end if;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 295 (OID 28013)
-- Name: forums_gettop25newposts (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_gettop25newposts (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_gettop25newposts (character varying) TO PUBLIC;


--
-- TOC entry 54 (OID 28015)
-- Name: unmoderatedpoststatus; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE unmoderatedpoststatus AS (oldestpostageinminutes integer,
	totalpostsinmoderationqueue integer);


--
-- TOC entry 296 (OID 28016)
-- Name: a(integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getunmoderatedpoststatus (integer, character varying) RETURNS SETOF unmoderatedpoststatus
    AS '
declare 
	_forumid alias for $1;
	_username alias for $2;
	_rec unmoderatedpoststatus%rowtype;
begin
	for _rec in
	select 
		(current_timestamp(3) - isnull(min(postdate),current_timestamp(3)))*24*60 as oldestpostageinminutes,
		cast(count(postid) as int4) as totalpostsinmoderationqueue
	from 
		posts p 
	where 
		(_forumid = 0 or forumid = _forumid) and 
		approved = false
	loop
		return next _rec;
	end loop;
	return;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 297 (OID 28016)
-- Name: forums_getunmoderatedpoststatus (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getunmoderatedpoststatus (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getunmoderatedpoststatus (integer, character varying) TO PUBLIC;


--
-- TOC entry 298 (OID 28017)
-- Name: forums_markallthreadsread (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_markallthreadsread (integer, character varying) RETURNS integer
    AS '
declare
	_forumid alias for $1;
	_username alias for $2;
	_postid int;
	t_found int;
begin

	-- first find the max post id for the given forum
	select into _postid  max(postid) from posts where forumid = _forumid;
	-- do we need to performa an insert or an update?
	select into t_found 1 from forumsread where forumid = _forumid and username ilike _username;
	if found then
		update 
			forumsread
		set
			markreadafter = _postid
		where
			forumid = _forumid and
			username ilike _username;
	else
		insert into
			forumsread
			(forumid, username, markreadafter)
		values
			(_forumid, _username, _postid);
	end if;
	-- do some clean up
	delete from postsread where postid < _postid and username ilike _username; 
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 299 (OID 28017)
-- Name: forums_markallthreadsread (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_markallthreadsread (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_markallthreadsread (integer, character varying) TO PUBLIC;


--
-- TOC entry 300 (OID 28018)
-- Name: forums_removeforumfromrole (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_removeforumfromrole (integer, character varying) RETURNS integer
    AS '
declare 
	_forumid alias for $1;
	_rolename alias for $2;
	t_found int;
begin
	select into t_found 1 from privateforums where forumid=_forumid and rolename ilike _rolename;
	if found then
		delete from 
			privateforums
		where
			forumid=_forumid and rolename ilike _rolename; 
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 301 (OID 28018)
-- Name: forums_removeforumfromrole (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_removeforumfromrole (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_removeforumfromrole (integer, character varying) TO PUBLIC;


--
-- TOC entry 302 (OID 28019)
-- Name: forums_removeuserfromrole (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_removeuserfromrole (character varying, character varying) RETURNS integer
    AS '
declare
	_username alias for $1;
	_rolename alias for $2;
	t_found int;
begin
	select into t_found 1 from usersinroles where username ilike _username and rolename ilike _rolename;
	if found then
		delete from 
			usersinroles
		where
			username ilike _username and rolename ilike _rolename; 
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 303 (OID 28019)
-- Name: forums_removeuserfromrole (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_removeuserfromrole (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_removeuserfromrole (character varying, character varying) TO PUBLIC;


--
-- TOC entry 304 (OID 28020)
-- Name: forums_reversetrackingoption (character varying, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_reversetrackingoption (character varying, integer) RETURNS integer
    AS '
declare
	_username alias for $1;
	_postid alias for $2;
	t_found int;
	_threadid int;
begin
	-- reverse the user''s tracking options for a particular thread
	-- first get the threadid of the post

	select into _threadid  threadid from posts where postid = _postid;
	select into t_found 1 from threadtrackings where threadid = _threadid and username ilike _username;
	if found then
		-- the user is tracking this thread, delete this row
		delete from threadtrackings
			where threadid = _threadid and username ilike _username;
	else
		-- this user isn''t tracking the thread, so add her
		insert into threadtrackings (threadid, username)
			values(_threadid, _username); 
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 305 (OID 28020)
-- Name: forums_reversetrackingoption (character varying, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_reversetrackingoption (character varying, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_reversetrackingoption (character varying, integer) TO PUBLIC;


--
-- TOC entry 306 (OID 28021)
-- Name: forums_toggleoptions (character varying, boolean, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_toggleoptions (character varying, boolean, boolean) RETURNS integer
    AS '
declare 
	_username alias for $1;
	_hidereadthreads alias for $2;
	_flatview alias for $3;
begin
    if _flatview is null then
	update
		users
	set
		showunreadtopicsonly = _hidereadthreads
	where
		username ilike _username;
    else
	update
		users
	set
		showunreadtopicsonly = _hidereadthreads,
		flatview = _flatview
	where
		username ilike _username; 
    end if;
    return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 307 (OID 28021)
-- Name: forums_toggleoptions (character varying, boolean, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_toggleoptions (character varying, boolean, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_toggleoptions (character varying, boolean, boolean) TO PUBLIC;


--
-- TOC entry 308 (OID 28022)
-- Name: forums_updateforumgroup (character varying, integer); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updateforumgroup (character varying, integer) RETURNS integer
    AS '
declare
	_forumgroupname alias for $1;
	_forumgroupid alias for $2;
begin
	if _forumgroupname is null then
		delete from 
			forumgroups
		where
			forumgroupid = _forumgroupid;
	else
		-- insert a new forum
		update 
			forumgroups 
		set 
			name = _forumgroupname
		where 
			forumgroupid = _forumgroupid; 
	end if;
	return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 309 (OID 28022)
-- Name: forums_updateforumgroup (character varying, integer); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updateforumgroup (character varying, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updateforumgroup (character varying, integer) TO PUBLIC;


--
-- TOC entry 350 (OID 28023)
-- Name: forums_updateroledescription (character varying, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updateroledescription (character varying, character varying) RETURNS integer
    AS '
declare
	_rolename alias for $1;
	_description alias for $2;
	t_found int;
begin
    select into t_found 1 from userroles where rolename ilike _rolename;
    if found then
            update userroles
            set description=_description
            where rolename ilike _rolename; 
    end if;
    return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 351 (OID 28023)
-- Name: forums_updateroledescription (character varying, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updateroledescription (character varying, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updateroledescription (character varying, character varying) TO PUBLIC;


--
-- TOC entry 310 (OID 28024)
-- Name: forums_vote (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_vote (integer, character varying) RETURNS integer
    AS '
declare
	_postid alias for $1;
	_vote alias for $2;
	t_found int;
begin
  select into
        t_found 1 
    from 
        vote 
    where 
        postid = _postid and vote = _vote;
  if not found then
    -- transacted insert for download count
        insert into 
            vote
        values
        (
            _postid,
            _vote,
            1
        );
  else
    -- transacted update for download count
        update 
          vote
        set 
          votecount  =  votecount + 1
        where 
          postid = _postid and
          vote = _vote;
  end if;
  return null;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 311 (OID 28024)
-- Name: forums_vote (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_vote (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_vote (integer, character varying) TO PUBLIC;


--
-- TOC entry 55 (OID 28026)
-- Name: postread; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE postread AS (hasread boolean);


--
-- TOC entry 312 (OID 28027)
-- Name: forums_getpostread (integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getpostread (integer, character varying) RETURNS SETOF postread
    AS '
declare 
	_postid alias for $1;
	_username alias for $2;
	_hasread bool;
	t_found int;
	_rec postread%ROWTYPE;
begin
	_hasread := false;
	select into t_found 1
	from
		postsread
	where
		postid = _postid and
		username ilike _username;
	if found then
		_hasread := true;
		for _rec in
		select _hasread as hasread
		loop
			return next _rec; 
		end loop;
	end if;
	return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 313 (OID 28027)
-- Name: forums_getpostread (integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getpostread (integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getpostread (integer, character varying) TO PUBLIC;


--
-- TOC entry 56 (OID 28029)
-- Name: prevnextthreadid; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE prevnextthreadid AS (threadid integer);


--
-- TOC entry 314 (OID 28030)
-- Name: forums_getprevnextthreadid (integer, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getprevnextthreadid (integer, boolean) RETURNS SETOF prevnextthreadid
    AS '
declare 
	_postid alias for $1;
	_nextthread alias for $2;
	_currentthreadid int;
	_currentthreaddate timestamp;
	_forumid int;
	_threadid int;
	_rec prevnextthreadid%rowtype;
begin
  select into _currentthreadid, _currentthreaddate, _forumid
		 threadid, threaddate, forumid 
  from posts where postid = _postid;

  if _nextthread = true then
	select into _threadid  threadid
	from
		posts
	where
		postlevel = 1 and
		approved = true and
		forumid = _forumid and
		threaddate < _currentthreaddate limit 1;
  else
	select into _threadid  threadid 
	from
		posts
	where
		postlevel = 1 and
		approved = true and
		forumid = _forumid and
		threaddate > _currentthreaddate limit 1;
  end if;

  if _threadid is null then
    _threadid := _currentthreadid;
  end if;  

  for _rec in
  select _threadid as threadid
  loop
	return next _rec;
  end loop;
  return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 315 (OID 28030)
-- Name: forums_getprevnextthreadid (integer, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getprevnextthreadid (integer, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getprevnextthreadid (integer, boolean) TO PUBLIC;


--
-- TOC entry 57 (OID 28032)
-- Name: roledescription; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE roledescription AS (description character varying(512));


--
-- TOC entry 348 (OID 28033)
-- Name: forums_getroledescription (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getroledescription (character varying) RETURNS SETOF roledescription
    AS '
declare
	_rolename alias for $1;
	t_found int;
	_rec roledescription%rowtype;
begin
    select into t_found 1 from userroles where rolename ilike _rolename;
    if found then
        for _rec in
        select description from userroles where rolename ilike _rolename
	loop
		return next _rec;
	end loop;
    else
	for _rec in
	select '''' as description
	loop
		return next _rec;
	end loop; 
    end if;
    return;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 349 (OID 28033)
-- Name: forums_getroledescription (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getroledescription (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getroledescription (character varying) TO PUBLIC;


--
-- TOC entry 58 (OID 28043)
-- Name: summaryinfo; Type: TYPE; Schema: public; Owner: pgadmin
--

CREATE TYPE summaryinfo AS (totalusers integer,
	totalposts integer,
	totaltopics integer,
	daysposts integer,
	daystopics integer);


--
-- TOC entry 318 (OID 28044)
-- Name: forums_getsummaryinfo (); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_getsummaryinfo () RETURNS SETOF summaryinfo
    AS '
	-- get summary information - total users, total posts, totaltopics, daysposts, and daystopics
	
	select
	(select cast(count(*) as int4) from users) as totalusers,
	(select cast(count(*) as int4) from posts) as totalposts,
	(select cast(count(*) as int4) from posts where parentid = postid) as totaltopics,
	(select cast(count(*) as int4) from posts
				where postdate > dateadd(''dd'',-1,current_timestamp(3))) as daysposts,
	(select cast(count(*) as int4) from posts
				where parentid = postid and postdate > dateadd(''dd'',-1,current_timestamp(3))) as daystopics; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 319 (OID 28044)
-- Name: forums_getsummaryinfo (); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_getsummaryinfo () FROM PUBLIC;
GRANT ALL ON FUNCTION forums_getsummaryinfo () TO PUBLIC;


--
-- TOC entry 320 (OID 28045)
-- Name: forums_movepost (integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_movepost (integer, integer, character varying) RETURNS integer
    AS '
declare 
	_postid alias for $1;
	_movetoforumid alias for $2;
	_username alias for $3;
	_currentforum int;
	_approvesetting bool;
	_forumname varchar(100);
	t_found int;
begin
	select into _approvesetting  approved from posts where postid = _postid;
	if _approvesetting = false then
		-- ok, so we''re dealing with a post that is being moved via moderation
		-- does the user moving this have rights to moderate in the new forum? (or is the forum unmoderated?
		select into t_found 1 from moderators where (forumid = _movetoforumid or forumid = 0) and username ilike _username;
		if found or (select moderated from forums where forumid = _movetoforumid) = false then
			-- this user has rights, so we''ll want to automagically approve the post in the new forum
			_approvesetting := 1;
		end if;
	end if;
		
	-- only allow top-level messages to be moved
	if (select parentid from posts where postid = _postid) <> _postid then
		return 0;
	else
		-- get the forum we are moving from
		select into _currentforum  forumid
		from
			posts
		where
			postid = _postid;	
		-- update the post with a new forum id
		update 
			posts
		set 
			forumid = _movetoforumid,
			approved = _approvesetting
		where 
			threadid = (select threadid from posts where postid = _postid);
		-- update the forum statistics for the from forum
		perform statistics_resetforumstatistics(_currentforum);
		-- update the forum statistics for the to forum
		perform statistics_resetforumstatistics(_movetoforumid);
		-- record to our moderation audit log
		insert into
			moderationaudit
		values
			(current_timestamp(3), _postid, _username, 3, null);
		if _approvesetting = false then
			-- the post was moved but not approved
			return 1;
		else
			-- the post was moved and approved
			return 2; 
		end if;
	end if;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 321 (OID 28045)
-- Name: forums_movepost (integer, integer, character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_movepost (integer, integer, character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_movepost (integer, integer, character varying) TO PUBLIC;


--
-- TOC entry 322 (OID 28047)
-- Name: forums_userhaspostsawaitingmoderation (character varying); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_userhaspostsawaitingmoderation (character varying) RETURNS boolean
    AS '
declare
	_username alias for $1;
	t_found int;
begin
	-- can the user moderate all forums?
	select into t_found  1 from moderators where username ilike _username and forumid=0;
	if found then
		-- return all posts awaiting moderation
		select into t_found 1 from posts p inner join forums f on f.forumid = p.forumid where approved = false limit 1;
		if found then
		  return true;
		else
		  return false;
		end if;
	else
		-- return only those posts in the forum this user can moderate
		select into t_found 1 from posts p inner join forums f on f.forumid = p.forumid where approved = false and p.forumid in (select forumid from moderators where username ilike _username) limit 1;
		if found then
		  return true;
		else
		  return false;
		end if;
	end if;
end '
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 323 (OID 28047)
-- Name: forums_userhaspostsawaitingmoderation (character varying); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_userhaspostsawaitingmoderation (character varying) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_userhaspostsawaitingmoderation (character varying) TO PUBLIC;


--
-- TOC entry 328 (OID 28073)
-- Name: forums_isduplicatepost (character varying, text); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_isduplicatepost (character varying, text) RETURNS integer
    AS '
	select cast(count(*) as int4)
	from posts 
	where username ilike $1 and body ilike $2; '
    LANGUAGE sql SECURITY DEFINER;


--
-- TOC entry 329 (OID 28073)
-- Name: forums_isduplicatepost (character varying, text); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_isduplicatepost (character varying, text) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_isduplicatepost (character varying, text) TO PUBLIC;


--
-- TOC entry 330 (OID 28089)
-- Name: forums_updateuserinfo (character varying, character varying, character varying, character varying, character varying, integer, boolean, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, boolean, boolean, character varying, boolean); Type: FUNCTION; Schema: public; Owner: pgadmin
--

CREATE FUNCTION forums_updateuserinfo (character varying, character varying, character varying, character varying, character varying, integer, boolean, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, boolean, boolean, character varying, boolean) RETURNS integer
    AS '
declare
	_username alias for $1;
	_email alias for $2;
	_fakeemail alias for $3;
	_url alias for $4;
	_signature alias for $5;
	_forumview alias for $6;
	_threadtracking alias for $7;
	_timezone alias for $8;
	_password alias for $9;
	_occupation alias for $10;
	_location alias for $11;
	_interests alias for $12;
	_msnim alias for $13;
	_aolim alias for $14;
	_yahooim alias for $15;
	_icqim alias for $16;
	_showunreadtopicsonly alias for $17;
	_sitestyle alias for $18;
	_avatartype alias for $19;
	_hasavatar alias for $20;
	_showavatar alias for $21;
	_dateformat alias for $22;
	_postvieworder alias for $23;
	t_found int;
begin
	-- update the user''s info only if we have a valid password
	select into t_found 1 from users where username ilike _username and password = _password;
	if found then
		
		-- ok, we have a valid user
		update 
			users set
			email = _email,
			fakeemail = _fakeemail,
			url = _url,
			signature = _signature,
			forumview = _forumview,
			trackyourposts = _threadtracking,
			timezone = _timezone,
                        occupation = _occupation,
			location = _location,
			interests = _interests,
			msn = _msnim,
			yahoo = _yahooim,
			aim = _aolim,
			icq = _icqim,
			showunreadtopicsonly = _showunreadtopicsonly,
			approved = true,
			style = _sitestyle,
			avatartype = _avatartype,
			hasavatar = _hasavatar,
			showavatar = _showavatar,
			dateformat = _dateformat,
			postvieworder = _postvieworder
		where 
			username ilike _username and
			password = _password;
		
		return 1;
	else
		-- cripes, the password doesn''t match up!
		return 0; 
	end if;
end'
    LANGUAGE plpgsql SECURITY DEFINER;


--
-- TOC entry 331 (OID 28089)
-- Name: forums_updateuserinfo (character varying, character varying, character varying, character varying, character varying, integer, boolean, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, boolean, boolean, character varying, boolean); Type: ACL; Schema: public; Owner: pgadmin
--

REVOKE ALL ON FUNCTION forums_updateuserinfo (character varying, character varying, character varying, character varying, character varying, integer, boolean, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, boolean, boolean, character varying, boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION forums_updateuserinfo (character varying, character varying, character varying, character varying, character varying, integer, boolean, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, boolean, boolean, character varying, boolean) TO PUBLIC;


--
-- TOC entry 88 (OID 24711)
-- Name: forumgroups_ix_forumgroups_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE UNIQUE INDEX forumgroups_ix_forumgroups_idx ON forumgroups USING btree (name);


--
-- TOC entry 90 (OID 24725)
-- Name: forums_ix_forums_active_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX forums_ix_forums_active_idx ON forums USING btree (active);


--
-- TOC entry 92 (OID 24728)
-- Name: forumsread_ix_forumsreadby-0; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX "forumsread_ix_forumsreadby-0" ON forumsread USING btree (forumid);


--
-- TOC entry 93 (OID 24729)
-- Name: forumsread_ix_forumsreadby-1; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX "forumsread_ix_forumsreadby-1" ON forumsread USING btree (username);


--
-- TOC entry 95 (OID 24785)
-- Name: posts_ix_posts_approved_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_approved_idx ON posts USING btree (approved);


--
-- TOC entry 96 (OID 24786)
-- Name: posts_ix_posts_forumid_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_forumid_idx ON posts USING btree (forumid);


--
-- TOC entry 97 (OID 24787)
-- Name: posts_ix_posts_parentid_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_parentid_idx ON posts USING btree (parentid);


--
-- TOC entry 98 (OID 24788)
-- Name: posts_ix_posts_postlevel_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_postlevel_idx ON posts USING btree (postlevel);


--
-- TOC entry 99 (OID 24789)
-- Name: posts_ix_posts_sortorder_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_sortorder_idx ON posts USING btree (sortorder);


--
-- TOC entry 100 (OID 24790)
-- Name: posts_ix_posts_threadid_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_threadid_idx ON posts USING btree (threadid);


--
-- TOC entry 101 (OID 24791)
-- Name: posts_ix_posts_username_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX posts_ix_posts_username_idx ON posts USING btree (username);


--
-- TOC entry 105 (OID 24794)
-- Name: postsread_ix_postsread_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX postsread_ix_postsread_idx ON postsread USING btree (postid);


--
-- TOC entry 103 (OID 24795)
-- Name: postsread_ix_postsread_1_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX postsread_ix_postsread_1_idx ON postsread USING btree (username);


--
-- TOC entry 104 (OID 24796)
-- Name: postsread_ix_postsread_2_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX postsread_ix_postsread_2_idx ON postsread USING btree (username);


--
-- TOC entry 106 (OID 24800)
-- Name: privateforums_ix_privatefo-0; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX "privateforums_ix_privatefo-0" ON privateforums USING btree (forumid);


--
-- TOC entry 108 (OID 24809)
-- Name: userroles_ix_userroles_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE UNIQUE INDEX userroles_ix_userroles_idx ON userroles USING btree (rolename);


--
-- TOC entry 111 (OID 24818)
-- Name: users_ix_users_uniqueemail_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE UNIQUE INDEX users_ix_users_uniqueemail_idx ON users USING btree (email);


--
-- TOC entry 110 (OID 24819)
-- Name: users_ix_users_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX users_ix_users_idx ON users USING btree (datecreated);


--
-- TOC entry 109 (OID 24820)
-- Name: users_ix_users_1_idx; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX users_ix_users_1_idx ON users USING btree (totalposts);


--
-- TOC entry 113 (OID 24825)
-- Name: usersinroles_ix_usersinrol-0; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX "usersinroles_ix_usersinrol-0" ON usersinroles USING btree (username);


--
-- TOC entry 114 (OID 24826)
-- Name: usersinroles_ix_usersinrol-1; Type: INDEX; Schema: public; Owner: pgadmin
--

CREATE INDEX "usersinroles_ix_usersinrol-1" ON usersinroles USING btree (rolename);


--
-- TOC entry 87 (OID 24692)
-- Name: emails_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (emailid);


--
-- TOC entry 89 (OID 24708)
-- Name: forumgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY forumgroups
    ADD CONSTRAINT forumgroups_pkey PRIMARY KEY (forumgroupid);


--
-- TOC entry 91 (OID 24720)
-- Name: forums_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (forumid);


--
-- TOC entry 94 (OID 24761)
-- Name: moderators_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY moderators
    ADD CONSTRAINT moderators_pkey PRIMARY KEY (username, forumid);


--
-- TOC entry 102 (OID 24780)
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (postid);


--
-- TOC entry 107 (OID 24803)
-- Name: threadtrackings_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY threadtrackings
    ADD CONSTRAINT threadtrackings_pkey PRIMARY KEY (threadid, username);


--
-- TOC entry 112 (OID 24815)
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);


--
-- TOC entry 362 (OID 24829)
-- Name: fk_moderators_users_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY moderators
    ADD CONSTRAINT fk_moderators_users_fk FOREIGN KEY (username) REFERENCES users(username) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 363 (OID 24833)
-- Name: fk_posts_forums_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_posts_forums_fk FOREIGN KEY (forumid) REFERENCES forums(forumid) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 364 (OID 24837)
-- Name: fk_posts_users_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_posts_users_fk FOREIGN KEY (username) REFERENCES users(username) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 365 (OID 24841)
-- Name: fk_privateforums_userroles_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY privateforums
    ADD CONSTRAINT fk_privateforums_userroles_fk FOREIGN KEY (rolename) REFERENCES userroles(rolename) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 366 (OID 24845)
-- Name: fk_threadtrackings_users_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY threadtrackings
    ADD CONSTRAINT fk_threadtrackings_users_fk FOREIGN KEY (username) REFERENCES users(username) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 367 (OID 24849)
-- Name: fk_usersinroles_userroles_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY usersinroles
    ADD CONSTRAINT fk_usersinroles_userroles_fk FOREIGN KEY (rolename) REFERENCES userroles(rolename) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 368 (OID 24853)
-- Name: fk_usersinroles_users_fk; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY usersinroles
    ADD CONSTRAINT fk_usersinroles_users_fk FOREIGN KEY (username) REFERENCES users(username) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 115 (OID 25076)
-- Name: anonymoususers_pkey; Type: CONSTRAINT; Schema: public; Owner: pgadmin
--

ALTER TABLE ONLY anonymoususers
    ADD CONSTRAINT anonymoususers_pkey PRIMARY KEY (userid);



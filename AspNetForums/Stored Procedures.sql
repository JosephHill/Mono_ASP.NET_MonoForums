CREATE or replace function hasreadpost (
	varchar(50), --:username
	int, --:postid
	int --:forumid
) returns bool
as '
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
security definer language plpgsql;
grant execute on function hasreadpost (
	varchar(50), --:username
	int, --:postid
	int --:forumid
) to public;

create or replace function statistics_updateforumstatistics
(
	int, --:forumid
	int, --:threadid
	int --:postid
) returns int 
as '
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
security definer language plpgsql;
grant execute on function statistics_updateforumstatistics
(
	int, --:forumid
	int, --:threadid
	int --:postid
) to public;

create or replace function maintenance_cleanforumsread
(
	int --:forumid
) returns int 
as '
	delete from forumsread
	where
		markreadafter = 0 and
		forumid = $1; 
	SELECT 1;'
security definer language sql;
grant execute on function maintenance_cleanforumsread
(
	int --:forumid
) to public;

create or replace function maintenance_resetforumgroupsforinsert
 () returns int 
as '
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
security definer language plpgsql;
grant execute on function maintenance_resetforumgroupsforinsert
 () to public;

-- DROP TYPE public.posthistory CASCADE;
CREATE TYPE public.posthistory AS (
	moderatedon timestamp,
	moderatedby varchar(50),
	description varchar(256),
	notes varchar(1024)
);
create or replace function moderate_getposthistory(
	int, --:postid
	varchar(50) --:username
) returns setof posthistory
as '
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
security definer language sql;
grant execute on function moderate_getposthistory(
	int, --:postid
	varchar(50) --:username
) to public;

-- DROP TYPE public.uservisitsbyday CASCADE;
CREATE TYPE public.uservisitsbyday AS (
	statdate timestamp,
	usercount int4,
	postcount int4,
	avgpostperuser decimal(5,2),
	postcountaspnetteam int4,
	percentagepostsaspnetteam decimal(5,2)
);
create or replace function reports_uservisitsbyday
(
	int, --:daysback
	bool --:sumdaycount
) returns setof uservisitsbyday
as '
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
		select _usercount cast(count(*) as int4) 
		from users 
		where 
			extract(doy from lastactivity) = extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', lastactivity) = date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3)));
		
		-- users posted in last day
		select _postcount cast(count(*) as int4) 
		from posts 
		where 
			extract(doy from postdate) = extract(doy from dateadd(''dd'', _daysback, current_timestamp(3))) and 
			date_part(''yy'', postdate) = date_part(''yy'', dateadd(''dd'', _daysback, current_timestamp(3)));
			
                -- aspnet team post count
		select _aspnetteampostcount cast(count(*) as int4) 
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
		)
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
return null;
end'
security definer language plpgsql;
grant execute on function reports_uservisitsbyday
(
	int, --:daysback
	bool --:sumdaycount
) to public;

-- DROP TYPE public.foruser CASCADE;
CREATE TYPE public.foruser AS (
	postid int4,
	parentid int4,
	threadid int4,
	postlevel int4,
	sortorder int4,
	username varchar(50),
	subject varchar(256),
	postdate timestamp,
	threaddate timestamp,
	approved bool,
	forumid int4,
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	hasread bool
);
create or replace function search_foruser (
	int, --:pageindex
	int, --:pagesize
	varchar(50), --:usernametosearchfor
	varchar(50) --:username
) returns setof foruser
as '
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
return null;
end '
security definer language plpgsql;
grant execute on function search_foruser (
	int, --:pageindex
	int, --:pagesize
	varchar(50), --:usernametosearchfor
	varchar(50) --:username
) to public;

-- DROP TYPE public.totalmoderationactions CASCADE;
CREATE TYPE public.totalmoderationactions AS (
	description varchar(256),
	totalactions int4
);
create or replace function statistics_getmoderationactions
 () returns setof totalmoderationactions
as '
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
security definer language sql;
grant execute on function statistics_getmoderationactions
 () to public;

-- DROP TYPE public.mostactivemoderators CASCADE;
CREATE TYPE public.mostactivemoderators AS (
	username varchar(50),
	postsmoderated int4
);
create or replace function statistics_getmostactivemoderators
 () returns setof mostactivemoderators
as '
select distinct 
	moderatedby as username, 
	(select cast(count(moderationaction) as int4) from moderationaudit m2 where m2.moderatedby = m.moderatedby) as postsmoderated
from 
	moderationaudit m 
order by 
	postsmoderated desc limit 10; '
security definer language sql;
grant execute on function statistics_getmostactivemoderators
 () to public;

-- DROP TYPE public.mostactiveusers CASCADE;
CREATE TYPE public.mostactiveusers AS (
	username varchar,
	totalposts int
);
create or replace function statistics_getmostactiveusers
 () returns setof mostactiveusers
as '
select 
	username,
	totalposts
from
	users
where
	username not in (select username from usersinroles where rolename = ''aspnetteam'')
order by
	totalposts desc limit 3;'
security definer language sql;
grant execute on function statistics_getmostactiveusers
 () to public;

create or replace function statistics_resetforumstatistics
(
	int --:forumid
) returns int 
as '
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
security definer language plpgsql;
grant execute on function statistics_resetforumstatistics
(
	int --:forumid
) to public;

create or replace function statistics_resettopposters
 () returns int 
as '
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
 		set attributes = (trim(both '' '' from attributes)::text::int8 & x''fffffff3''::int8)
		where username = _rec.username;
		-- top 25 poster
		if (_loopcounter < 26) then
			update users
			set attributes = (trim(both '' '' from attributes)::text::int8 ^ 4)
			where username = _rec.username;
		end if;
		-- top 50 poster
		if (_loopcounter > 25) and (_loopcounter < 51) then
			update users
			set attributes = (trim(both '' '' from attributes)::text::int8 ^ 8)
			where username = _rec.username;
		end if;
		-- top 100 poster
		if (_loopcounter > 50) and (_loopcounter < 101) then
			update users
			set attributes = (trim(both '' '' from attributes)::text::int8 ^ 16)
			where username = _rec.username;
		end if;
		_loopcounter := _loopcounter + 1;
	end loop;
	return null;
end'
security definer language plpgsql;
grant execute on function statistics_resettopposters
 () to public;

create or replace function forums_addforum
(
	varchar(100), --:name
	varchar(3000), --:description
	int, --:forumgroupid
	bool, --:moderated
	int, --:daystoview
	bool --:active
) returns int 
as '
	-- insert a new forum
	insert into forums (forumgroupid, name, description, moderated, daystoview, active)
	values ($3, $1, $2, $4, $5, $6); 
	SELECT 1;'
security definer language sql;
grant execute on function forums_addforum
(
	varchar(100), --:name
	varchar(3000), --:description
	int, --:forumgroupid
	bool, --:moderated
	int, --:daystoview
	bool --:active
) to public;

create or replace function forums_addforumgroup
(
	varchar(256) --:forumgroupname
) returns int 
as '
	-- insert a new forum
	insert into 
		forumgroups 
		(name)
	values 
		($1);
	-- reset the sort order
	select maintenance_resetforumgroupsforinsert(); 
	SELECT 1;'
security definer language sql;
grant execute on function forums_addforumgroup
(
	varchar(256) --:forumgroupname
) to public;

create or replace function forums_addforumtorole
(
	int, --:forumid
	varchar(256) --:rolename
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_addforumtorole
(
	int, --:forumid
	varchar(256) --:rolename
) to public;

create or replace function forums_addmoderatedforumforuser
(
	varchar(50), --:username
	int, --:forumid
	bool --:emailnotification
) returns int 
as '
	-- add a row to the moderators table
	-- if the user wants to add all forums, ahead and delete all of the other forums
	delete from moderators where username ilike $1 and $2 = 0;
	-- now insert the new row into the table
	insert into moderators (username, forumid, emailnotification)
	values ($1, $2, $3); 
	SELECT 1;'
security definer language sql;
grant execute on function forums_addmoderatedforumforuser
(
	varchar(50), --:username
	int, --:forumid
	bool --:emailnotification
) to public;

create or replace function forums_addpost 
(
	int, --:forumid
	int,  --:replytopostid
	varchar(256), --:subject
	varchar(50), --:username
	text, --:body
	bool, --:islocked
	timestamp --:pinned
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_addpost 
(
	int, --:forumid
	int,  --:replytopostid
	varchar(256), --:subject
	varchar(50), --:username
	text, --:body
	bool, --:islocked
	timestamp --:pinned
) to public;

create or replace function forums_addusertorole
(
	varchar(50), --:username
	varchar(256) --:rolename
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_addusertorole
(
	varchar(50), --:username
	varchar(256) --:rolename
) to public;

create or replace function forums_approvemoderatedpost
(
	int, --:postid
	varchar(50), --:approvedby
	varchar(50) --:trusted
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_approvemoderatedpost
(
	int, --:postid
	varchar(50), --:approvedby
	varchar(50) --:trusted
) to public;

create or replace function forums_approvepost
(
	int --:postid
) returns int 
as '
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
		perform statistics_resetforumstatistics _forumid();
		-- send back a success code
		return 1; 
	end if;
end'
security definer language plpgsql;
grant execute on function forums_approvepost
(
	int --:postid
) to public;
 
-- DROP TYPE public.canmoderate CASCADE;
CREATE TYPE public.canmoderate AS (
	canmoderate int4
);
create or replace function forums_canmoderate 
(
	varchar(50) --:username
) returns setof canmoderate
as '
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
	return null;
end'
security definer language plpgsql;
grant execute on function forums_canmoderate 
(
	varchar(50) --:username
) to public;

create or replace function forums_canmoderateforum 
(
	varchar(50), --:username
	int --:forumid
) returns setof canmoderate
as '
declare
	_username alias for $1;
	_forumid alias for $2;
	_rec allforums%ROWTYPE;
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
  return _rec;
end'
security definer language plpgsql;
grant execute on function forums_canmoderateforum 
(
	varchar(50), --:username
	int --:forumid
) to public;

create or replace function forums_changeforumgroupsortorder
(
	int, --:forumgroupid
	bool --:moveup
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_changeforumgroupsortorder
(
	int, --:forumgroupid
	bool --:moveup
) to public;

create or replace function forums_changeuserpassword
(
	varchar(50), --:username
	varchar(50) --:newpassword
) returns int 
as '
update
	users
set
	password = $2
where
	username ilike $1; 
SELECT 1;'
security definer language sql;
grant execute on function forums_changeuserpassword
(
	varchar(50), --:username
	varchar(50) --:newpassword
) to public;

create or replace function forums_checkusercredentials
(
	varchar(50), --:username
	varchar(20) --:password
) returns int4 
as '
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
security definer language plpgsql;
grant execute on function forums_checkusercredentials
(
	varchar(50), --:username
	varchar(20) --:password
) to public;

create or replace function forums_createnewrole
(
	varchar(256), --:rolename
	varchar(512) --:description
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_createnewrole
(
	varchar(256), --:rolename
	varchar(512) --:description
) to public;

create or replace function forums_createnewuser
(
	varchar(50), --:username
	varchar(75), --:email
	varchar(20) --:randompassword
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_createnewuser
(
	varchar(50), --:username
	varchar(75), --:email
	varchar(20) --:randompassword
) to public;

create or replace function forums_deleteforum
(
	int --:forumid
) returns int 
as '
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
security definer language sql;
grant execute on function forums_deleteforum
(
	int --:forumid
) to public;

create or replace function forums_deletemoderatedpost
(
	int, --:postid
	varchar(50), --:approvedby
	varchar(1024) --:reason
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_deletemoderatedpost
(
	int, --:postid
	varchar(50), --:approvedby
	varchar(1024) --:reason
) to public;

create or replace function forums_deletepost
(
	int --:postid
) returns int 
as '
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
		preform statistics_resetforumstatistics(_forumid);
	else
		-- we must recursively delete this post and all of its children
		preform forums_deletepostandchildren(_postid); 
	end if;
	return null;
end'
security definer language plpgsql;
grant execute on function forums_deletepost
(
	int --:postid
) to public;

create or replace function forums_deletepostandchildren
(
	int --:postid
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_deletepostandchildren
(
	int --:postid
) to public;

create or replace function forums_deleterole
(
	varchar(256) --:rolename
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_deleterole
(
	varchar(256) --:rolename
) to public;

-- DROP TYPE public.findusersbyname CASCADE;
CREATE TYPE public.findusersbyname AS (
	username varchar(50),
	password varchar(50),
	email varchar(75),
	forumview int4,
	approved bool,
        profileapproved bool,
	trusted bool,
	fakeemail varchar(75),
	url varchar(100),
	signature varchar(256),
	datecreated timestamp,
	trackyourposts bool,
	lastlogin timestamp,
	lastactivity timestamp,
	timezone int4,
	location varchar(100),
	occupation varchar(100),
	interests varchar(100),
	msn varchar(50),
	yahoo varchar(50),
	aim varchar(50),
	icq varchar(50),
	totalposts int4,
	hasavatar bool,
	showunreadtopicsonly bool,
	style varchar(20),
	avatartype int4,
	avatarurl varchar(256),
	showavatar bool,
	dateformat varchar(10),
	postvieworder bool,
	ismoderator bool,
	flatview bool,
	attributes char(4)
);
create or replace function forums_findusersbyname
(
	int, --:pageindex
	int, --:pagesize
	varchar(50) --:usernametofind
) returns setof findusersbyname
as '
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
	displayinmemberlist = 1 and
	username ilike ''%'' + _usernametofind + ''%''
    order by 
	datecreated
    offset _pagelowerbound
    limit _pagesize
    loop
	return next _rec;
    end loop;
    return null; 
end'
security definer language plpgsql;
grant execute on function forums_findusersbyname
(
	int, --:pageindex
	int, --:pagesize
	varchar(50) --:usernametofind
) to public;

create or replace function forums_getallbutoneforum
(
	int --:postid
) returns setof forums
as '
	-- get all of the forums except for the forum that postid exists in
	select
		*
	from forums 
	where not (forumid = (select forumid from posts where postid = $1)) and active = true; '
security definer language sql;
grant execute on function forums_getallbutoneforum
(
	int --:postid
) to public;

create or replace function forums_getallforumgroups
(
	bool, --:getallforumsgroups	
	varchar(50) --:username
) returns setof forumgroups
as '
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
			where
				forumgroups.forumgroupid = forums.forumgroupid and
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
			return null;
				
		else
			SELECT 1 INTO t_found
			from
				forums
			where
				forumgroups.forumgroupid = forums.forumgroupid and
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
			return null;
		end if;
	else
		for _rec in 
			select 
				*
			from
				forumgroups loop
			return next _rec;
			end loop;
		return null;
	end if;
end'
security definer language plpgsql;
grant execute on function forums_getallforumgroups
(
	bool, --:getallforumsgroups
	varchar(50) --:username
) to public;

create or replace function forums_getallforumgroupsformoderation
(
	varchar(50) --:username
) returns setof forumgroups 
as '
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
  return null;
end '
security definer language plpgsql;
grant execute on function forums_getallforumgroupsformoderation
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.allforums CASCADE;
CREATE TYPE public.allforums AS
(	forumid int4,
	forumgroupid int4,
	parentid int4,
	name varchar(100),
	description varchar(3000),
	datecreated timestamp,
	daystoview int4,
	moderated bool,
	totalposts int4,
	totaltopics int4,
	mostrecentpostid int4,
	mostrecentthreadid int4,
	mostrecentpostdate timestamp,
	mostrecentpostauthor varchar(50),
	active bool,
	lastuseractivity timestamp,
	sortorder int4,
	isprivate boolean,
	displaymask char(64)
);
create or replace function forums_getallforums
(
	bool, --:getallforums	
	varchar(50) --:username
) returns setof allforums
as '
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
			return null;
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
			return null;
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
			return null;
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
			return null;
		end if;
	end if;
end'
security definer language plpgsql;
grant execute on function forums_getallforums
(
	bool, --:getallforums	
	varchar(50) --:username
) to public;

-- DROP TYPE public.allforumsbyforumgroupid CASCADE;
CREATE TYPE public.allforumsbyforumgroupid AS (
	forumid int4,
	forumgroupid int4,
	name varchar(50),
	description varchar(3000),
	datecreated timestamp,
	daystoview int4,
	moderated bool,
	totalposts int4,
	totaltopics int4,
	mostrecentpostid int4,
	mostrecentpostdate timestamp,
	mostrecentpostauthor varchar(50),
	active bool,
	sortorder int4
);
create or replace function forums_getallforumsbyforumgroupid
(
	int, --:forumgroupid
	bool --:getallforums	
	
) returns setof allforumsbyforumgroupid
as '
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
security definer language plpgsql;
grant execute on function forums_getallforumsbyforumgroupid
(
	int, --:forumgroupid
	bool --:getallforums	
) to public;

-- DROP TYPE public.allmessages CASCADE;
CREATE TYPE public.allmessages AS (
	subject varchar(256),
	postid int4,
	forumid int4,
	threadid int4,
	parentid int4,
	postlevel int4,
	sortorder int4,
	approved bool,
	postdate timestamp,
	threaddate timestamp,	
	username varchar(50),
	replies int4,
	body text,
	totalmessagesinthread int4, -- not used
	totalviews int4,
	islocked bool
);
create or replace function forums_getallmessages
(
	int, --:forumid
	int, --:viewtype
	int --:pagesback
) returns setof allmessages
as '
-- the returned recordset depends on the viewtype option chosen
--	0 == flat display
--	1 == mixed display (just top-level posts)
--	2 == threaded display
declare 
	_forumid alias $1;
	_viewtype alias $2;
	_pagesback alias $3;
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
  return null;
end '
security definer language plpgsql;
grant execute on function forums_getallmessages
(
	int, --:forumid
	int, --:viewtype
	int --:pagesback
) to public;

-- DROP TYPE public.roles CASCADE;
CREATE TYPE public.roles AS (
	rolename varchar(256)
);
create or replace function forums_getallroles
 () returns setof roles
as '
    select 
        rolename 
    from 
        userroles; '
security definer language sql;
grant execute on function forums_getallroles
 () to public;

-- DROP TYPE public.alltopicspaged CASCADE;
CREATE TYPE public.alltopicspaged AS (
	subject varchar(256),
	body text,
	postid int4,
	threadid int4,
	parentid int4,
	postdate timestamp,
	threaddate timestamp,
	pinneddate timestamp,
	username varchar(50),
	replies int4,
	totalviews int4,
	islocked bool,
	ispinned bool,
	hasread bool,
	mostrecentpostauthor varchar(50),
	mostrecentpostid int4
);
create or replace function forums_getalltopicspaged
(
	int, --:forumid
	int, --:pagesize
	int,  --:pageindex
	timestamp,    -- filter returned records by date  --:datefilter
	varchar (50), --:username
	bool    -- 0 all / 1 unread only --:unreadtopicsonly
) returns setof alltopicspaged
as '
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
		(select max(postdate) from posts where threadid = threadid) as postdate,
		threaddate,
		pinneddate,
		username,
		(select cast(count(*) as int4) from posts where threadid = threadid and postlevel != 1 and approved = true) as replies,
		totalviews,
		islocked,
		ispinned,
		false as hasread,
		(select username from posts where threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
		(select postid from posts where threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
	from 
		posts
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
   			(select max(postdate) from posts where threadid = threadid) as postdate,
			threaddate,
			pinneddate,
			username,
			(select cast(count(*) as int4) from posts where threadid = threadid and approved = true and postlevel != 1) as replies,
			totalviews,
			islocked,
			ispinned,
			(select hasreadpost(_username, postid, forumid)) as hasread,
			(select username from posts where threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
			(select postid from posts where threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
		from 
			posts
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
			(select max(postdate) from posts where threadid = threadid) as postdate,
			threaddate,
			pinneddate,
			username,
			(select cast(count(*) as int4) from posts where threadid = threadid and approved = true and postlevel != 1) as replies,
			totalviews,
			islocked,
			ispinned,
			(select hasreadpost(_username, postid, forumid)) as hasread,
			(select username from posts where threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostauthor,
			(select postid from posts where threadid = threadid and approved = true order by postdate desc limit 1) as mostrecentpostid
		from 
			posts
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
    return null;
end'
security definer language plpgsql;
grant execute on function forums_getalltopicspaged
(
	int, --:forumid
	int, --:pagesize
	int,  --:pageindex
	timestamp,    -- filter returned records by date  --:datefilter
	varchar (50), --:username
	bool    -- 0 all / 1 unread only --:unreadtopicsonly
) to public;

-- DROP TYPE public.allunmoderatedtopicspaged CASCADE;
CREATE TYPE public.allunmoderatedtopicspaged AS (
	subject varchar(256),
	postid int4,
	threadid int4,
	parentid int4,
	postdate timestamp,
	threaddate timestamp,
	pinneddate timestamp,
	username varchar(50),
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	ispinned bool,
	hasread bool,
	mostrecentpostauthor varchar(50),
	mostrecentpostid int4
);
create or replace function forums_getallunmoderatedtopicspaged
(
	int, --:forumid
	int, --:pagesize
	int,  --:pageindex
	varchar (50) --:username
) returns setof allunmoderatedtopicspaged
as '
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
        return null;
end '
security definer language plpgsql;
grant execute on function forums_getallunmoderatedtopicspaged
(
	int, --:forumid
	int, --:pagesize
	int,  --:pageindex
	varchar (50) --:username
) to public;

-- DROP TYPE public.allusers CASCADE;
CREATE TYPE public.allusers AS (
	username varchar(50),
	password varchar(50),
	email varchar(75),
	forumview int4,
	approved bool,
        profileapproved bool,
	trusted bool,
	fakeemail varchar(75),
	url varchar(100),
	signature varchar(256),
	datecreated timestamp,
	trackyourposts bool,
	lastlogin timestamp,
	lastactivity timestamp,
	timezone int4,
	location varchar(100),
	occupation varchar(100),
	interests varchar(100),
	msn varchar(50),
	yahoo varchar(50),
	aim varchar(50),
	icq varchar(50),
	totalposts int4,
	hasavatar bool,
	showunreadtopicsonly bool,
	style varchar(20),
	avatartype int4,
	showavatar bool,
	dateformat varchar(10),
	postvieworder bool,
	flatview bool,
	ismoderator bool,
	avatarurl varchar(256),
	attributes char(4)
);
create or replace function forums_getallusers
(
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	bool, --:sortorder
	varchar(1) --:usernamebeginswith
) returns setof allusers
as '
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
		(select cast(count(*) as int4) > 0 from moderators where username ilike u.username) as ismoderator,
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
		(select cast(count(*) as int4) > 0 from moderators where username = u.username) as ismoderator,
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
		(select cast(count(*) as int4) > 0 from moderators where username = u.username) as ismoderator,
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
		(select cast(count(*) as int4) > 0 from moderators where username = u.username) as ismoderator,
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
return null;
end'
security definer language plpgsql;
grant execute on function forums_getallusers
(
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	bool, --:sortorder
	varchar(1) --:usernamebeginswith
) to public;

-- DROP TYPE public.anonymoususersonline CASCADE;
CREATE TYPE public.anonymoususersonline AS
(
	anonymoususercount int4
);
create or replace function forums_getanonymoususersonline
 () returns setof anonymoususersonline
as '
	select cast(count(*) as int4) from anonymoususers as anonymoususercount; '
security definer language sql;
grant execute on function forums_getanonymoususersonline
 () to public;

-- DROP TYPE public.bannedusers CASCADE;
CREATE TYPE public.bannedusers AS (
	username varchar(50),
	email varchar(75),
	datecreated timestamp
);
create or replace function forums_getbannedusers
 () returns setof bannedusers
as '
	-- return all of the banned users
	select
		username,
		email,
		datecreated
	from users
	where approved = false
	order by username; '
security definer language sql;
grant execute on function forums_getbannedusers
 () to public;

create or replace function forums_getemailinfo
(
	int --:emailid
) returns setof emails
as '
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
security definer language sql;
grant execute on function forums_getemailinfo
(
	int --:emailid
) to public;

create or replace function forums_getemaillist
 () returns setof emails
as '
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
security definer language sql;
grant execute on function forums_getemaillist
 () to public;

-- DROP TYPE public.forumbypostid CASCADE;
CREATE TYPE public.forumbypostid AS (
	forumid int4,
	forumgroupid int4,
	parentid int4,
	name varchar(100),
	description varchar(3000),
	datecreated timestamp,
	moderated bool,
	daystoview int4,
	active bool,
	sortorder int4,
	isprivate bool,
	displaymask char(64)
);
create or replace function forums_getforumbypostid
(
	int --:postid
) returns setof forumbypostid
as '
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
security definer language sql;
grant execute on function forums_getforumbypostid
(
	int --:postid
) to public;

-- DROP TYPE public.forumbythreadid CASCADE;
CREATE TYPE public.forumbythreadid AS (
	forumid int4,
	forumgroupid int4,
	name varchar(100),
	description varchar(3000),
	datecreated timestamp,
	moderated bool,
	daystoview int4,
	active bool,
	sortorder int4,
	isprivate bool
);
create or replace function forums_getforumbythreadid
(
	int --:threadid
) returns setof forumbythreadid
as '
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
security definer language sql;
grant execute on function forums_getforumbythreadid
(
	int --:threadid
) to public;

create or replace function forums_getforumgroupbyforumid
(
	int --:forumid
) returns setof forumgroups
as '
	select 
		forumgroups.forumgroupid,
		forumgroups.name,
		forumgroups.sortorder
	from
		forumgroups, forums
	where
		forums.forumgroupid = forumgroups.forumgroupid and
		forums.forumid = $1; '
security definer language sql;
grant execute on function forums_getforumgroupbyforumid
(
	int --:forumid
) to public;

-- DROP TYPE public.forumgroupnamebyid CASCADE;
CREATE TYPE public.forumgroupnamebyid AS (
	name varchar(256),
	sortorder int4
);
create or replace function forums_getforumgroupnamebyid
(
	int --:forumid
) returns setof forumgroupnamebyid
as '
	select 
		forumgroups.name,
		forumgroups.sortorder
	from
		forumgroups, forums
	where
		forums.forumgroupid = forumgroups.forumgroupid and
		forums.forumid = $1; '
security definer language sql;
grant execute on function forums_getforumgroupnamebyid
(
	int --:forumid
) to public;
-- DROP TYPE public.foruminfo CASCADE;
CREATE TYPE public.foruminfo AS (
	forumid int4,
	forumgroupid int4,
	parentid int4,
	name varchar(100),
	description varchar(3000),
	moderated bool,
	daystoview int4,
	datecreated timestamp,
	active bool,
	totaltopics int4,
	sortorder int4,
	isprivate bool,
	displaymask char(64)
);

create or replace function forums_getforuminfo
(
	int, --:forumid
	varchar(50) --:username
) returns setof foruminfo
as '
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
	return null;
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
	return null;
  end if;
end'
security definer language plpgsql;
grant execute on function forums_getforuminfo
(
	int, --:forumid
	varchar(50) --:username
) to public;

create or replace function forums_getforummessagetemplatelist

 () returns setof messages
as '
select 
	messageid,
	title,
	body
from
	messages; '
security definer language sql;
grant execute on function forums_getforummessagetemplatelist

 () to public;

-- DROP TYPE public.forummoderators CASCADE;
CREATE TYPE public.forummoderators AS (
	username varchar(50), 
	emailnotification bool, 
	datecreated timestamp
);
create or replace function forums_getforummoderators
(
	int --:forumid
) returns setof forummoderators
as '
	-- get a list of forum moderators
	select 
		username, 
		emailnotification, 
		datecreated
	from 
		moderators
	where 
		forumid = $1 or forumid = 0; '
security definer language sql;
grant execute on function forums_getforummoderators
(
	int --:forumid
) to public;

-- DROP TYPE public.forumviewbyusername CASCADE;
CREATE TYPE public.forumviewbyusername AS (
	forumview int4
);
create or replace function forums_getforumviewbyusername
(
	varchar(50) --:username
) returns setof forumviewbyusername
as '
	-- get the forumview for the user
	select
		forumview
	from users
	where username ilike $1; '
security definer language sql;
grant execute on function forums_getforumviewbyusername
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.forumsbyforumgroupid CASCADE;
CREATE TYPE public.forumsbyforumgroupid AS (
	forumid int4,
	forumgroupid int4,
	parentid int4,
	name varchar(100),
	description varchar(3000),
	datecreated timestamp,
	daystoview int4,
	moderated bool,
	totalposts int4,
	totaltopics int4,
	mostrecentpostid int4,
	mostrecentthreadid int4,
	mostrecentpostdate timestamp,
	mostrecentpostauthor varchar(50),
	active bool,
	lastuseractivity timestamp,
	sortorder int4,
	isprivate bool,
	displaymask char(64)
);
create or replace function forums_getforumsbyforumgroupid
(
	int, --:forumgroupid
	int, --:getallforums	
	varchar(50) --:username
	
) returns setof forumsbyforumgroupid
as '
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
				true active,
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
	return null;
end'
security definer language plpgsql;
grant execute on function forums_getforumsbyforumgroupid
(
	int, --:forumgroupid
	int, --:getallforums	
	varchar(50) --:username
	
) to public;


-- DROP TYPE public.forumsformoderationbyforumgroupid CASCADE;
CREATE TYPE public.forumsformoderationbyforumgroupid AS (
	forumid int4,
	forumgroupid int4,
	name varchar(100),
	description varchar(3000),
	datecreated timestamp,
	daystoview int4,
	moderated bool,
	totalposts int4,
	totaltopics int4,
	mostrecentpostid int4,
	mostrecentthreadid int4,
	mostrecentpostdate timestamp,
	mostrecentpostauthor varchar(50),
	totalpostsawaitingmoderation int4,
	active bool,
	lastuseractivity timestamp,
	sortorder int4,
	isprivate bool
);
create or replace function forums_getforumsformoderationbyforumgroupid
(
	int, --:forumgroupid
	varchar(50) --:username
	
) returns setof forumsformoderationbyforumgroupid
as '
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
  return null;
end'
security definer language plpgsql;
grant execute on function forums_getforumsformoderationbyforumgroupid
(
	int, --:forumgroupid
	varchar(50) --:username
	
) to public;

-- DROP TYPE public.forumsmoderatedbyuser CASCADE;
CREATE TYPE public.forumsmoderatedbyuser AS (
	forumid int4,
	emailnotification bool,
	forumname varchar(100),
	datecreated timestamp
);
create or replace function forums_getforumsmoderatedbyuser
(
	varchar(50) --:username
) returns setof forumsmoderatedbyuser
as '
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
	return null;
end '
security definer language plpgsql;
grant execute on function forums_getforumsmoderatedbyuser
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.forumsnotmoderatedbyuser CASCADE;
CREATE TYPE public.forumsnotmoderatedbyuser AS (
	forumid int,
	forumname varchar(100)
);	
create or replace function forums_getforumsnotmoderatedbyuser
(
	varchar(50) --:username
) returns setof forumsnotmoderatedbyuser
as '
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
	return null;
end'
security definer language plpgsql;
grant execute on function forums_getforumsnotmoderatedbyuser
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.message CASCADE;
CREATE TYPE public.message AS (
	title varchar(250),
	body varchar(3000)
);
create or replace function forums_getmessage
(
	int --:messageid
) returns setof message
as '
	select
		title,
		body
	from
		messages
	where
		messageid = $1; '
security definer language sql;
grant execute on function forums_getmessage
(
	int --:messageid
) to public;

-- DROP TYPE public.moderatedforums CASCADE;
CREATE TYPE public.moderatedforums AS (
	forumid int4,
	forumgroupid int4,
	name varchar(100),
	description varchar(3000),
	datecreated timestamp,
	moderated bool,
	daystoview int4,
	active bool,
	sortorder int4
);
create or replace function forums_getmoderatedforums
(
	varchar(50) --:username
) returns setof moderatedforums
as '
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
security definer language plpgsql;
grant execute on function forums_getmoderatedforums
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.moderatedposts CASCADE;
CREATE TYPE public.moderatedposts AS (
	postid int4,
	threadid int4,
	threaddate timestamp,
	postlevel int4,
	sortorder int4,
	parentid int4,
	subject varchar(256),
	approved bool,
	forumid int4,
	forumname varchar(100),
	postdate timestamp,
	username varchar(50),
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	hasread bool
);
create or replace function forums_getmoderatedposts
(
	varchar(50) --:username
) returns setof moderatedposts
as '
declare
	_username alias for $1;
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
	return null;
end'
security definer language plpgsql;
grant execute on function forums_getmoderatedposts
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.moderatorsforemailnotification CASCADE;
CREATE TYPE public.moderatorsforemailnotification AS (
	username varchar(50),
	email varchar(75)
);
create or replace function forums_getmoderatorsforemailnotification
(
	int --:postid
) returns setof moderatorsforemailnotification
as '
	select
		u.username,
		email
	from users u
		inner join moderators m on
			m.username = u.username
	where (m.forumid = (select forumid from posts where postid = $1) or m.forumid = 0) and m.emailnotification = true; '
security definer language sql;
grant execute on function forums_getmoderatorsforemailnotification
(
	int --:postid
) to public;

create or replace function forums_getnextpostid
(
	int, --:threadid
	int, --:sortorder
	int  --, --:forumid
	--int output --:nextpostid
) returns int 
as '
select (coalesce((select 	postid
		  from 		posts 
		  where 	threadid = $1 and 
				forumid = $3 and 
				sortorder = $2+1 and 
				approved = true limit 1), 0));'
security definer language sql;
grant execute on function forums_getnextpostid
(
	int, --:threadid
	int, --:sortorder
	int --, --:forumid
	--int output --:nextpostid
) to public;

create or replace function forums_getnextthreadid
(
	int, --:threadid
	int--, --:forumid
) returns int 
as '
select	(coalesce((select threadid
		from 	posts
		where 	threadid > $1 and 
			forumid = $2 and 
			approved = true limit 1), 0));'
security definer language sql;
grant execute on function forums_getnextthreadid
(
	int, --:threadid
	int--, --:forumid
	--int output --:nextthreadid
) to public;
 
-- DROP TYPE public.parentid CASCADE;
CREATE TYPE public.parentid AS (
	parentid int4
);
create or replace function forums_getparentid
(
	int --:postid
) returns setof parentid
as '
	select parentid
	from posts
	where postid = $1; '
security definer language sql;
grant execute on function forums_getparentid
(
	int --:postid
) to public;

-- DROP TYPE public.postinfo CASCADE;
CREATE TYPE public.postinfo AS (
	subject varchar(256),
	postid int4,
	username varchar(50),
	forumid int4,
	forumname varchar(100),
	parentid int4,
	threadid int4,
	approved bool,
	postdate timestamp,
	postlevel int,
	sortorder int,
	threaddate timestamp,
	replies int4,
	body text,
	totalmessagesinthread int4, -- not used
	totalviews int4,
	islocked bool,
	hasread bool
);
create or replace function forums_getpostinfo
(
	int, --:postid
	bool, --:trackviews
	varchar (50) --:username
) returns setof postinfo
as '
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
	return null;
end'
security definer language plpgsql;
grant execute on function forums_getpostinfo
(
	int, --:postid
	bool, --:trackviews
	varchar (50) --:username
) to public;

-- DROP TYPE public.postread CASCADE;
CREATE TYPE public.postread AS (
	hasread bool
);
create or replace function forums_getpostread
(
	int, --:postid
	varchar (50) --:username
) returns setof postread
as '
declare 
	_postid alias for $1;
	_username alias for $2;
	_hasread bool;
	t_found int;
	_rec hasread%ROWTYPE;
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
	return null;
end '
security definer language plpgsql;
grant execute on function forums_getpostread
(
	int, --:postid
	varchar (50) --:username
) to public;

-- DROP TYPE public.prevnextthreadid CASCADE;
CREATE TYPE public.prevnextthreadid AS (
	threadid int4
);
create or replace function forums_getprevnextthreadid (
	int, --:postid
	bool --:nextthread
) returns setof prevnextthreadid
as '
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

  if _nextthread = 1 then
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

  for _rec in
  select isnull(_threadid, _currentthreadid) as threadid
  loop
	return next _rec;
  end loop;
  return null;
end '
security definer language plpgsql;
grant execute on function forums_getprevnextthreadid (
	int, --:postid
	bool --:nextthread
) to public;

create or replace function forums_getprevpostid
(
	int, --:threadid
	int, --:sortorder
	int --, --:forumid
	--int output --:prevpostid
) returns int4 
as '
select  (coalesce((select postid
		   from	  posts
		   where  threadid = $1 and 
			  forumid = $3 and 
			  sortorder = $2-1 and 
			  approved = true limit 1), 0)); '
security definer language sql;
grant execute on function forums_getprevpostid
(
	int, --:threadid
	int, --:sortorder
	int--, --:forumid
	--int output --:prevpostid
) to public;

create or replace function forums_getprevthreadid
(
	int, --:threadid
	int--, --:forumid
	--int output --:prevthreadid
) returns int 
as '
select  (coalesce((select 	threadid
		   from 	posts
		   where 	threadid < $1 and 
			        forumid = $2 and 
				approved = true 
		   order by 	threadid desc limit 1), 0)); '
security definer language sql;
grant execute on function forums_getprevthreadid
(
	int, --:threadid
	int--, --:forumid
	--int output --:prevthreadid
) to public;

-- DROP TYPE public.roledescription CASCADE;
CREATE TYPE public.roledescription AS (
	description varchar(512)
);
create or replace function forums_getroledescription
(
	varchar(256) --:rolename
) returns setof roledescription
as '
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
    return null;
end '
security definer language plpgsql;
grant execute on function forums_getroledescription
(
	varchar(256) --:rolename
) to public;

create or replace function forums_getrolesbyforum
(
	int --:forumid
) returns setof roles
as '
    select 
        rolename
    from 
        privateforums
    where
        forumid = $1; '
security definer language sql;
grant execute on function forums_getrolesbyforum
(
	int --:forumid
) to public;

create or replace function forums_getrolesbyuser
(
	varchar(50) --:username
) returns setof roles
as '
	select 
		rolename 
	from 
		usersinroles
	where
		username ilike $1; '
security definer language sql;
grant execute on function forums_getrolesbyuser
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.searchresults CASCADE;
CREATE TYPE public.searchresults AS (
	postid int4,
	parentid int4,
	threadid int4,
	postlevel int4,
	sortorder int4,
	username varchar(50),
	subject varchar(256),
	postdate timestamp,
	threaddate timestamp,
	approved bool,
	forumid int4,
	forumname varchar(100),
	morerecords int4,
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	hasread bool -- not used
);
create or replace function forums_getsearchresults
(
	varchar(500), --:searchterms
	int, --:page
	int, --:recsperpage
	varchar(50) --:username
) returns setof searchresults
as '
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
	return null;
end'
security definer language plpgsql;
grant execute on function forums_getsearchresults
(
	varchar(500), --:searchterms
	int, --:page
	int, --:recsperpage
	varchar(50) --:username
) to public;
/* TODO deprecated?
create or replace function forums_getsearchresultsbytext (
	int, --:page
	int, --:recsperpage
	int = 0, --:forumid
	bool = 0, --:fulltextsearch
	bool = 1, --:andsearch
	varchar(250), --:pattern1
	varchar(50) = null, --:pattern2
	varchar(50) = null, --:pattern3
	varchar(50) = null, --:pattern4
	varchar(50) = null, --:username
	bool output, --:morerecords
	bool output --:status
) as '
    -- performance optimizations
    
    -- global declarations
    declare _sql varchar(1000)
    declare _firstrec int, _lastrec int, _morerec int
    _firstrec := (_page - 1) * _recsperpage;;
    _lastrec := (_firstrec + _recsperpage);;
    _morerec := _lastrec + 1;;
    _morerecords := 0;;
    
    _status := 0;;
    create table #searchresults (
        indexid int identity(1,1),
        postid int
    )
    -- turn on rowcounting for performance
    set rowcount _morerec;
    if _fulltextsearch = 1 begin
        -- first check to see if full text is enabled on the column.  if it is then do the
        -- search.  else, don''t do the search and set the status bool to 1 for full text error
        if columnproperty(object_id(''posts''), ''body'', ''isfulltextindexed'') = 0 _status := 1;
        else
            exec forums_getsearchsresultsbytext_ftq _pattern1, _forumid, _username
    end
    else begin
        insert into #searchresults(postid)
        select postid
        from posts p
        where
            approved = 1 and
            (
	= -1 or --:forumid
                forumid = _forumid
            ) and
            (
                p.forumid not in (select forumid from privateforums) or
                p.forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))
            ) and
            (
                (
	= 1 and --:andsearch
                    (
                        0 < isnull(patindex(_pattern1, body), 0) and
                        0 < isnull(patindex(_pattern2, body), 1) and
                        0 < isnull(patindex(_pattern3, body), 1) and
                        0 < isnull(patindex(_pattern4, body), 1)
                    ) 
                ) or
                (
	= 0 and --:andsearch
                    (
                        0 < isnull(patindex(_pattern1, body), 0) or
                        0 < isnull(patindex(_pattern2, body), 0) or
                        0 < isnull(patindex(_pattern3, body), 0) or
                        0 < isnull(patindex(_pattern4, body), 0)
                    )
                )
            )
        order by threaddate desc
    end
    if @@rowcount > _lastrec _morerecords := 1;
    set rowcount 0
    -- turn off rowcounting
    -- select the data out of the temporary table
    select
        forums_post.*,
        hasread = 0 -- not used
    from 
        forums_post, #searchresults
    where
        forums_post.postid = #searchresults.postid and
        #searchresults.indexid > _firstrec and
        #searchresults.indexid <= _lastrec
    order by #searchresults.indexid asc; '
security definer language plpgsql;
grant execute on function forums_getsearchresultsbytext (
	int, --:page
	int, --:recsperpage
	int = 0, --:forumid
	bool = 0, --:fulltextsearch
	bool = 1, --:andsearch
	varchar(250), --:pattern1
	varchar(50) = null, --:pattern2
	varchar(50) = null, --:pattern3
	varchar(50) = null, --:pattern4
	varchar(50) = null, --:username
	bool output, --:morerecords
	bool output --:status
) to public;
*//* TODO deprecated?
create or replace function forums_getsearchresultsbytext_ftq (
	varchar(250), --:pattern1
	int, --:forumid
	varchar(50) --:username
) returns setof 
as '
    if @@nestlevel > 1 begin
        insert into #searchresults(postid)
        select postid
        from posts p
        where
            approved = 1 and
            (
	= 0 or --:forumid
                forumid = _forumid
            ) and
            (
                p.forumid not in (select forumid from privateforums) or
                p.forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))
            ) and
            contains(body, _pattern1)
        order by threaddate desc; '
security definer language plpgsql;
grant execute on function forums_getsearchresultsbytext_ftq (
	varchar(250), --:pattern1
	int, --:forumid
	varchar(50) --:username
) to public;
*//* TODO deprecated?
 as '
    -- performance optimizations
    
    -- global declarations
    declare _sql varchar(1000)
    declare _firstrec int, _lastrec int, _morerec int
    _firstrec := (_page - 1) * _recsperpage;;
    _lastrec := (_firstrec + _recsperpage);;
    _morerec := _lastrec + 1;;
    _morerecords := 0;;
    
    _status := 0;;
    create table #searchresults (
        indexid int identity(1,1),
        postid int
    )
    -- turn on rowcounting for performance
    set rowcount _morerec;
    if _fulltextsearch = 1 begin
        -- first check to see if full text is enabled on the column.  if it is then do the
        -- search.  else, don''t do the search and set the status bool to 1 for full text error
        if columnproperty(object_id(''posts''), ''body'', ''isfulltextindexed'') = 0 _status := 1;
        else
            exec forums_getsearchsresultsbytext_ftq _pattern1, _forumid, _username
    end
    else begin
        insert into #searchresults(postid)
        select postid
        from posts p
        where
            approved = 1 and
            (
	= -1 or --:forumid
                forumid = _forumid
            ) and
            (
                p.forumid not in (select forumid from privateforums) or
                p.forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))
            ) and
            (
                (
	= 1 and --:andsearch
                    (
                        0 < isnull(patindex(_pattern1, body), 0) and
                        0 < isnull(patindex(_pattern2, body), 1) and
                        0 < isnull(patindex(_pattern3, body), 1) and
                        0 < isnull(patindex(_pattern4, body), 1)
                    ) 
                ) or
                (
	= 0 and --:andsearch
                    (
                        0 < isnull(patindex(_pattern1, body), 0) or
                        0 < isnull(patindex(_pattern2, body), 0) or
                        0 < isnull(patindex(_pattern3, body), 0) or
                        0 < isnull(patindex(_pattern4, body), 0)
                    )
                )
            )
        order by threaddate desc
    end
    if @@rowcount > _lastrec _morerecords := 1;
    set rowcount 0
    -- turn off rowcounting
    -- select the data out of the temporary table
    select
        forums_post.*,
        hasread = 0 -- not used
    from 
        forums_post, #searchresults
    where
        forums_post.postid = #searchresults.postid and
        #searchresults.indexid > _firstrec and
        #searchresults.indexid <= _lastrec
    order by #searchresults.indexid asc; '
security definer language plpgsql;
grant execute on function forums_getsearchresultsbytext_ftq (
	varchar(250), --:pattern1
	int, --:forumid
	varchar(50) --:username
) to public;
*//* TODO deprecated
create or replace function forums_getsearchresultsbyuser (
	int, --:page
	int, --:recsperpage
	int = 0, --:forumid
	varchar(50), --:userpattern
	varchar(50) = null, --:username
	bool output --:morerecords
) returns setof 
as '
    -- performance optimizations
    
    -- global declarations
    declare _sql varchar(1000)
    declare _firstrec int, _lastrec int, _morerec int
    _firstrec := (_page - 1) * _recsperpage;;
    _lastrec := (_firstrec + _recsperpage);;
    _morerec := _lastrec + 1;;
    _morerecords := 0;;
    create table #searchresults (
        indexid int identity(1,1),
        postid int
    )
    -- turn on rowcounting for performance
    set rowcount _morerec;
    insert into #searchresults(postid)
    select postid
    from posts p
    where
        approved = 1 and
        (
	= 0 or --:forumid
            forumid = _forumid
        ) and
        (
            p.forumid not in (select forumid from privateforums) or
            p.forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))
        ) and
        0 < isnull(patindex(lower(_userpattern), lower(username)), 1)
    order by threaddate desc
    if @@rowcount > _lastrec _morerecords := 1;
    set rowcount 0
    -- turn off rowcounting
    -- select the data out of the temporary table
    select
        p.*,
        hasread = 0 -- not used
    from 
        forums_post p, #searchresults
    where
        forums_post.postid = #searchresults.postid and
        #searchresults.indexid > _firstrec and
        #searchresults.indexid <= _lastrec
    order by #searchresults.indexid asc; '
security definer language plpgsql;
grant execute on function forums_getsearchresultsbyuser (
	int, --:page
	int, --:recsperpage
	int = 0, --:forumid
	varchar(50), --:userpattern
	varchar(50) = null, --:username
	bool output --:morerecords
) to public;
*/
-- DROP TYPE public.singlemessage CASCADE;
CREATE TYPE public.singlemessage AS (
	subject varchar(256),
	forumid int4,
	forumname varchar(100),
	threadid int4,
	parentid int4,
	postlevel int4,
	sortorder int4,
	postdate timestamp,
	threaddate timestamp,
	username varchar(50),
	fakeemail varchar(75),
	url varchar(100),
	signature varchar(256),
	approved bool,
	replies int4,
	prevthreadid int4,
	nextthreadid int4,
	prevpostid int4,
	nextpostid int4,
	useristrackingthread bool,
	body text,
	islocked bool
);
create or replace function forums_getsinglemessage
(
	int, --:postid
	varchar(50) --:username
) returns setof singlemessage
as '
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
return null;
end'
security definer language plpgsql;
grant execute on function forums_getsinglemessage
(
	int, --:postid
	varchar(50) --:username
) to public;

-- DROP TYPE public.statistics CASCADE;
CREATE TYPE public.statistics AS (
	totalusers int4,
	totalposts int4,
	totalmoderators int4,
	totalmoderatedposts int4,
	totaltopics int4,
	daysposts int4, -- todo remove
	daystopics int4, -- todo remove
	newpostsinpast24hours int4,
	newthreadsinpast24hours int4,
	newusersinpast24hours int4,
	mostviewspostid int4,
	mostviewssubject varchar(256),
	mostactivepostid int4,
	mostactivesubject varchar(256),
	mostactiveuser varchar(50),
	mostreadpostid int4,
	mostreadsubject varchar(256),
	newestuser varchar(50)
);
create or replace function forums_getstatistics
 () returns statistics
as '
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
security definer language plpgsql;
grant execute on function forums_getstatistics
 () to public;

-- DROP TYPE public.summaryinfo CASCADE;
CREATE TYPE public.summaryinfo AS (
	totalusers int4,
	totalposts int4,
	totaltopics int4,
	daysposts int4,
	daystopics int4
);
create or replace function forums_getsummaryinfo
 () returns setof summaryinfo
as '
	-- get summary information - total users, total posts, totaltopics, daysposts, and daystopics
	
	select
	(select cast(count(*) as int4) from users) as totalusers,
	(select cast(count(*) as int4) from posts) as totalposts,
	(select cast(count(*) as int4) from posts where parentid = postid) as totaltopics,
	(select cast(count(*) as int4) from posts
				where postdate > dateadd(''dd'',-1,current_timestamp(3))) as daysposts,
	(select cast(count(*) as int4) from posts
				where parentid = postid and postdate > dateadd(''dd'',-1,current_timestamp(3))) as daystopics; '
security definer language sql;
grant execute on function forums_getsummaryinfo
 () to public;
 
-- DROP TYPE public.thread CASCADE;
CREATE TYPE public.thread AS (
	postid int4,
	forumid int4,
	subject varchar(256),
	parentid int4,
	threadid int4,
	postlevel int4,
	sortorder int4,
	postdate timestamp,
	threaddate timestamp,
	username varchar(50),
	approved bool,
	replies int4,
	body text
);
create or replace function forums_getthread
(
	int --:threadid
) returns setof thread
as '
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
security definer language sql;
grant execute on function forums_getthread
(
	int --:threadid
) to public;

-- DROP TYPE public.threadbyparentid CASCADE;
CREATE TYPE public.threadbyparentid AS (
	postid int4,
	threadid int4,
	forumid int4,
	subject varchar(256),
	parentid int4,
	postlevel int4,
	sortorder int4,
	postdate timestamp,
	threaddate timestamp,
	username varchar(50),
	approved bool,
	replies int4,
	body text,
	totalmessagesinthread int4,
	totalviews int4,
	islocked bool
);
create or replace function forums_getthreadbyparentid
(
	int --:parentid
) returns setof threadbyparentid
as '
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
security definer language sql;
grant execute on function forums_getthreadbyparentid
(
	int --:parentid
) to public;

-- DROP TYPE public.threadbypostid CASCADE;
CREATE TYPE public.threadbypostid AS (
	postid int4,
	threadid int4,
	forumid int4,
	forumname varchar(100),
	subject varchar(256),
	parentid int4,
	postlevel int4,
	sortorder int4,
	postdate timestamp,
	threaddate timestamp,
	username varchar(50),
	approved bool,
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	hasread bool
);
create or replace function forums_getthreadbypostid
(
	int, --:postid
	varchar(50) --:username
) returns setof threadbypostid
as '
declare 
	_postid alias for $1;
	_username alias for $2;
	_threadid int;
	_rec threadbypostid%ROWTYPE;
begin
	-- get the thread id of the post
	select into _threadid = threadid from posts where postid = _postid;

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
	return null; 
end'
security definer language plpgsql;
grant execute on function forums_getthreadbypostid
(
	int, --:postid
	varchar(50) --:username
) to public;

-- DROP TYPE public.threadbypostidpaged CASCADE;
CREATE TYPE public.threadbypostidpaged AS (
	postid int4,
	threadid int4,
	forumid int4,
	forumname varchar(100),
	subject varchar(256),
	parentid int4,
	postlevel int4,
	sortorder int4,
	postdate timestamp,
	threaddate timestamp,
	username varchar(50),
	approved bool,
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	totalmessagesinthread int4, -- not used
	hasread bool, -- not used
	posttype int4
);
create or replace function forums_getthreadbypostidpaged
(
	int, --:postid
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	int, --:sortorder
	varchar(50) --:username
) returns setof threadbypostidpaged
as '
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
			return null;
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
	return null;
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
	return null;
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
	return null;
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
	return null;
    end if;
end if;
end '
security definer language plpgsql;
grant execute on function forums_getthreadbypostidpaged
(
	int, --:postid
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	int, --:sortorder
	varchar(50) --:username
) to public;
/* TODO deprecated?
create or replace function forums_getthreadbypostidpaged2
(
	int, --:postid
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	bool, --:sortorder
	varchar(50) --:username
) returns setof 
as '
declare _pagelowerbound int
declare _pageupperbound int
declare _threadid int
declare _forumid int
declare _privateforumid int
declare _isprivateforum bool
declare _isuserapprovedforprivateforum bool
-- get the forumid, the privateforumid, and the threadid
select _forumid = forumid, _threadid = threadid from posts where postid = _postid
select _privateforumid = forumid from privateforums where forumid = _forumid
-- is this a private forum?
if _privateforumid is not null
  begin
    -- this is a private forum
    _isprivateforum := 1;
    -- does the user have access to this forum?
    if (_username is not null)
      begin
        if exists(select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username))
          _isuserapprovedforprivateforum := 1;
        else
          _isuserapprovedforprivateforum := 0;
      end
    else
      _isuserapprovedforprivateforum := 0;
  end
else
  _isprivateforum := 0;
-- let''s return here if the user is not allowed
if _isprivateforum = 1 and _isuserapprovedforprivateforum = 0
  return
-- set the page bounds
_pagelowerbound := _pagesize * _pageindex;
_pageupperbound := _pagelowerbound + _pagesize + 1;
-- create a temp table to store the select results
create table #pageindex 
(
	indexid int identity (1, 1) not null,
	postid int
)
-- sort by post date
if _sortby = 0 and _sortorder = 0
    insert into #pageindex (postid)
    select postid from posts p where approved = 1 and threadid = _threadid order by postdate
else if _sortby = 0 and _sortorder = 1
    insert into #pageindex (postid)
    select postid from posts p where approved = 1 and threadid = _threadid order by postdate desc
-- sort by author
if _sortby = 1 and _sortorder = 0
    insert into #pageindex (postid)
    select postid from posts p where approved = 1 and threadid = _threadid order by username
else if _sortby = 1 and _sortorder = 1
    insert into #pageindex (postid)
    select postid from posts p where approved = 1 and threadid = _threadid order by username desc
select
	p.postid,
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
	totalmessagesinthread = 0, -- not used
	hasread = 0 -- not used
from 
	posts p,
	#pageindex
where 
	p.postid = #pageindex.postid and
	#pageindex.indexid > _pagelowerbound and
	#pageindex.indexid < _pageupperbound; '
security definer language plpgsql;
grant execute on function forums_getthreadbypostidpaged2
(
	int, --:postid
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	bool, --:sortorder
	varchar(50) --:username
) to public;
*//* TODO deprecated?
create or replace function forums_getthreadbypostidpaged_backup
(
	int, --:postid
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	bool, --:sortorder
	varchar(50) --:username
) returns setof 
as '
declare _pagelowerbound int
declare _pageupperbound int
-- set the page bounds
_pagelowerbound := _pagesize * _pageindex;
_pageupperbound := _pagelowerbound + _pagesize + 1;
-- create a temp table to store the select results
create table #pageindex 
(
	indexid int identity (1, 1) not null,
	postid int
)
-- sort by post date
if _sortby = 0 and _sortorder = 0
    insert into #pageindex (postid)
    select postid from posts p where approved=1 and threadid = (select threadid from posts where postid = _postid) and postid >= _postid and parentid >= (select parentid from posts where postid = _postid) and	sortorder >= (select sortorder from posts where postid = _postid) order by postdate
else if _sortby = 0 and _sortorder = 1
    insert into #pageindex (postid)
    select postid from posts p where approved=1 and threadid = (select threadid from posts where postid = _postid) and postid >= _postid and parentid >= (select parentid from posts where postid = _postid) and	sortorder >= (select sortorder from posts where postid = _postid) order by postdate desc
-- sort by author
if _sortby = 1 and _sortorder = 0
    insert into #pageindex (postid)
    select postid from posts p where approved=1 and threadid = (select threadid from posts where postid = _postid) and postid >= _postid and parentid >= (select parentid from posts where postid = _postid) and	sortorder >= (select sortorder from posts where postid = _postid) order by username
else if _sortby = 1 and _sortorder = 1
    insert into #pageindex (postid)
    select postid from posts p where approved=1 and threadid = (select threadid from posts where postid = _postid) and postid >= _postid and parentid >= (select parentid from posts where postid = _postid) and	sortorder >= (select sortorder from posts where postid = _postid) order by username desc
-- get the thread info for this post
if _username is not null
	select
		p.postid,
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
		totalmessagesinthread = 0, -- not used
		hasread = 0 -- not used
	from 
		posts p,
		#pageindex
	where 
		p.postid = #pageindex.postid and
		#pageindex.indexid > _pagelowerbound and
		#pageindex.indexid < _pageupperbound and
		(forumid not in (select forumid from privateforums) or
		forumid in (select forumid from privateforums where rolename in (select rolename from usersinroles where username ilike _username)))
else
	select
		p.postid,
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
		totalmessagesinthread = 0, -- not used
		hasread = 0 -- not used
	from 
		posts p,
		#pageindex
	where 
		p.postid = #pageindex.postid and
		#pageindex.indexid > _pagelowerbound and
		#pageindex.indexid < _pageupperbound and
		forumid not in (select forumid from privateforums); '
security definer language plpgsql;
grant execute on function forums_getthreadbypostidpaged_backup
(
	int, --:postid
	int, --:pageindex
	int, --:pagesize
	int, --:sortby
	bool, --:sortorder
	varchar(50) --:username
) to public;
*/

-- DROP TYPE public.timezone CASCADE;
CREATE TYPE public.timezone AS (
	timezone int4
);
create or replace function forums_gettimezonebyusername
(
	varchar(50) --:username
) returns setof timezone
as '
	-- get this user''s timezone offset
	select timezone
	from users
	where username ilike $1; '
security definer language sql;
grant execute on function forums_gettimezonebyusername
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.top25newposts CASCADE;
CREATE TYPE public.top25newposts AS (
	subject varchar(256),
	postid int4,
	threadid int4,
	parentid int4,
	postdate timestamp,
	threaddate timestamp,
	username varchar(50),
	replies int4,
	body text,
	totalviews int4,
	islocked bool,
	hasread bool,
	mostrecentpostauthor varchar(50),
	mostrecentpostid int4
);
create or replace function forums_gettop25newposts
(
	varchar(50) --:username
) returns setof top25newposts
as '
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
security definer language plpgsql;
grant execute on function forums_gettop25newposts
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.topicsuseristracking CASCADE;
CREATE TYPE public.topicsuseristracking AS (
	subject varchar(256),
	body text,
	postid int4,
	threadid int4,
	parentid int4,
	postdate timestamp,
	threaddate timestamp,
	pinneddate timestamp,
	username varchar(50),
	replies int4,
	totalviews int4,
	islocked bool,
	ispinned bool,
	hasread bool,
	mostrecentpostauthor varchar(50),
	mostrecentpostid int4
);
create or replace function forums_gettopicsuseristracking
(
	varchar(50) --:username
) returns setof topicsuseristracking
as '
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
security definer language sql;
grant execute on function forums_gettopicsuseristracking
(
	varchar(50) --:username
) to public;

-- DROP TYPE public.topicsusermostrecentlyparticipatedin CASCADE;
CREATE TYPE public.topicsusermostrecentlyparticipatedin AS (
	subject varchar(256),
	body text,
	postid int4,
	threadid int4,
	parentid int4,
	postdate timestamp,
	threaddate timestamp,
	pinneddate timestamp,
	username varchar(50),
	replies int4,
	totalviews int4,
	islocked bool,
	ispinned bool,
	hasread bool,
	mostrecentpostauthor varchar(50),
	mostrecentpostid int4
);
create or replace function forums_gettopicsusermostrecentlyparticipatedin
(
	varchar(50) --:username
) returns setof topicsusermostrecentlyparticipatedin
as '
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
return null; 
end'
security definer language plpgsql;
grant execute on function forums_gettopicsusermostrecentlyparticipatedin
(
	varchar(50) --:username
) to public;

create or replace function forums_gettotalnumberofforums
 () returns int4 
as '
	select
		cast(count(*) as int4)
	from
		forums; '
security definer language sql;
grant execute on function forums_gettotalnumberofforums
 () to public;

create or replace function forums_gettotalpostcount

 () returns int4
as '
	select
	 cast(count(*) as int4)
	from
	  posts; '
security definer language sql;
grant execute on function forums_gettotalpostcount

 () to public;

-- DROP TYPE public.totalpostsforthread CASCADE;
CREATE TYPE public.totalpostsforthread AS (
	totalpostsforthread int4
);
create or replace function forums_gettotalpostsforthread
(
	int --:postid
) returns setof totalpostsforthread
as '
	-- get the count of posts for a given thread
	select 
		cast(count(postid) as int4) as totalpostsforthread
	from 
		posts
	where 
		threadid = $1; '
security definer language sql;
grant execute on function forums_gettotalpostsforthread
(
	int --:postid
) to public;

create or replace function forums_gettotalusers
(
	varchar(1), --:usernamebeginswith
	varchar(50) --:usernametofind
) returns int4 
as '
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
			username ilike ''%'' + _usernametofind + ''%''; 
	end if;
    end if;
    return _return;
end'
security definer language plpgsql;
grant execute on function forums_gettotalusers
(
	varchar(1), --:usernamebeginswith
	varchar(50) --:usernametofind
) to public;

-- DROP TYPE public.email CASCADE;
CREATE TYPE public.email AS (
	email varchar(75)
);
create or replace function forums_gettrackingemailsforthread
(
	int --:postid
) returns setof email
as '
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
security definer language sql;
grant execute on function forums_gettrackingemailsforthread
(
	int --:postid
) to public;

-- DROP TYPE public.unmoderatedpoststatus CASCADE;
CREATE TYPE public.unmoderatedpoststatus AS (
	oldestpostageinminutes int4,
	totalpostsinmoderationqueue int4
);
create or replace function forums_getunmoderatedpoststatus
(
	int, --:forumid
	varchar (50) --:username
) returns setof unmoderatedpoststatus
as '
declare 
	_forumid alias for $1;
	_username alias for $2;
	_rec unmoderatedpoststatus%rowtype;
begin
	if _forumid = 0 then
		_forumid := null
	end if;
	for _rec in
	select 
		(current_timestamp(3) - isnull(min(postdate),current_timestamp(3)))*24*60 as oldestpostageinminutes,
		cast(count(postid) as int4) as totalpostsinmoderationqueue
	from 
		posts p 
	where 
		forumid = isnull(_forumid,forumid) and 
		approved = false
	loop
		return next _rec;
	end loop;
	return null;
end'
security definer language plpgsql;
grant execute on function forums_getunmoderatedpoststatus
(
	int, --:forumid
	varchar (50) --:username
) to public;
/* TODO DEPRECATED?  (There is no usergroups table or view)
create or replace function forums_getusergroups
 () returns setof 
as '
	select
		groupname,
		isadmingroup,
		ismoderatorgroup
	from
		usergroups
	order by
		sortorder,
		groupname; '
security definer language plpgsql;
grant execute on function forums_getusergroups
 () to public;
*/
-- DROP TYPE public.userinfo CASCADE;
CREATE TYPE public.userinfo AS (
	username varchar(50),
	password varchar(50),
	email varchar(75),
	forumview int4,
	approved bool,
	profileapproved bool,
	trusted bool,
	fakeemail varchar(75),
	url varchar(100),
	signature varchar(256),
	datecreated timestamp,
	trackyourposts bool,
	lastlogin timestamp,
	lastactivity timestamp,
	timezone int4,
	location varchar(100),
	occupation varchar(100),
	interests varchar(100),
	msn varchar(50),
	yahoo varchar(50),
	aim varchar(50),
	icq varchar(50),
	ismoderator bool,
	totalposts int4,
	hasavatar bool,
	showunreadtopicsonly bool,
	style varchar(20),
	avatartype int4,
	showavatar bool,
	dateformat varchar(10),
	postvieworder bool,
	flatview bool,
	avatarurl varchar(256),
	attributes char(4)
);
create or replace function forums_getuserinfo
(
	varchar(50), --:username
	bool --:updateisonline
) returns setof userinfo
as '
	-- update activity
	update 
		users 
	set 
		lastactivity = current_timestamp(3) 
	where 
		username ilike $1 and
		true = $2;

        -- get the user details
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
		username ilike $1;'
security definer language sql;
grant execute on function forums_getuserinfo
(
	varchar(50), --:username
	bool --:updateisonline
) to public;

-- DROP TYPE public.username CASCADE;
CREATE TYPE public.username AS (
	username varchar(50)
);
create or replace function forums_getusernamefrompostid
(
	int --:postid
) returns setof username
as '
	-- returns who posted a particular post
	select username
	from posts
	where postid = $1; '
security definer language sql;
grant execute on function forums_getusernamefrompostid
(
	int --:postid
) to public;

create or replace function forums_getusernamebyemail
(
	varchar(50) --:email
) returns setof username
as '
select 
	username
from
	users
where
	email = $1; '
security definer language sql;
grant execute on function forums_getusernamebyemail
(
	varchar(50) --:email
) to public;

-- DROP TYPE public.usersbyfirstcharacter CASCADE;
CREATE TYPE public.usersbyfirstcharacter AS (
	username varchar(50),
	password varchar(50),
	email varchar(75),
	forumview int4,
	approved bool,
	profileapproved bool,
	trusted bool,
	fakeemail varchar(75),
	url varchar(100),
	signature varchar(256),
	datecreated timestamp,
	trackyourposts bool,
	lastlogin timestamp,
	lastactivity timestamp,
	timezone int4,
	location varchar(100),
	occupation varchar(100),
	interests varchar(100),
	msn varchar(50),
	yahoo varchar(50),
	aim varchar(50),
	icq varchar(50),
	totalposts int4,
	hasavatar bool,
	showunreadtopicsonly bool,
	style varchar(20),
	avatartype int4,
	avatarurl varchar(256),
	showavatar bool,
	dateformat varchar(10),
	postvieworder bool,
	flatview bool,
	ismoderator bool,
	attributes char(4)
);
create or replace function forums_getusersbyfirstcharacter
(
	char(1) --:firstletter
) returns setof usersbyfirstcharacter
as '
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
security definer language sql;
grant execute on function forums_getusersbyfirstcharacter
(
	char(1) --:firstletter
) to public;

-- DROP TYPE public.usersonline CASCADE;
CREATE TYPE public.usersonline AS
   (username varchar(50),
    administrator bool,
    ismoderator bool);
create or replace function forums_getusersonline
(
	int --:pastminutes
) returns setof usersonline 
as '
	-- get online users
	select
		username,
		(select cast(count(*) as int4) > 0 from usersinroles where rolename = ''forum-administrators'' and username = u.username limit 1) as administrator,
		(select cast(count(*) as int4) > 0 from moderators where username = u.username) as ismoderator
	from
		users u
	where
		lastactivity > dateadd(''minute'', (0 - $1), current_timestamp(3)); '
security definer language sql;
grant execute on function forums_getusersonline
(
	int --:pastminutes
) to public;

create or replace function forums_getvoteresults (
	int --:postid
) returns setof vote
as '
  select
	*
  from
	vote
  where
	postid = $1; '
security definer language sql;
grant execute on function forums_getvoteresults (
	int --:postid
) to public;

create or replace function forums_isduplicatepost
(
	varchar(50), --:username
	text --:body
) returns int4 
as '
	select cast(count(*) as int4)
	from posts 
	where username ilike $1 and body ilike $2; '
security definer language sql;
grant execute on function forums_isduplicatepost
(
	varchar(50), --:username
	text --:body
) to public;

-- DROP TYPE public.isusertrackingpost CASCADE;
CREATE TYPE public.isusertrackingpost AS (
	isusertrackingpost bool
);
create or replace function forums_isusertrackingpost
(
	int, --:threadid
	varchar(50) --:username
) returns setof isusertrackingpost 
as '
select exists(
	select 
		threadid 
	from 
		threadtrackings 
	where 
		threadid = $1 and 
		username ilike $2) as isusertrackingpost; '
security definer language sql;
grant execute on function forums_isusertrackingpost
(
	int, --:threadid
	varchar(50) --:username
) to public;

create or replace function forums_markallthreadsread
(
	int, --:forumid
	varchar (50) --:username
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_markallthreadsread
(
	int, --:forumid
	varchar (50) --:username
) to public;

create or replace function forums_markpostasread
(
	int, --:postid
	varchar (50) --:username
) returns int
as '
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
security definer language plpgsql;
grant execute on function forums_markpostasread
(
	int, --:postid
	varchar (50) --:username
) to public;

create or replace function forums_movepost
(
	int, --:postid
	int, --:movetoforumid
	varchar(50) --:username
) returns int4 
as '
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
			postid = _postid;
		-- update the forum statistics for the from forum
		perform statistics_resetforumstatistics(_currentforum);
		-- update the forum statistics for the to forum
		perform statistics_resetforumstatistics(_movetoforumid);
		-- record to our moderation audit log
		insert into
			moderationaudit
		values
			(current_timestamp(3), _postid, _username, 3, null);
		if _approvesetting = false
			-- the post was moved but not approved
			return 1;
		else
			-- the post was moved and approved
			return 2; 
		end if;
end '
security definer language plpgsql;
grant execute on function forums_movepost
(
	int, --:postid
	int, --:movetoforumid
	varchar(50) --:username
) to public;

create or replace function forums_removeforumfromrole
(
	int, --:forumid
	varchar(256) --:rolename
) returns int4 
as '
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
security definer language plpgsql;
grant execute on function forums_removeforumfromrole
(
	int, --:forumid
	varchar(256) --:rolename
) to public;

create or replace function forums_removemoderatedforumforuser
(
	varchar(50), --:username
	int --:forumid
) returns int 
as '
	-- remove a row from the moderators table
	delete from moderators
	where username ilike $1 and forumid = $2; 
	SELECT 1;'
security definer language sql;
grant execute on function forums_removemoderatedforumforuser
(
	varchar(50), --:username
	int --:forumid
) to public;

create or replace function forums_removeuserfromrole
(
	varchar(50), --:username
	varchar(256) --:rolename
) returns int4 
as '
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
security definer language plpgsql;
grant execute on function forums_removeuserfromrole
(
	varchar(50), --:username
	varchar(256) --:rolename
) to public;

create or replace function forums_reversetrackinption 
(
	varchar(50), --:username
	int --:postid
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_reversetrackinption 
(
	varchar(50), --:username
	int --:postid
) to public;

create or replace function forums_toggleoptions 
(
	varchar(50), --:username
	bool, --:hidereadthreads
	bool --:flatview
) returns int4 
as '
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
end'
security definer language plpgsql;
grant execute on function forums_toggleoptions 
(
	varchar(50), --:username
	bool, --:hidereadthreads
	bool --:flatview
) to public;

-- DROP TYPE public.topiccountforforum CASCADE;
CREATE TYPE public.topiccountforforum AS (
	totaltopics int4
);
create or replace function forums_topiccountforforum
(
	int, --:forumid
	timestamp(3), --:maxdate
	timestamp(3), --:mindate
	varchar(50), --:username
	bool --:unreadtopicsonly
) returns setof topiccountforforum
as '
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
		return null;
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
	    return null;
	end if;
end'
security definer language plpgsql;
grant execute on function forums_topiccountforforum
(
	int, --:forumid
	timestamp(3), --:maxdate
	timestamp(3), --:mindate
	varchar(50), --:username
	bool --:unreadtopicsonly
) to public;

create or replace function forums_trackanonymoususers
(
	char(36) --:userid
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_trackanonymoususers
(
	char(36) --:userid
) to public;

create or replace function forums_unbanuser
(
	varchar(50) --:username
) returns int 
as '
	-- unban this user
	update users set
		approved = true
	where username ilike $1; 
	SELECT 1;'
security definer language sql;
grant execute on function forums_unbanuser
(
	varchar(50) --:username
) to public;

create or replace function forums_updateemailtemplate
(
	int, --:emailid
	varchar(50), --:subject
	text --:message
) returns int 
as '
	-- update a particular email message
	update emails set
		subject = $2,
		message = $3
	where emailid = $1; 
	SELECT 1;'
security definer language sql;
grant execute on function forums_updateemailtemplate
(
	int, --:emailid
	varchar(50), --:subject
	text --:message
) to public;

create or replace function forums_updateforum
(
	int, --:forumid
	int, --:forumgroupid
	varchar(100), --:name
	varchar(3000), --:description
	bool, --:moderated
	int, --:daystoview
	bool --:active
) returns int 
as '
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
security definer language sql;
grant execute on function forums_updateforum
(
	int, --:forumid
	int, --:forumgroupid
	varchar(100), --:name
	varchar(3000), --:description
	bool, --:moderated
	int, --:daystoview
	bool --:active
) to public;

create or replace function forums_updateforumgroup
(
	varchar(256), --:forumgroupname
	int --:forumgroupid
) returns int 
as '
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
security definer language plpgsql;
grant execute on function forums_updateforumgroup
(
	varchar(256), --:forumgroupname
	int --:forumgroupid
) to public;

create or replace function forums_updatemessagetemplatelist
(
	int, --:messageid
	varchar(256), --:title
	varchar(4000) --:body
) returns int 
as '
update
	messages
set
	title = $2,
	body = $3
where
	messageid = $1; 
SELECT 1;'
security definer language sql;
grant execute on function forums_updatemessagetemplatelist
(
	int, --:messageid
	varchar(256), --:title
	varchar(4000) --:body
) to public;

create or replace function forums_updatepost
(
	int, --:postid
	varchar(256), --:subject
	text, --:body
	bool, --:islocked
	varchar(50) --:editedby
) returns int 
as '
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
security definer language sql;
grant execute on function forums_updatepost
(
	int, --:postid
	varchar(256), --:subject
	text, --:body
	bool, --:islocked
	varchar(50) --:editedby
) to public;

create or replace function forums_updateroledescription
(
	varchar(256), --:rolename
	varchar(512) --:description
) returns int4 
as '
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
security definer language plpgsql;
grant execute on function forums_updateroledescription
(
	varchar(256), --:rolename
	varchar(512) --:description
) to public;

create or replace function forums_updateuserfromadminpage
(
	varchar(50), --:username
	bool, --:profileapproved
	bool, --:approved
	bool --:trusted
) returns int 
as '
	update
		users
	set 
		profileapproved = $2,
		approved = $3,
		trusted = $4
	where
		username ilike $1; 
	SELECT 1;'
security definer language sql;
grant execute on function forums_updateuserfromadminpage
(
	varchar(50), --:username
	bool, --:profileapproved
	bool, --:approved
	bool --:trusted
) to public;

create or replace function forums_updateuserinfo
(
	varchar(50), --:username
	varchar(75), --:email
	varchar(75), --:fakeemail
	varchar(100), --:url
	varchar(255), --:signature
	int, --:forumview
	bool, --:threadtracking
	int, --:timezone
	varchar(20), --:password
	varchar(100), --:occupation
	varchar(100), --:location
	varchar(200), --:interests
	varchar(50), --:msnim
	varchar(50), --:aolim
	varchar(50), --:yahooim
	varchar(50), --:icqim
	bool, --:showunreadtopicsonly
	varchar(20), --:sitestyle
	int4, --:avatartype
	bool, --:hasavatar
	bool, --:showavatar
	varchar(10), --:dateformat
	bool --:postvieworder
) returns int4
 as '
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
security definer language plpgsql;
grant execute on function forums_updateuserinfo
(
	varchar(50), --:username
	varchar(75), --:email
	varchar(75), --:fakeemail
	varchar(100), --:url
	varchar(255), --:signature
	int, --:forumview
	bool, --:threadtracking
	int, --:timezone
	varchar(20), --:password
	varchar(100), --:occupation
	varchar(100), --:location
	varchar(200), --:interests
	varchar(50), --:msnim
	varchar(50), --:aolim
	varchar(50), --:yahooim
	varchar(50), --:icqim
	bool, --:showunreadtopicsonly
	varchar(20), --:sitestyle
	int4, --:avatartype
	bool, --:hasavatar
	bool, --:showavatar
	varchar(10), --:dateformat
	bool --:postvieworder
) to public;

create or replace function forums_userhaspostsawaitingmoderation
(
	varchar(50) --:username
) returns bool 
as '
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
security definer language plpgsql;
grant execute on function forums_userhaspostsawaitingmoderation
(
	varchar(50) --:username
) to public;

create or replace function forums_vote (
	int, --:postid
	varchar(2) --:vote
) returns int4 
as '
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
security definer language plpgsql;
grant execute on function forums_vote (
	int, --:postid
	varchar(2) --:vote
) to public;


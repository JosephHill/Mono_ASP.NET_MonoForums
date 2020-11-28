CREATE OR REPLACE VIEW public.forums_forum AS 

 SELECT forums.forumid, forums.forumgroupid, forums.parentid, forums.name, forums.description, forums.datecreated, forums.daystoview, forums.moderated, forums.totalposts, forums.totalthreads AS totaltopics, forums.mostrecentpostid, forums.mostrecentthreadid, forums.mostrecentpostdate, forums.mostrecentpostauthor, forums.active, forums.sortorder, forums.displaymask 
   FROM forums;


CREATE OR REPLACE VIEW public.forums_post AS 

 SELECT p.subject, p.body, p.postid, p.threadid, p.parentid, p.totalviews, p.islocked, p.ispinned, p.threaddate, p.pinneddate, p.username, p.forumid, p.postlevel, p.sortorder, p.approved, p.posttype, p.postdate, (
         SELECT forums.name 
           FROM forums 
          WHERE (forums.forumid = p.forumid )) AS forumname, (
                 SELECT count(* ) AS count 
                   FROM posts 
                  WHERE (((p.threadid = posts.threadid ) AND (posts.approved = true )) AND (posts.postlevel <> 1 ))) AS replies, (
                         SELECT posts.username 
                           FROM posts 
                          WHERE ((p.threadid = posts.threadid ) AND (posts.approved = true )) 
                          ORDER BY posts.postdate DESC 
                          LIMIT 1 ) AS mostrecentpostauthor, (
                                 SELECT posts.postid 
                                   FROM posts 
                                  WHERE ((p.threadid = posts.threadid ) AND (posts.approved = true )) 
                                  ORDER BY posts.postdate DESC 
                                  LIMIT 1 ) AS mostrecentpostid 
                                   FROM posts p; 




CREATE OR REPLACE VIEW public.forums_user AS 

 SELECT users.username, users."password", users.email, users.forumview, users.approved, users.profileapproved, users."trusted", users.fakeemail, users.url, users.signature, users.datecreated, users.trackyourposts, users.lastlogin, users.lastactivity, users.timezone, users."location", users.occupation, users.interests, users.msn, users.yahoo, users.aim, users.icq, users.totalposts, users.hasavatar, users.showunreadtopicsonly, users.style, users.avatartype, users.showavatar, users.dateformat, users.postvieworder, users.avatarurl, (
         SELECT count(* ) AS count 
           FROM moderators 
          WHERE (moderators.username = users.username )) AS ismoderator, users.flatview, users.attributes 
           FROM users;

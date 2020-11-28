ALTER TABLE emails_emailid_seq OWNER TO test;
ALTER TABLE emails OWNER TO test;
ALTER TABLE forumgroups_forumgroupid_seq OWNER TO test;
ALTER TABLE forumgroups OWNER TO test;
ALTER TABLE forums_forumid_seq OWNER TO test;
ALTER TABLE forums OWNER TO test;
ALTER TABLE forumsread OWNER TO test;
ALTER TABLE messages_messageid_seq OWNER TO test;
ALTER TABLE messages OWNER TO test;
ALTER TABLE moderationaction OWNER TO test;
ALTER TABLE moderationaudit OWNER TO test;
ALTER TABLE moderators OWNER TO test;
ALTER TABLE post_archive_postid_seq OWNER TO test;
ALTER TABLE post_archive OWNER TO test;
ALTER TABLE posts_postid_seq OWNER TO test;
ALTER TABLE posts OWNER TO test;
ALTER TABLE postsread OWNER TO test;
ALTER TABLE privateforums OWNER TO test;
ALTER TABLE threadtrackings OWNER TO test;
ALTER TABLE userroles OWNER TO test;
ALTER TABLE users_userid_seq OWNER TO test;
ALTER TABLE users OWNER TO test;
ALTER TABLE usersinroles OWNER TO test;
ALTER TABLE vote OWNER TO test;
ALTER TABLE forums_forum OWNER TO test;
ALTER TABLE forums_post OWNER TO test;
ALTER TABLE forums_user OWNER TO test;
ALTER TABLE anonymoususers OWNER TO test;
ALTER FUNCTION dateadd (character varying, integer, timestamp with time zone) OWNER TO test;
ALTER FUNCTION hasreadpost (character varying, integer, integer) OWNER TO test;
ALTER FUNCTION statistics_updateforumstatistics (integer, integer, integer) OWNER TO test;
ALTER FUNCTION maintenance_cleanforumsread (integer) OWNER TO test;
ALTER FUNCTION maintenance_resetforumgroupsforinsert () OWNER TO test;
ALTER FUNCTION moderate_getposthistory (integer, character varying) OWNER TO test;
ALTER FUNCTION reports_uservisitsbyday (integer, boolean) OWNER TO test;
ALTER FUNCTION search_foruser (integer, integer, character varying, character varying) OWNER TO test;
ALTER FUNCTION statistics_getmoderationactions () OWNER TO test;
ALTER FUNCTION statistics_getmostactivemoderators () OWNER TO test;
ALTER FUNCTION statistics_getmostactiveusers () OWNER TO test;
ALTER FUNCTION statistics_resetforumstatistics (integer) OWNER TO test;
ALTER FUNCTION statistics_resettopposters () OWNER TO test;
ALTER FUNCTION forums_addforum (character varying, character varying, integer, boolean, integer, boolean) OWNER TO test;
ALTER FUNCTION forums_addforumgroup (character varying) OWNER TO test;
ALTER FUNCTION forums_addforumtorole (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_addmoderatedforumforuser (character varying, integer, boolean) OWNER TO test;
ALTER FUNCTION forums_addpost (integer, integer, character varying, character varying, text, boolean, timestamp without time zone) OWNER TO test;
ALTER FUNCTION forums_addusertorole (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_approvemoderatedpost (integer, character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_approvepost (integer) OWNER TO test;
ALTER FUNCTION forums_canmoderate (character varying) OWNER TO test;
ALTER FUNCTION forums_canmoderateforum (character varying, integer) OWNER TO test;
ALTER FUNCTION forums_changeuserpassword (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_checkusercredentials (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_createnewrole (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_deleteforum (integer) OWNER TO test;
ALTER FUNCTION forums_deleterole (character varying) OWNER TO test;
ALTER FUNCTION forums_getallbutoneforum (integer) OWNER TO test;
ALTER FUNCTION forums_getallforumgroups (boolean, character varying) OWNER TO test;
ALTER FUNCTION forums_getallforums (boolean, character varying) OWNER TO test;
ALTER FUNCTION forums_getallroles () OWNER TO test;
ALTER FUNCTION forums_getalltopicspaged (integer, integer, integer, timestamp without time zone, character varying, boolean) OWNER TO test;
ALTER FUNCTION forums_getallusers (integer, integer, integer, boolean, character varying) OWNER TO test;
ALTER FUNCTION forums_getanonymoususersonline () OWNER TO test;
ALTER FUNCTION forums_getbannedusers () OWNER TO test;
ALTER FUNCTION forums_getemailinfo (integer) OWNER TO test;
ALTER FUNCTION forums_getemaillist () OWNER TO test;
ALTER FUNCTION forums_getforumbypostid (integer) OWNER TO test;
ALTER FUNCTION forums_getforumbythreadid (integer) OWNER TO test;
ALTER FUNCTION forums_getforumgroupbyforumid (integer) OWNER TO test;
ALTER FUNCTION forums_getforumgroupnamebyid (integer) OWNER TO test;
ALTER FUNCTION forums_getforummessagetemplatelist () OWNER TO test;
ALTER FUNCTION forums_getforummoderators (integer) OWNER TO test;
ALTER FUNCTION forums_getforumviewbyusername (character varying) OWNER TO test;
ALTER FUNCTION forums_getforumsbyforumgroupid (integer, integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getmessage (integer) OWNER TO test;
ALTER FUNCTION forums_getmoderatorsforemailnotification (integer) OWNER TO test;
ALTER FUNCTION forums_getnextpostid (integer, integer, integer) OWNER TO test;
ALTER FUNCTION forums_getnextthreadid (integer, integer) OWNER TO test;
ALTER FUNCTION forums_getparentid (integer) OWNER TO test;
ALTER FUNCTION forums_getpostinfo (integer, boolean, character varying) OWNER TO test;
ALTER FUNCTION forums_getprevpostid (integer, integer, integer) OWNER TO test;
ALTER FUNCTION forums_getprevthreadid (integer, integer) OWNER TO test;
ALTER FUNCTION forums_getrolesbyforum (integer) OWNER TO test;
ALTER FUNCTION forums_getrolesbyuser (character varying) OWNER TO test;
ALTER FUNCTION forums_getsearchresults (character varying, integer, integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getsinglemessage (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getstatistics () OWNER TO test;
ALTER FUNCTION forums_getthread (integer) OWNER TO test;
ALTER FUNCTION forums_getthreadbyparentid (integer) OWNER TO test;
ALTER FUNCTION forums_getthreadbypostid (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getthreadbypostidpaged (integer, integer, integer, integer, integer, character varying) OWNER TO test;
ALTER FUNCTION forums_gettopicsuseristracking (character varying) OWNER TO test;
ALTER FUNCTION forums_gettopicsusermostrecentlyparticipatedin (character varying) OWNER TO test;
ALTER FUNCTION forums_gettotalnumberofforums () OWNER TO test;
ALTER FUNCTION forums_gettotalpostcount () OWNER TO test;
ALTER FUNCTION forums_gettotalpostsforthread (integer) OWNER TO test;
ALTER FUNCTION forums_gettotalusers (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_gettrackingemailsforthread (integer) OWNER TO test;
ALTER FUNCTION forums_getuserinfo (character varying, boolean) OWNER TO test;
ALTER FUNCTION forums_getusernamefrompostid (integer) OWNER TO test;
ALTER FUNCTION forums_getusernamebyemail (character varying) OWNER TO test;
ALTER FUNCTION forums_getusersbyfirstcharacter (character) OWNER TO test;
ALTER FUNCTION forums_getusersonline (integer) OWNER TO test;
ALTER FUNCTION forums_getvoteresults (integer) OWNER TO test;
ALTER FUNCTION forums_isusertrackingpost (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_markpostasread (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_removemoderatedforumforuser (character varying, integer) OWNER TO test;
ALTER FUNCTION forums_topiccountforforum (integer, timestamp without time zone, timestamp without time zone, character varying, boolean) OWNER TO test;
ALTER FUNCTION forums_trackanonymoususers (character) OWNER TO test;
ALTER FUNCTION forums_unbanuser (character varying) OWNER TO test;
ALTER FUNCTION forums_updateemailtemplate (integer, character varying, text) OWNER TO test;
ALTER FUNCTION forums_updateforum (integer, integer, character varying, character varying, boolean, integer, boolean) OWNER TO test;
ALTER FUNCTION forums_updatemessagetemplatelist (integer, character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_updatepost (integer, character varying, text, boolean, character varying) OWNER TO test;
ALTER FUNCTION forums_updateuserfromadminpage (character varying, boolean, boolean, boolean) OWNER TO test;
ALTER FUNCTION forums_getforuminfo (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_changeforumgroupsortorder (integer, boolean) OWNER TO test;
ALTER FUNCTION forums_createnewuser (character varying, character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_deletemoderatedpost (integer, character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_deletepost (integer) OWNER TO test;
ALTER FUNCTION forums_deletepostandchildren (integer) OWNER TO test;
ALTER FUNCTION forums_findusersbyname (integer, integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getallforumgroupsformoderation (character varying) OWNER TO test;
ALTER FUNCTION forums_getallforumsbyforumgroupid (integer, boolean) OWNER TO test;
ALTER FUNCTION forums_getallmessages (integer, integer, integer) OWNER TO test;
ALTER FUNCTION forums_getallunmoderatedtopicspaged (integer, integer, integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getforumsformoderationbyforumgroupid (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getforumsmoderatedbyuser (character varying) OWNER TO test;
ALTER FUNCTION forums_getforumsnotmoderatedbyuser (character varying) OWNER TO test;
ALTER FUNCTION forums_getmoderatedforums (character varying) OWNER TO test;
ALTER FUNCTION forums_getmoderatedposts (character varying) OWNER TO test;
ALTER FUNCTION forums_gettimezonebyusername (character varying) OWNER TO test;
ALTER FUNCTION forums_gettop25newposts (character varying) OWNER TO test;
ALTER FUNCTION forums_getunmoderatedpoststatus (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_markallthreadsread (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_removeforumfromrole (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_removeuserfromrole (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_reversetrackingoption (character varying, integer) OWNER TO test;
ALTER FUNCTION forums_toggleoptions (character varying, boolean, boolean) OWNER TO test;
ALTER FUNCTION forums_updateforumgroup (character varying, integer) OWNER TO test;
ALTER FUNCTION forums_updateroledescription (character varying, character varying) OWNER TO test;
ALTER FUNCTION forums_vote (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getpostread (integer, character varying) OWNER TO test;
ALTER FUNCTION forums_getprevnextthreadid (integer, boolean) OWNER TO test;
ALTER FUNCTION forums_getroledescription (character varying) OWNER TO test;
ALTER FUNCTION forums_getsummaryinfo () OWNER TO test;
ALTER FUNCTION forums_movepost (integer, integer, character varying) OWNER TO test;
ALTER FUNCTION forums_userhaspostsawaitingmoderation (character varying) OWNER TO test;
ALTER FUNCTION forums_isduplicatepost (character varying, text) OWNER TO test;
ALTER FUNCTION forums_updateuserinfo (character varying, character varying, character varying, character varying, character varying, integer, boolean, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, character varying, integer, boolean, boolean, character varying, boolean) OWNER TO test;
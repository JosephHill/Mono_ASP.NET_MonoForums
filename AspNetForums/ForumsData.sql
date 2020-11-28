
BEGIN;


INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('1', 'ASP.NET Forums: Your password', '1', 'email', 'Send the user their forgotten password.', '<Username>, 
At <TimeSent> you requested that your ASP.NET Forums password be sent to you via email.
Your username and password are:
Username: <Username>
Password:  <Password>
You can login from:
<WebSiteUrl><UrlLogin>')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('2', 'ASP.NET Forums: Password Changed', '2', 'email', 'Notify the user when they have changed their password.', '<Username>, 
Your ASP.NET Forums password was changed at <TimeSent>. 
Your password was changed to: 
<Password>')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('3', 'ASP.NET Forums: <Subject>', '0', 'email', 'Notify the user when a new message has been posted to a thread they are tracking.', 'At <TimeSent> a message was posted to a thread you were tracking.
<Subject> by <PostedBy>
<PostBody>
To view the complete thread and reply, please visit:
<WebSiteUrl><PostUrl>.  
You were sent this email because you opted to receive email notifications when someone responded to this thread. To unsubscribe to this thread either:
1. Visit the above URL and uncheck ''Email me when someone replies...''
2. Visit your user profile page and uncheck ''Enable email tracking''')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('4', 'ASP.NET Forums: Your user account information', '2', 'email', 'Send the user their username/password when they create a new account.', '<Username>, 
At <TimeSent> you created a new user account at <SiteName>.  
Your username and password are:
Username: <Username>
Password:  <Password>
To begin posting, you will need to log in first.
To login, please visit:
<WebSiteUrl><UrlLogin>
To change your password (after logging in), please visit:
<WebSiteUrl><UrlProfile>
Once you login, you should take a moment to set your user profile, available on the top right of any page within the forum. From the User Information page you can change your password, enter the email address you wish to have display when you post messages, choose how to have the forum posts displayed, and other handy settings.')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('5', 'ASP.NET Forums: Your message has been approved!', '0', 'email', 'Notify the user that their message to a moderated forum has been approved.', 'At <PostDate> you posted a message titled "<Subject>" to the <ForumName> forum, which is a moderated forum.  This email is to let you know that your message was approved at <TimeSent>.  
You can now view it at: 
<WebSiteUrl><PostUrl>.')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('6', 'ASP.NET Forums: Your message has been moved and approved', '0', 'email', 'Notify the user that their message has been moved to another forum and approved.', 'At <PostDate> you posted a message titled "<Subject>" to a moderated forum.  At <TimeSent> this message was moved to the <ForumName> forum and approved.  
You can view your message at the following URL:
<WebSiteUrl><PostUrl>')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('7', 'ASP.NET Forums: Your post has been moved to another forum', '0', 'email', 'Notify the user that their message has been moved and NOT yet approved.', 'At <PostDate> you posted a message titled "<Subject>" to a moderated forum.  At <TimeSent> this message was moved to the <ForumName> forum, where it is still waiting approval.  You will receive a second email once this message is approved in the new forum.')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('8', 'ASP.NET Forums: Your post has been deleted.', '2', 'email', 'Notify the user that their post has been deleted.', 'At <PostDate> a message you posted title "<Subject>" to the <ForumName> forum was deleted by the forum moderator.  The moderator provided the following reason(s) for deleting your post:
<DeleteReasons>')
;
INSERT INTO "public"."emails" ("emailid", "subject", "importance", "fromaddress", "description", "message") VALUES ('9', 'ASP.NET Forums: A post is awaiting moderation.', '0', 'email', 'Notify the moderator(s) that a new post is awaitng moderation.', 'At <TimeSent> a post was made to the <ForumName> Forum:
Posted By: <PostedBy>
Subject: <Subject>
Posted On: <PostDate>
Post Body:
<PostBody>
Visit <WebSiteUrl><ModerateUrl> to moderate this post...')
;
INSERT INTO "public"."forumgroups" ("forumgroupid", "name", "sortorder") VALUES ('1', 'Sample Forum Group', '0')
;
INSERT INTO "public"."forums" ("forumid", "forumgroupid", "parentid", "name", "description", "datecreated", "moderated", "daystoview", "active", "sortorder", "totalposts", "totalthreads", "mostrecentpostid", "mostrecentthreadid", "mostrecentpostdate", "mostrecentpostauthor", "displaymask") VALUES ('1', '1', '0', 'Sample Unmoderated Forum', 'A sample unmoderated forum created when the AspNetForums were installed.', '2004-5-21 23:36:45', '0', '0', '1', '10', '1', '1', '1', '1', '2004-5-21 23:36:45', 'Admin', '\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000')
;
INSERT INTO "public"."forums" ("forumid", "forumgroupid", "parentid", "name", "description", "datecreated", "moderated", "daystoview", "active", "sortorder", "totalposts", "totalthreads", "mostrecentpostid", "mostrecentthreadid", "mostrecentpostauthor", "displaymask") VALUES ('2', '1', '0', 'Sample Moderated Forum', 'A sample moderated forum created when the AspNetForums were installed.', '2004-5-21 23:36:45', '1', '0', '1', '20', '0', '0', '0', '0', '', '\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000')
;
INSERT INTO "public"."forums" ("forumid", "forumgroupid", "parentid", "name", "description", "datecreated", "moderated", "daystoview", "active", "sortorder", "totalposts", "totalthreads", "mostrecentpostid", "mostrecentthreadid", "mostrecentpostdate", "mostrecentpostauthor", "displaymask") VALUES ('3', '1', '0', 'Sample Private Forum', 'A sample private forum created when the AspNetForums were installed.', '2004-5-21 23:36:45', '0', '0', '1', '30', '1', '1', '3', '3', '2004-5-21 23:36:45', 'Admin', '\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('1', 'Error: You are Unable to Administer', 'In order to perform <i>any</i> administration duties on this Web site, your user account must be marked as having administrator rights.  Unfortunately, your account does not have such rights.<p>If you believe you''ve reached this message in error, please notify the Web site administrator.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('2', 'Error: You are Unable to Edit this Post', 'Due to security settings, you are not able to edit this post.  Most likely, another moderator has already approved the post you are attempting to edit. Administrators may edit <i>any</i> post.  Moderators may only edit non-Approved posts in forums they have been selected to moderate.<p>If you believe you''ve reached this message in error, please contact the Web site administrator.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('3', 'Error: You Are Not Able to Moderate', 'In order to participate in the moderation of posts, you must have been granted adequate permissions from the Web site administrator.  That is, the Web site administrator must have explicitly setup your User account to allow for post moderation.  Please contact the Web site administrator if you believe you''ve reached this message in error.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('4', 'Error: Attempting to Insert a Duplicate Post', 'You have, in the past, attempted to post a question on this forum, or another forum, with the same body.  Duplicate posts are not allowed.<p><DuplicatePost>')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('5', 'Error: File Not Found', 'The file you requested cannot be found.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('6', 'Error: Unknown forum', 'The forum you requested does not exist.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('7', 'New Account Created', 'You will soon receive an email which will contain a randomly generated password.  Once you have this information you may login at the <UrlLogin>.<p>Once you''ve logged in, you may wish to visit your user profile and change your password - all of these details will be provided in the email.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('8', 'Post Pending Moderation', 'Since you posted to a moderated forum, a forum administrator must approve your post before it will become visible.  Please be patient, this may take anywhere from a few minutes to many hours.<p>Note that you will receive an email when your post is approved.<p><PendingModeration>')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('9', 'Error: Post Does Not Exist', 'The post you attempted to view does not exist.  Most likely, the message you are trying to view has been deleted by one of the site''s administrators.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('10', 'Error: PostID Parameter Not Specified', 'You have attempted to visit the Web page to display a forum''s post, but, for some reason, the PostID was not successfully passed in.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('11', 'Error: There was a Problem Posting your Message', 'There was a problem posting your message.  This is most likely due to the fact that while you were replying to a message, it has been deleted by the administrator.  We apologize for any inconvenience.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('12', 'Error: The post you are attempting to view has not been approved', 'You are unable to view this message due to the fact that it has not been approved. Most likely this is because you are trying to view a post that was posted to a moderated forum and has not yet been approved by one of the forum administrators.<p>Once this post has been approved, it will appear in the forum list and you will be able to view its contents.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('13', 'Your user profile has been successfully updated', 'Your user information has been updated and will be reflected immediately.<p>Please return to the <UrlHome>')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('14', 'Error: User Does Not Exist', 'The user you attempted to view does not exist.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('15', 'User Password Updated', 'Your user password has been updated and mailed to you.')
;
INSERT INTO "public"."messages" ("messageid", "title", "body") VALUES ('16', 'Error: User Password Update Failed', 'Your password update operation failed - your password has not been changed.')
;
INSERT INTO "public"."moderationaction" ("moderationaction", "description") VALUES ('1', 'Approve')
;
INSERT INTO "public"."userroles" ("rolename", "description") VALUES ('Forum-Administrators', 'Forum administrators role.')
;
INSERT INTO "public"."userroles" ("rolename", "description") VALUES ('Forum-Moderators', 'Forum moderators role.')
;
INSERT INTO "public"."users" ("username", "userid", "password", "email", "forumview", "profileapproved", "approved", "trusted", "fakeemail", "url", "signature", "datecreated", "trackyourposts", "lastlogin", "lastactivity", "timezone", "location", "occupation", "interests", "msn", "yahoo", "aim", "icq", "totalposts", "hasavatar", "showunreadtopicsonly", "style", "showavatar", "dateformat", "postvieworder", "flatview", "displayinmemberlist", "avatarurl", "avatartype", "attributes") VALUES ('Admin', '1', 'admin', 'noemail', '2', '1', '1', '0', '', '', '', '2004-5-21 23:36:45', '0', '2004-5-21 23:36:45', '2004-5-21 23:36:45', '-5', '', '', '', '', '', '', '', '3', '0', '0', 'default', '0', 'MM-dd-yyyy', '0', '1', '1', '', '1', '\\000\\000\\000\\000')
;
INSERT INTO "public"."usersinroles" ("username", "rolename") VALUES ('Admin', 'Forum-Administrators')
;
INSERT INTO "public"."usersinroles" ("username", "rolename") VALUES ('Admin', 'Forum-Moderators')
;
INSERT INTO "public"."moderators" ("username", "forumid", "datecreated", "emailnotification") VALUES ('Admin', '0', '2004-5-21 23:36:45', '0')
;
INSERT INTO "public"."posts" ("postid", "threadid", "parentid", "postlevel", "sortorder", "subject", "postdate", "approved", "forumid", "username", "threaddate", "totalviews", "islocked", "ispinned", "pinneddate", "body", "posttype") VALUES ('1', '1', '1', '1', '1', 'Sample Post in unmoderated forum', '2004-5-21 23:36:45', '1', '1', 'Admin', '2004-5-21 23:36:45', '0', '0', '0', '2004-5-21 23:36:45', 'Sample post in unmoderated forum', '0')
;
INSERT INTO "public"."posts" ("postid", "threadid", "parentid", "postlevel", "sortorder", "subject", "postdate", "approved", "forumid", "username", "threaddate", "totalviews", "islocked", "ispinned", "pinneddate", "body", "posttype") VALUES ('2', '2', '2', '1', '1', 'Sample Post in moderated forum', '2004-5-21 23:36:45', '0', '2', 'Admin', '2004-5-21 23:36:45', '0', '0', '0', '2004-5-21 23:36:45', 'Sample post in moderated forum', '0')
;
INSERT INTO "public"."posts" ("postid", "threadid", "parentid", "postlevel", "sortorder", "subject", "postdate", "approved", "forumid", "username", "threaddate", "totalviews", "islocked", "ispinned", "pinneddate", "body", "posttype") VALUES ('3', '3', '3', '1', '1', 'Sample Post in private forum', '2004-5-21 23:36:45', '1', '3', 'Admin', '2004-5-21 23:36:45', '0', '0', '0', '2004-5-21 23:36:45', 'Sample post in private forum', '0')
;
INSERT INTO "public"."privateforums" ("forumid", "rolename") VALUES ('3', 'Forum-Administrators')
;

COMMIT;
select setval('emails_emailid_seq', (select max(emailid) from emails))
	where (select max(emailid) from emails) > 0;
select setval('forumgroups_forumgroupid_seq', (select max(forumgroupid) from forumgroups))
	where (select max(forumgroupid) from forumgroups) > 0;
select setval('forums_forumid_seq', (select max(forumid) from forums))
	where (select max(forumid) from forums) > 0;
select setval('messages_messageid_seq', (select max(messageid) from messages))
	where (select max(messageid) from messages) > 0;
select setval('post_archive_postid_seq', (select max(postid) from post_archive))
	where (select max(postid) from post_archive) > 0;
select setval('posts_postid_seq', (select max(postid) from posts))
	where (select max(postid) from posts) > 0;
select setval('users_userid_seq', (select max(userid) from users))
	where (select max(userid) from users) > 0;
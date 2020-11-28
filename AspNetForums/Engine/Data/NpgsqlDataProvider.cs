using System;
using System.Data;
using Npgsql;
using AspNetForums.Components;
using System.Web;
using System.Web.Mail;
using System.IO;
using System.Text.RegularExpressions;
using System.Collections;
using System.Text;

namespace AspNetForums.Data {


    /// <summary>
    /// Summary description for WebForumsDataProvider.
    /// </summary>
    public class NpgsqlDataProvider : IDataProviderBase {

        /****************************************************************
        // GetNextThreadID
        //
        /// <summary>
        /// Gets the next threadid based on the postid
        /// </summary>
        //
        ****************************************************************/
        public ModerationQueueStatus GetQueueStatus(int forumID, string username) {
            ModerationQueueStatus moderationQueue = new ModerationQueueStatus();

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getunmoderatedpoststatus(:forumid,:username)", myConnection);
            NpgsqlDataReader reader;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumID;
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();

            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                moderationQueue.AgeInMinutes = (int) reader["oldestpostageinminutes"];
                moderationQueue.Count = (int) reader["totalpostsinmoderationqueue"];
            }

            reader.Close();
            myConnection.Close();

            return moderationQueue;
        }

        /****************************************************************
        // GetNextThreadID
        //
        /// <summary>
        /// Gets the next threadid based on the postid
        /// </summary>
        //
        ****************************************************************/
        public int GetNextThreadID(int postID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getprevnextthreadid(:postid,:nextthread)", myConnection);
            NpgsqlDataReader reader;
            int threadID = postID;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;
            myCommand.Parameters.Add("nextthread", NpgsqlTypes.NpgsqlDbType.Boolean).Value = true;

            // Execute the command
            myConnection.Open();

            reader = myCommand.ExecuteReader();

            while (reader.Read())
                threadID = (int) reader["threadid"];

            reader.Close();
            myConnection.Close();

            return threadID;
        }

        /****************************************************************
        // GetPrevThreadID
        //
        /// <summary>
        /// Gets the prev threadid based on the postid
        /// </summary>
        //
        ****************************************************************/
        public int GetPrevThreadID(int postID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getprevnextthreadid(:postid,:nextthread)", myConnection);
            NpgsqlDataReader reader;
            int threadID = postID;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;
            myCommand.Parameters.Add("nextthread", NpgsqlTypes.NpgsqlDbType.Boolean).Value = false;

            // Execute the command
            myConnection.Open();

            reader = myCommand.ExecuteReader();

            while (reader.Read())
                threadID = (int) reader["threadid"];

            reader.Close();
            myConnection.Close();

            return threadID;
        }

        /****************************************************************
        // Vote
        //
        /// <summary>
        /// Votes for a poll
        /// </summary>
        //
        ****************************************************************/
        public void Vote(int postID, string selection) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_vote(:postid,:vote)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;
            myCommand.Parameters.Add("vote", NpgsqlTypes.NpgsqlDbType.Text, 2).Value = selection;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }
        
        /****************************************************************
        // GetVoteResults
        //
        /// <summary>
        /// Returns a collection of threads that the user has recently partipated in.
        /// </summary>
        //
        ****************************************************************/
        public VoteResultCollection GetVoteResults(int postID) {
            VoteResult voteResult;
            VoteResultCollection voteResults = new VoteResultCollection();

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getvoteresults(:postid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            
            // Read the values
            //
            while (dr.Read()) {
                voteResult = new VoteResult();
                voteResult.Vote = (string) dr["vote"];
                voteResult.VoteCount = (int) dr["votecount"];

                voteResults.Add(voteResult.Vote,voteResult);
            }
            
            // Close the conneciton
            myConnection.Close();

            return voteResults;
        }

        /****************************************************************
        // GetThreadsUserMostRecentlyParticipatedIn
        //
        /// <summary>
        /// Returns a collection of threads that the user has recently partipated in.
        /// </summary>
        //
        ****************************************************************/
        public ThreadCollection GetThreadsUserMostRecentlyParticipatedIn(string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettopicsusermostrecentlyparticipatedin(:username)", myConnection);
            ThreadCollection threads;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            threads = new ThreadCollection();

            while (dr.Read()) {
                threads.Add(PopulateThreadFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            // Only return the posts specified through paging

            return threads;
        }


        /****************************************************************
        // GetThreadsUserIsTracking
        //
        /// <summary>
        /// Returns a collection of threads that the user is tracking
        /// </summary>
        //
        ****************************************************************/
        public ThreadCollection GetThreadsUserIsTracking(string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettopicsuseristracking(:username)", myConnection);
            ThreadCollection threads;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            threads = new ThreadCollection();

            while (dr.Read()) {
                threads.Add(PopulateThreadFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            // Only return the posts specified through paging

            return threads;
        }


        /****************************************************************
        // FindUsersByName
        //
        /// <summary>
        /// Returns a collection of users matching the name value provided.
        /// </summary>
        //
        ****************************************************************/
        public UserCollection FindUsersByName(int pageIndex, int pageSize, string usernameToMatch) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_findusersbyname(:pageindex,:pagesize,:usernametofind)", myConnection);
            NpgsqlDataReader reader;
            UserCollection users = new UserCollection();
            User user;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            myCommand.Parameters.Add("pageindex", NpgsqlTypes.NpgsqlDbType.Integer).Value = pageIndex;
            myCommand.Parameters.Add("pagesize", NpgsqlTypes.NpgsqlDbType.Integer).Value = pageSize;
            myCommand.Parameters.Add("usernametofind", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = usernameToMatch;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                user = this.PopulateUserFromNpgsqlDataReader(reader);
                users.Add(user);
            }

            reader.Close();
            myConnection.Close();

            return users;
        }

        
        
        /****************************************************************
        // GetTopNPopularPosts
        //
        /// <summary>
        /// TODO
        /// </summary>
        //
        ****************************************************************/
        public PostCollection GetTopNPopularPosts(string username, int postCount, int days) {
            return GetTopNPosts(username, postCount, days, "TotalViews");
        }
        
        /****************************************************************
        // GetTopNPopularPosts
        //
        /// <summary>
        /// ToDO
        /// </summary>
        //
        ****************************************************************/
        public PostCollection GetTopNNewPosts(string username, int postCount) {
            return GetTopNPosts(username, postCount, 0, "ThreadDate");
        }
        
        /****************************************************************
        // GetTopNPopularPosts
        //
        /// <summary>
        /// TODO
        /// </summary>
        //
        ****************************************************************/
        private PostCollection GetTopNPosts(string username, int postCount, int days, string sort) {
            PostCollection posts = new PostCollection();
            NpgsqlConnection myConnection;

            using(myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString)) {
                NpgsqlCommand myCommand = new NpgsqlCommand("forums_GetTopNPosts", myConnection);
                myCommand.CommandType = CommandType.StoredProcedure;
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
                myCommand.Parameters.Add("sorttype", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = sort;
                myCommand.Parameters.Add("postcount", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = postCount;
                myCommand.Parameters.Add("daystocount", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = days;
                
                myConnection.Open();
                using(NpgsqlDataReader dr = myCommand.ExecuteReader()) {
                    Post post = null;
                    
                    while(dr.Read()) {
                        post = PopulatePostFromNpgsqlDataReader(dr);
                        posts.Add(post);
                    }
                }
            }

            // Close the connection
            myConnection.Close();
            return posts;
        }

        /****************************************************************
        // GetModerationAuditSummary
        //
        /// <summary>
        /// Returns a summary of moderation audit details.
        /// </summary>
        //
        ****************************************************************/
        public ModerationAuditCollection GetModerationAuditSummary() {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("statistics_getmoderationactions()", myConnection);
            NpgsqlDataReader reader;
            ModerationAuditCollection moderationAudits = new ModerationAuditCollection();
            ModerationAuditSummary moderationAudit;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                moderationAudit = new ModerationAuditSummary();
                moderationAudit.Action = (string) reader["description"];
                moderationAudit.ActionSummary = Convert.ToInt32(reader["totalactions"]);

                moderationAudits.Add(moderationAudit);
            }

            reader.Close();
            myConnection.Close();

            return moderationAudits;

        }

        /****************************************************************
        // GetMostActiveModerators
        //
        /// <summary>
        /// Returns a collection of the most active moderators.
        /// </summary>
        //
        ****************************************************************/
        public ModeratorCollection GetMostActiveModerators() {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("statistics_getmostactivemoderators()", myConnection);
            NpgsqlDataReader reader;
            ModeratorCollection moderators = new ModeratorCollection();
            Moderator moderator;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                moderator = new Moderator();
                moderator.Username = (string) reader["username"];
                moderator.TotalPostsModerated = Convert.ToInt32(reader["postsmoderated"]);

                moderators.Add(moderator);
            }

            reader.Close();
            myConnection.Close();

            return moderators;

        }


        /****************************************************************
        // GetMostActiveUsers
        //
        /// <summary>
        /// Returns a collection of the most active users.
        /// </summary>
        //
        ****************************************************************/
        public UserCollection GetMostActiveUsers() {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("statistics_getmostactiveusers()", myConnection);
            NpgsqlDataReader reader;
            UserCollection users = new UserCollection();
            User user;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                user = new User();
                user.Username = (string) reader["username"];
                user.TotalPosts = Convert.ToInt32(reader["totalposts"]);

                users.Add(user);
            }

            reader.Close();
            myConnection.Close();

            return users;

        }


        /****************************************************************
        // GetAllUnmoderatedThreads
        //
        /// <summary>
        /// Returns a collection of all posts that have yet to be approved.
        /// </summary>
        //
        ****************************************************************/
        public ThreadCollection GetAllUnmoderatedThreads(int forumID, int pageSize, int pageIndex, string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallunmoderatedtopicspaged(:forumid,:pagesize,:pageindex,:username)", myConnection);
            ThreadCollection threads;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = forumID;
            myCommand.Parameters.Add("pagesize", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = pageSize;
            myCommand.Parameters.Add("pageindex", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = pageIndex;
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            threads = new ThreadCollection();

            while (dr.Read()) {
                threads.Add(PopulateThreadFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            // Only return the posts specified through paging
            return threads;
        }

        /****************************************************************
        // GetTotalUnModeratedThreadsInForum
        //
        /// <summary>
        /// Returns a count of all posts that have yet to be approved.
        /// </summary>
        //
        ****************************************************************/
        public int GetTotalUnModeratedThreadsInForum(int ForumID, DateTime maxDateTime, DateTime minDateTime, string username, bool unreadThreadsOnly) {
            return 0;
        }

        /****************************************************************
        // GetForumsForModerationByForumGroupId
        //
        /// <summary>
        /// Returns forums in a given forum group for moderation
        /// </summary>
        //
        ****************************************************************/
        public ModeratedForumCollection GetForumsForModerationByForumGroupId(int forumGroupId, string username) {

            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumsformoderationbyforumgroupid(:forumgroupid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumgroupid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumGroupId;
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // populate a ForumCollection object
            ModeratedForumCollection forums = new ModeratedForumCollection();
            ModeratedForum moderatedForum;

            while (dr.Read()) {

                moderatedForum = PopulateModeratedForumFromNpgsqlDataReader(dr);

                moderatedForum.TotalPosts = Convert.ToInt32(dr["totalposts"]);
                moderatedForum.TotalThreads = Convert.ToInt32(dr["totaltopics"]);
                moderatedForum.ForumGroupId = (int) dr["forumgroupid"];
                moderatedForum.TotalPostsAwaitingModeration = (int) dr["totalpostsawaitingmoderation"];

                // Handle Nulls in the case that we don't have a 'most recent post...'
                if (Convert.IsDBNull(dr["mostrecentpostauthor"]))
                    moderatedForum.MostRecentPostAuthor = null;
                else
                    moderatedForum.MostRecentPostAuthor = Convert.ToString(dr["mostrecentpostauthor"]);

                if (Convert.IsDBNull(dr["mostrecentpostid"])) {
                    moderatedForum.MostRecentPostId = 0;
                    moderatedForum.MostRecentThreadId = 0;
                } else {
                    moderatedForum.MostRecentPostId = Convert.ToInt32(dr["mostrecentpostid"]);
                    moderatedForum.MostRecentThreadId = Convert.ToInt32(dr["mostrecentthreadid"]);
                }

                if (Convert.IsDBNull(dr["mostrecentpostdate"]))
                    moderatedForum.MostRecentPostDate = DateTime.MinValue.AddMonths(1);
                else
                    moderatedForum.MostRecentPostDate = Convert.ToDateTime(dr["mostrecentpostdate"]);

                // Last time the user was active in the forum
                if (username != null) {
                    if (Convert.IsDBNull(dr["lastuseractivity"]))
                        moderatedForum.LastUserActivity = DateTime.MinValue.AddMonths(1);
                    else
                        moderatedForum.LastUserActivity = Convert.ToDateTime(dr["lastuseractivity"]);
                } else {
                    moderatedForum.LastUserActivity = DateTime.MinValue;
                }
            
                forums.Add(moderatedForum);

            }
            dr.Close();
            myConnection.Close();

            return forums;   
        }

        /****************************************************************
        // GetForumGroupsForModeration
        //
        /// <summary>
        /// Returns a forum group collection of all the forum groups containing
        /// forums that the current user has moderation abilities on.
        /// </summary>
        //
        ****************************************************************/
        public ForumGroupCollection GetForumGroupsForModeration(string username) {
            // Connect to the database
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallforumgroupsformoderation(:username)", myConnection);

            myCommand.CommandType = CommandType.StoredProcedure;

            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
    
            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // populate a ForumGroupCollection object
            ForumGroupCollection forumGroups = new ForumGroupCollection();
            ForumGroup forumGroup;

            while (dr.Read()) {
                forumGroup = PopulateForumGroupFromNpgsqlDataReader(dr);
                forumGroups.Add(forumGroup);
            }
            dr.Close();
            myConnection.Close();

            return forumGroups;
        }

        /****************************************************************
        // ToggleOptions
        //
        /// <summary>
        /// Allows use to change various settings without updating the profile directly
        /// </summary>
        //
        ****************************************************************/
        public void ToggleOptions(string username, bool hideReadThreads, ViewOptions viewOptions) {
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_toggleoptions(:username,:hidereadthreads,:flatview)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
            myCommand.Parameters.Add("hidereadthreads", NpgsqlTypes.NpgsqlDbType.Boolean).Value = hideReadThreads;

            if (ViewOptions.NotSet == viewOptions)
                myCommand.Parameters.Add("flatview", NpgsqlTypes.NpgsqlDbType.Boolean).Value = System.DBNull.Value;
            else if (ViewOptions.Threaded == viewOptions)
                myCommand.Parameters.Add("flatview", NpgsqlTypes.NpgsqlDbType.Boolean).Value = false;
            else
                myCommand.Parameters.Add("flatview", NpgsqlTypes.NpgsqlDbType.Boolean).Value = true;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();

            myConnection.Close();
        }

        /****************************************************************
        // ChangeForumGroupSortOrder
        //
        /// <summary>
        /// Used to move forums group sort order up or down
        /// </summary>
        //
        ****************************************************************/
        public void ChangeForumGroupSortOrder(int forumGroupID, bool moveUp) {
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_changeforumgroupsortorder(:forumgroupid,:moveup)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("forumgroupid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumGroupID;
            myCommand.Parameters.Add("moveup", NpgsqlTypes.NpgsqlDbType.Boolean).Value = moveUp;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();

            myConnection.Close();
        }

        /****************************************************************
        // UpdateMessageTemplate
        //
        /// <summary>
        /// update the message in the database
        /// </summary>
        //
        ****************************************************************/
        public void UpdateMessageTemplate(ForumMessage message) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updatemessagetemplatelist(:messageid,:title,:body)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("messageid", NpgsqlTypes.NpgsqlDbType.Integer).Value = message.MessageID;
            myCommand.Parameters.Add("title", NpgsqlTypes.NpgsqlDbType.Text, 128).Value = message.Title;
            myCommand.Parameters.Add("body", NpgsqlTypes.NpgsqlDbType.Text, 4000).Value = message.Body;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();

            myConnection.Close();

        }


        /****************************************************************
        // GetMessageTemplateList
        //
        /// <summary>
        /// Returns a collection of ForumMessages
        /// </summary>
        //
        ****************************************************************/
        public ForumMessageTemplateCollection GetMessageTemplateList() {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforummessagetemplatelist()", myConnection);
            NpgsqlDataReader reader;
            ForumMessageTemplateCollection messages = new ForumMessageTemplateCollection();
            ForumMessage message;


            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                message = new ForumMessage();

                message.MessageID = Convert.ToInt32(reader["messageid"]);
                message.Title = (string) reader["title"];
                message.Body = (string) reader["body"];

                messages.Add(message);

            }

            myConnection.Close();

            return messages;
        }

        /****************************************************************
        // GetUsernameByEmail
        //
        /// <summary>
        /// Returns the username given an email address
        /// </summary>
        //
        ****************************************************************/
        public string GetUsernameByEmail(string emailAddress) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getusernamebyemail(:email)", myConnection);
            NpgsqlDataReader reader;
            string username = null;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("email", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = emailAddress;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            while (reader.Read()) {
                username = (String) reader["username"];
            }

            myConnection.Close();

            return username;
        }


        /****************************************************************
        // ChangePasswordForLoggedOnUser
        //
        /// <summary>
        /// Change the password for the logged on user.
        /// </summary>
        //
        ****************************************************************/
        public void ChangePasswordForLoggedOnUser(string username, string newPassword) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_changeuserpassword(:username,:newpassword)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
            myCommand.Parameters.Add("newpassword", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = newPassword;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();

        }


        /****************************************************************
        // GetMessage
        //
        /// <summary>
        /// Returns a message to display to the user.
        /// </summary>
        //
        ****************************************************************/
        public ForumMessage GetMessage(int messageId) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getmessage(:messageid)", myConnection);
            ForumMessage message;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("messageid", NpgsqlTypes.NpgsqlDbType.Integer).Value = messageId;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            message = new ForumMessage();

            while (dr.Read()) {

                message.Title = Convert.ToString(dr["title"]);
                message.Body = Convert.ToString(dr["body"]);

            }
            dr.Close();
            myConnection.Close();

            return message;

        }

        
        /****************************************************************
        // GetModeratedPostsByForumId
        //
        /// <summary>
        /// Returns all the posts in a given forum that require moderation.
        /// </summary>
        //
        ****************************************************************/
        private  PostCollection GetModeratedPostsByForumId(int forumId) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_GetModeratedPostsByForumId", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumId;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            PostCollection posts = new PostCollection();
            Post post = null;

            while (dr.Read()) {
                post = PopulatePostFromNpgsqlDataReader(dr);
                post.ForumName = Convert.ToString(dr["forumname"]);

                posts.Add(post);
            }
            dr.Close();
            myConnection.Close();

            return posts;
        }

        /****************************************************************
        // GetForumsRequiringModeration
        //
        /// <summary>
        /// Returns a Moderated Foru
        /// </summary>
        //
        ****************************************************************/
        public ModeratedForumCollection GetForumsRequiringModeration(string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getmoderatedforums(:username)", myConnection);
            NpgsqlDataReader reader;
            ModeratedForumCollection moderatedForums = new ModeratedForumCollection();
            ModeratedForum moderatedForum;
            PostCollection posts;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            reader = myCommand.ExecuteReader();

            // Loop through the returned results
            while (reader.Read()) {

                // Populate all the forum details
                moderatedForum = new ModeratedForum();
                moderatedForum = (ModeratedForum) PopulateForumFromNpgsqlDataReader(reader);

                // Get all the posts in the forum awaiting moderation
                posts = new PostCollection();
                posts = GetModeratedPostsByForumId(moderatedForum.ForumID);
                moderatedForum.PostsAwaitingModeration = posts;
            }

            myConnection.Close();

            return moderatedForums;

        }


        /****************************************************************
        // MarkPostAsRead
        //
        /// <summary>
        /// Flags a post a 'read' in the database
        /// </summary>
        //
        ****************************************************************/
        public void MarkPostAsRead(int postID, string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_markpostasread(:postid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
 
        }

        /****************************************************************
        // GetTotalPostsForThread
        //
        /// <summary>
        /// Returns the total number of posts in a given thread. This call
        /// is used mainly by paging when viewing posts.
        /// </summary>
        //
        ****************************************************************/
        public int GetTotalPostsForThread(int postID) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettotalpostsforthread(:postid)", myConnection);
            int postCount = 0;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // Populate the colleciton of users
            while (dr.Read())
                postCount = Convert.ToInt32(dr["totalpostsforthread"]);

            dr.Close();
            myConnection.Close();
 
            return postCount;
        }


        /****************************************************************
        // GetAllUsers
        //
        /// <summary>
        /// Returns a collection of all users.
        /// </summary>
        //
        ****************************************************************/
        public UserCollection GetAllUsers(int pageIndex, int pageSize, Users.SortUsersBy sortBy, int sortOrder, string usernameBeginsWith) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallusers(:pageindex,:pagesize,:sortby,:sortorder,:usernamebeginswith)", myConnection);
            UserCollection users = new UserCollection();

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Pass sproc parameters
            myCommand.Parameters.Add("pageindex", NpgsqlTypes.NpgsqlDbType.Integer).Value = pageIndex;
            myCommand.Parameters.Add("pagesize", NpgsqlTypes.NpgsqlDbType.Integer).Value = pageSize;
            myCommand.Parameters.Add("sortby", NpgsqlTypes.NpgsqlDbType.Integer).Value = (int)sortBy;
            myCommand.Parameters.Add("sortorder", NpgsqlTypes.NpgsqlDbType.Boolean).Value = Convert.ToBoolean(sortOrder);

            if ((usernameBeginsWith == "All") || (usernameBeginsWith == null))
                myCommand.Parameters.Add("usernamebeginswith", NpgsqlTypes.NpgsqlDbType.Text, 1).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("usernamebeginswith", NpgsqlTypes.NpgsqlDbType.Text, 1).Value = usernameBeginsWith;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // Populate the colleciton of users
            while (dr.Read())
                users.Add(PopulateUserFromNpgsqlDataReader(dr));

            dr.Close();
            myConnection.Close();

            return users;
        }

        /****************************************************************
        // GetTotalThreadsInForum
        //
        /// <summary>
        /// Returns the total number of threads in a given forum
        /// </summary>
        /// <param name="username">forum id to look up</param>
        //
        ****************************************************************/
        public int GetTotalThreadsInForum(int ForumID, DateTime maxDateTime, DateTime minDateTime, string username, bool unreadThreadsOnly) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_topiccountforforum(:forumid,:maxdate,:mindate,:username,:unreadtopicsonly)", myConnection);
            int totalThreads = 0;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer).Value = ForumID;

            // Control the returned values by DateTime
            myCommand.Parameters.Add("maxdate", NpgsqlTypes.NpgsqlDbType.Timestamp).Value = maxDateTime;
            myCommand.Parameters.Add("mindate", NpgsqlTypes.NpgsqlDbType.Timestamp).Value = minDateTime;

            // Do we have a username?
			if (username == null) 
				myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
			else 
				myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
			
			// Return unread threads
            myCommand.Parameters.Add("unreadtopicsonly", NpgsqlTypes.NpgsqlDbType.Boolean).Value = unreadThreadsOnly;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            while (dr.Read())
                totalThreads = Convert.ToInt32(dr["totaltopics"]);

            dr.Close();
            myConnection.Close();

            return totalThreads;
        }

        /****************************************************************
        // AddUserToRole
        //
        /// <summary>
        /// Adds a user to a role to elevate their permissions
        /// </summary>
        /// <param name="username">The username of the user to add to the role</param>
        /// <param name="role">The role the user will be added to</param>
        //
        ****************************************************************/
        public void AddUserToRole(string username, string role)
        {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_addusertorole(:username,:rolename)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
            myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;

            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }

        /****************************************************************
        // AddForumToRole
        //
        /// <summary>
        /// Adds a forum to a given role
        /// </summary>
        /// <param name="forumID">The id for the forum to be added to the role</param>
        /// <param name="role">The role the user will be added to</param>
        //
        ****************************************************************/
        public void AddForumToRole(int forumID, string role)
        {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_addforumtorole(:forumid,:rolename)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = forumID;
            myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;

            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }

        /****************************************************************
        // RemoveUserFromRole
        //
        /// <summary>
        /// Removes a user from a permissions role.
        /// </summary>
        /// <param name="username">The username of the user to remove from the role</param>
        /// <param name="role">The role the user will be removed from</param>
        //
        ****************************************************************/
        public void RemoveUserFromRole(string username, string role)
        {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_removeuserfromrole(:username,:rolename)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
            myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;

            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }

        /****************************************************************
        // RemoveForumFromRole
        //
        /// <summary>
        /// Removes a forum from a given permissions role.
        /// </summary>
        /// <param name="forumID">The forum ID for the forum to remove from the role.</param>
        /// <param name="role">The role the user will be removed from</param>
        //
        ****************************************************************/
        public void RemoveForumFromRole(int forumID, string role)
        {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_removeforumfromrole(:forumid,:rolename)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = forumID;
            myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;

            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }

        /****************************************************************
        // CreateNewRole
        //
        /// <summary>
        /// Creates a new permissions role
        /// </summary>
        /// <param name="role">The name for the new permissions role</param>
        /// <param name="description">The description of the new role useful for administration</param>
        //
        ****************************************************************/
        public void CreateNewRole(string role, string description)
        {
            // Create Instance of Connection and Command Object
            using(NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString))
            {
                NpgsqlCommand myCommand = new NpgsqlCommand("forums_createnewrole(:rolename,:description)", myConnection);

                // Mark the Command as a SPROC
                myCommand.CommandType = CommandType.StoredProcedure;

                // Add Parameters to SPROC
                myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;
                myCommand.Parameters.Add("description", NpgsqlTypes.NpgsqlDbType.Text, 512).Value = description;

                myConnection.Open();
                myCommand.ExecuteNonQuery();
                myConnection.Close();
            }
        }

        /****************************************************************
        // DeleteRole
        //
        /// <summary>
        /// Deletes an existing role
        /// </summary>
        /// <param name="role">The name for the role to be deleted</param>
        //
        ****************************************************************/
        public void DeleteRole(string role)
        {
            // Create Instance of Connection and Command Object
            using(NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString))
            {
                NpgsqlCommand myCommand = new NpgsqlCommand("forums_deleterole(:rolename)", myConnection);

                // Mark the Command as a SPROC
                myCommand.CommandType = CommandType.StoredProcedure;

                // Add Parameters to SPROC
                myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;

                myConnection.Open();
                myCommand.ExecuteNonQuery();
                myConnection.Close();
            }
        }

        /****************************************************************
        // GetRoleDescription
        //
        /// <summary>
        /// Gets the description string for a role
        /// </summary>
        /// <param name="role">The name for the role a description is needed for</param>
        //
        ****************************************************************/
        public string GetRoleDescription(string role)
        {
            string roleDescription;

            // Create Instance of Connection and Command Object
            using(NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString))
            {
                NpgsqlCommand myCommand = new NpgsqlCommand("forums_getroledescription(:rolename)", myConnection);

                // Mark the Command as a SPROC
                myCommand.CommandType = CommandType.StoredProcedure;

                // Add Parameters to SPROC
                myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;

                myConnection.Open();
                roleDescription = (string) myCommand.ExecuteScalar();
                myConnection.Close();
            }

            return roleDescription;
        }

        /****************************************************************
        // UpdateRoleDescription
        //
        /// <summary>
        /// Updates the description of a given role for administration purposes
        /// </summary>
        /// <param name="role">The name of the permissions role to be updated</param>
        /// <param name="description">The new description of the role useful for administration</param>
        //
        ****************************************************************/
        public void UpdateRoleDescription(string role, string description)
        {
            // Create Instance of Connection and Command Object
            using(NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString))
            {
                NpgsqlCommand myCommand = new NpgsqlCommand("forums_updateroledescription(:rolename,:description)", myConnection);

                // Mark the Command as a SPROC
                myCommand.CommandType = CommandType.StoredProcedure;

                // Add Parameters to SPROC
                myCommand.Parameters.Add("rolename", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = role;
                myCommand.Parameters.Add("description", NpgsqlTypes.NpgsqlDbType.Text, 512).Value = description;

                myConnection.Open();
                myCommand.ExecuteNonQuery();
                myConnection.Close();
            }
        }

        /****************************************************************
        // GetUserRoles
        //
        /// <summary>
        /// Returns a string array of role names
        /// </summary>
        //
        ****************************************************************/
        public String[] GetAllRoles() 
        {
            string[] roles;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallroles()", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Open the database connection and execute the command
            NpgsqlDataReader dr;

            myConnection.Open();
            dr = myCommand.ExecuteReader();

            // create a String array from the data
            ArrayList userRoles = new ArrayList();

            while (dr.Read()) 
            {
                userRoles.Add(dr["rolename"]);
            }

            dr.Close();

            // Return the String array of roles
            roles = (String[]) userRoles.ToArray(typeof(String));

            // Close the connection
            myConnection.Close();

            return roles;
        }
            
        /****************************************************************
        // GetUserRoles
        //
        /// <summary>
        /// Returns a string array of role names that the user belongs to
        /// </summary>
        /// <param name="username">username to find roles for</param>
        //
        ****************************************************************/
        public String[] GetUserRoles(string username) 
        {
            string[] roles;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getrolesbyuser(:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Open the database connection and execute the command
            NpgsqlDataReader dr;

            myConnection.Open();
            dr = myCommand.ExecuteReader();

            // create a String array from the data
            ArrayList userRoles = new ArrayList();

            while (dr.Read()) {
                userRoles.Add(dr["rolename"]);
            }

            dr.Close();

            // Return the String array of roles
            roles = (string[]) userRoles.ToArray(typeof(String));

            myConnection.Close();

            return roles;
        }

        /****************************************************************
        // GetUserRoles
        //
        /// <summary>
        /// Returns a string array of role names that the user belongs to
        /// </summary>
        /// <param name="username">username to find roles for</param>
        //
        ****************************************************************/
        public String[] GetForumRoles(int forumID) 
        {
            string[] roles;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getrolesbyforum(:forumid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = forumID;

            // Open the database connection and execute the command
            NpgsqlDataReader dr;

            myConnection.Open();
            dr = myCommand.ExecuteReader();

            // create a String array from the data
            ArrayList forumRoles = new ArrayList();

            while (dr.Read()) 
            {
                forumRoles.Add(dr["rolename"]);
            }

            dr.Close();

            // Return the String array of roles
            roles = (string[]) forumRoles.ToArray(typeof(String));

            myConnection.Close();

            return roles;
        }

        /****************************************************************
        // TrackAnonymousUsers
        //
        /// <summary>
        /// Keep track of anonymous users.
        /// </summary>
        /// <param name="userId">user id to uniquely identify the user</param>
        //
        ****************************************************************/
        public void TrackAnonymousUsers(string userId) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_trackanonymoususers(:userid)", myConnection);
            NpgsqlParameter param;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            param = new NpgsqlParameter("userid", NpgsqlTypes.NpgsqlDbType.Text, 36);
            param.Value = userId;
            myCommand.Parameters.Add(param);

            // Open the connection
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }

        /****************************************************************
        // GetForumGroupByForumId
        //
        /// <summary>
        /// Returns the name of a forum group based on the id of the forum.
        /// </summary>
        /// <param name="forumGroupName">ID of the forum group to lookup</param>
        //
        ****************************************************************/
        public ForumGroup GetForumGroupByForumId(int forumID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumgroupbyforumid(:forumid)", myConnection);
            NpgsqlDataReader dr;
            ForumGroup forumGroup = null;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumID;

            // Open the connection
            myConnection.Open();

            dr = myCommand.ExecuteReader();

            if (dr.Read())
                forumGroup = PopulateForumGroupFromNpgsqlDataReader(dr);

            myConnection.Close();

            return forumGroup;
        }

        /****************************************************************
        // AddForumGroup
        //
        /// <summary>
        /// Creates a new forum group, and exception is raised if the
        /// forum group already exists.
        /// </summary>
        /// <param name="forumGroupName">Name of the forum group to create</param>
        //
        ****************************************************************/
        public void AddForumGroup(string forumGroupName) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_addforumgroup(:forumgroupname)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter param = new NpgsqlParameter("forumgroupname", NpgsqlTypes.NpgsqlDbType.Text, 256);
            param.Value = forumGroupName;
            myCommand.Parameters.Add(param);

            // Open the connection
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();

        }

        /****************************************************************
        // MarkAllThreadsRead
        //
        /// <summary>
        /// Marks all threads from Forum ID and below as read
        /// </summary>
        //
        *****************************************************************/
        public void MarkAllThreadsRead(int forumID, string username) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_markallthreadsread(:forumid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter param = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer);
            param.Value = forumID;
            myCommand.Parameters.Add(param);

            param = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = username;
            myCommand.Parameters.Add(param);


            // Open the connection
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }


        /****************************************************************
        // UpdateForumGroup
        //
        /// <summary>
        /// Updates the name of an existing forum group
        /// </summary>
        /// <param name="forumGroupName">New name for the forum group</param>
        /// <param name="forumGroupId">Unique identifier for the forum group to update</param>
        //
        *****************************************************************/
        public void UpdateForumGroup(string forumGroupName, int forumGroupId) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updateforumgroup(:forumgroupname,:forumgroupid)", myConnection);
            NpgsqlParameter param;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            param = new NpgsqlParameter("forumgroupname", NpgsqlTypes.NpgsqlDbType.Text, 256);
            
            // If forumGroupName is null we want to delete
            if (null == forumGroupName)
                param.Value = System.DBNull.Value;
            else
                param.Value = forumGroupName;
            
            myCommand.Parameters.Add(param);

            // Add Parameters to SPROC
            param = new NpgsqlParameter("forumgroupid", NpgsqlTypes.NpgsqlDbType.Integer);
            param.Value = forumGroupId;
            myCommand.Parameters.Add(param);

            // Open the connection
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }


        /// <summary>
        /// Builds and returns an instance of the Post class based on the current row of an
        /// aptly populated NpgsqlDataReader object.
        /// </summary>
        /// <param name="dr">The NpgsqlDataReader object that contains, at minimum, the following
        /// columns: PostID, ParentID, Body, ForumID, PostDate, PostLevel, SortOrder, Subject,
        /// ThreadDate, ThreadID, Replies, Username, and Approved.</param>
        /// <returns>An instance of the Post class that represents the current row of the passed 
        /// in NpgsqlDataReader, dr.</returns>
        private Post PopulatePostFromNpgsqlDataReader(NpgsqlDataReader dr) {

            Post post = new Post();
            post.PostID = Convert.ToInt32(dr["postid"]);
            post.ParentID = Convert.ToInt32(dr["parentid"]);
            post.Body = Convert.ToString(dr["body"]);
            post.ForumName = Convert.ToString(dr["forumname"]);
            post.ForumID = Convert.ToInt32(dr["forumid"]);
            post.PostDate = Convert.ToDateTime(dr["postdate"]);
            post.PostLevel = Convert.ToInt32(dr["postlevel"]);
            post.SortOrder = Convert.ToInt32(dr["sortorder"]);
            post.Subject = Convert.ToString(dr["subject"]);
            post.ThreadDate = Convert.ToDateTime(dr["threaddate"]);
            post.ThreadID = Convert.ToInt32(dr["threadid"]);
            post.Replies = Convert.ToInt32(dr["replies"]);
            post.Username = Convert.ToString(dr["username"]);
            post.Approved = Convert.ToBoolean(dr["approved"]);
            post.IsLocked = Convert.ToBoolean(dr["islocked"]);
            post.Views = Convert.ToInt32(dr["totalviews"]);
            post.HasRead = Convert.ToBoolean(dr["hasread"]);
            
            return post;
        }

        
        // *********************************************************************
        //
        //  PopulateThreadFromNpgsqlDataReader
        //
        /// <summary>
        /// This private method accepts a datareader and attempts to create and
        /// populate a thread class instance which is returned to the caller. For
        /// all practical purposes, a thread is simply a lightweigh version of a 
        /// post - no details, such as the body, are provided though and a thread is
        /// always considered the first post in a thread.
        /// </summary>
        //
        // ********************************************************************/
        private Thread PopulateThreadFromNpgsqlDataReader(NpgsqlDataReader reader) {
            Thread thread = new Thread();

            thread.PostID = Convert.ToInt32(reader["postid"]);
            thread.PostDate = Convert.ToDateTime(reader["postdate"]);
            thread.Subject = Convert.ToString(reader["subject"]);
            thread.Body = Convert.ToString(reader["body"]);
            thread.ThreadDate = Convert.ToDateTime(reader["threaddate"]);
            thread.PinnedDate = Convert.ToDateTime(reader["pinneddate"]);
            thread.Replies = Convert.ToInt32(reader["replies"]);
            thread.Username = Convert.ToString(reader["username"]);
            thread.IsLocked = Convert.ToBoolean(reader["islocked"]);
            thread.IsPinned = Convert.ToBoolean(reader["ispinned"]);
            thread.Views = Convert.ToInt32(reader["totalviews"]);
            thread.HasRead = Convert.ToBoolean(reader["hasread"]);
            thread.MostRecentPostAuthor = Convert.ToString(reader["mostrecentpostauthor"]);
            thread.MostRecentPostID = Convert.ToInt32(reader["mostrecentpostid"]);
            thread.ThreadID = Convert.ToInt32(reader["threadid"]);

            return thread;
        }


        /// <summary>
        /// Builds and returns an instance of the Forum class based on the current row of an
        /// aptly populated NpgsqlDataReader object.
        /// </summary>
        /// <param name="dr">The NpgsqlDataReader object that contains, at minimum, the following
        /// columns: ForumID, DateCreated, Description, Name, Moderated, and DaysToView.</param>
        /// <returns>An instance of the Forum class that represents the current row of the passed 
        /// in NpgsqlDataReader, dr.</returns>
        private  Forum PopulateForumFromNpgsqlDataReader(NpgsqlDataReader dr) {
            Forum forum = new Forum();
            forum.ForumID = Convert.ToInt32(dr["forumid"]);
            forum.ParentId = Convert.ToInt32(dr["parentid"]);
            forum.ForumGroupId = Convert.ToInt32(dr["forumgroupid"]);
            forum.DateCreated = Convert.ToDateTime(dr["datecreated"]);
            forum.Description = Convert.ToString(dr["description"]);
            forum.Name = Convert.ToString(dr["name"]);
            forum.Moderated = Convert.ToBoolean(dr["moderated"]);
            forum.DaysToView = Convert.ToInt32(dr["daystoview"]);
            forum.Active = Convert.ToBoolean(dr["active"]);
            forum.SortOrder = Convert.ToInt32(dr["sortorder"]);
            forum.IsPrivate = Convert.ToBoolean(dr["isprivate"]);
            //Encoding en = Encoding.Default;
			//forum.DisplayMask = en.GetBytes((string)dr["displaymask"]);
			//TODO Handle byte arrays from postgres - JMH
			//forum.DisplayMask = new byte[16];
			forum.DisplayMask = (byte[]) dr["displaymask"];
            return forum;
        }

        private  ModeratedForum PopulateModeratedForumFromNpgsqlDataReader(NpgsqlDataReader dr) {
            ModeratedForum forum = new ModeratedForum();
            forum.ForumID = Convert.ToInt32(dr["forumid"]);
            forum.ForumGroupId = Convert.ToInt32(dr["forumgroupid"]);
            forum.DateCreated = Convert.ToDateTime(dr["datecreated"]);
            forum.Description = Convert.ToString(dr["description"]);
            forum.Name = Convert.ToString(dr["name"]);
            forum.Moderated = Convert.ToBoolean(dr["moderated"]);
            forum.DaysToView = Convert.ToInt32(dr["daystoview"]);
            forum.Active = Convert.ToBoolean(dr["active"]);
            forum.SortOrder = Convert.ToInt32(dr["sortorder"]);
            forum.IsPrivate = Convert.ToBoolean(dr["isprivate"]);

            return forum;
        }
        
        private ForumGroup PopulateForumGroupFromNpgsqlDataReader(NpgsqlDataReader dr) {

            ForumGroup forumGroup = new ForumGroup();
            forumGroup.ForumGroupID = (int) dr["forumgroupid"];
            forumGroup.Name = (string) dr["name"];
            forumGroup.SortOrder = Convert.ToInt32(dr["sortorder"]);

            return forumGroup;
        }
    

        /// <summary>
        /// Builds and returns an instance of the User class based on the current row of an
        /// aptly populated NpgsqlDataReader object.
        /// </summary>
        /// <param name="dr">The NpgsqlDataReader object that contains, at minimum, the following
        /// columns: Signature, Email, FakeEmail, Url, Password, Username, Administrator, Approved,
        /// Trusted, Timezone, DateCreated, LastLogin, and ForumView.</param>
        /// <returns>An instance of the User class that represents the current row of the passed 
        /// in NpgsqlDataReader, dr.</returns>
        private User PopulateUserFromNpgsqlDataReader(NpgsqlDataReader dr) {
            User user = new User();
            user.Signature = Convert.ToString(dr["signature"]);
            user.Email = Convert.ToString(dr["email"]);
            user.PublicEmail = Convert.ToString(dr["fakeemail"]);
            user.Url = Convert.ToString(dr["url"]);
            user.Password = Convert.ToString(dr["password"]);
            user.Username = Convert.ToString(dr["username"]);
            user.IsApproved = Convert.ToBoolean(dr["approved"]);
            user.IsProfileApproved = Convert.ToBoolean(dr["profileapproved"]);
            user.IsTrusted = Convert.ToBoolean(dr["trusted"]);
            user.Timezone = Convert.ToInt32(dr["timezone"]);
            user.DateCreated = Convert.ToDateTime(dr["datecreated"]);
            user.LastLogin = Convert.ToDateTime(dr["lastlogin"]);
            user.LastActivity = Convert.ToDateTime(dr["lastactivity"]);
            user.TrackPosts = Convert.ToBoolean(dr["trackyourposts"]);
            user.Location = (string) dr["location"];
            user.Occupation = (string) dr["occupation"];
            user.Interests = (string) dr["interests"];
            user.MsnIM = (string) dr["msn"];
            user.AolIM = (string) dr["aim"];
            user.YahooIM = (string) dr["yahoo"];
            user.IcqIM = (string) dr["icq"];
            user.TotalPosts = (int) dr["totalposts"];
            user.HasAvatar = (bool) dr["hasavatar"];
            user.HideReadThreads = (bool) dr["showunreadtopicsonly"];
            user.Skin = (string) dr["style"];
            user.Avatar = (AspNetForums.Components.AvatarType) (int) dr["avatartype"];
            user.AvatarUrl = (string) dr["avatarurl"];
            user.ShowAvatar = (bool) dr["showavatar"];
            user.DateFormat = (string) dr["dateformat"];
            user.ShowPostsAscending = (bool) dr["postvieworder"];
            user.ViewPostsInFlatView = (bool) dr["flatview"];
            user.IsModerator = Convert.ToBoolean(dr["ismoderator"]);
            user.Attributes = (byte[]) dr["attributes"];
			//Encoding en = Encoding.Unicode;
			//string uni = (string)dr["attributes"];
			//user.Attributes = en.GetBytes(uni);  
            //TODO Handle byte arrays from postgres - JMH
			//user.Attributes = new byte[4];       
            switch (Convert.ToInt32(dr["forumview"])) {
                case 0:
                    user.ForumView = ViewOptions.Flat;
                    break;

                case 1:
                    user.ForumView = ViewOptions.Mixed;
                    break;

                case 2:
                    user.ForumView = ViewOptions.Threaded;
                    break;

                default:
                    user.ForumView = ViewOptions.NotSet;
                    break;
            }
            
            return user;
        }


        
        /// <summary>
        /// Builds and returns an instance of the EmailTemplate class based on the current row of an
        /// aptly populated NpgsqlDataReader object.
        /// </summary>
        /// <param name="dr">The NpgsqlDataReader object that contains, at minimum, the following
        /// columns: EmailID, Subject, Message, FromAddress, Importance, and Description.</param>
        /// <returns>An instance of the EmailTemplate class that represents the current row of the passed 
        /// in NpgsqlDataReader, dr.</returns>
        private  EmailTemplate PopulateEmailTemplateFromNpgsqlDataReader(NpgsqlDataReader dr) {
            EmailTemplate email = new EmailTemplate();
            
            email.EmailTemplateID = Convert.ToInt32(dr["emailid"]);
            email.Subject = Convert.ToString(dr["subject"]);
            email.Body = Convert.ToString(dr["message"]);
            email.From = Convert.ToString(dr["fromaddress"]);
            email.Description = Convert.ToString(dr["description"]);

            switch (Convert.ToInt32(dr["importance"])) {
                case 0:
                    email.Priority = MailPriority.Low;
                    break;

                case 2:
                    email.Priority = MailPriority.High;
                    break;

                default:        // the default
                    email.Priority = MailPriority.Normal;
                    break;
            }

            return email;
        }
        /*********************************************************************************/


        /*********************************************************************************/

        /************************ POST FUNCTIONS ***********************
                 * These functions return information about a post or posts.  They
                 * are called from the WebForums.Posts class.
                 * *************************************************************/
        public ThreadCollection GetAllThreads(int forumID, string username, bool unreadThreadsOnly) {

            // TODO - might want to do some more work here
            return GetAllThreads(forumID, 9999, 0, DateTime.Now.AddYears(-20), username, unreadThreadsOnly);

        }


        public ThreadCollection GetAllThreads(int forumID, int pageSize, int pageIndex, DateTime endDate, string username, bool unreadThreadsOnly) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getalltopicspaged(:forumid,:pagesize,:pageindex,:datefilter,:username,:unreadtopicsonly)", myConnection);
            ThreadCollection threads;

            // Ensure DateTime is min value for SQL
            if (endDate == DateTime.MinValue)
                endDate = (DateTime) System.Data.SqlTypes.SqlDateTime.MinValue;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = forumID;
            myCommand.Parameters.Add("pagesize", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = pageSize;
            myCommand.Parameters.Add("pageindex", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = pageIndex;
            myCommand.Parameters.Add("datefilter", NpgsqlTypes.NpgsqlDbType.Timestamp).Value = endDate;
            
            // Only pass username if it's not null
            if (username == null)
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            myCommand.Parameters.Add("unreadtopicsonly", NpgsqlTypes.NpgsqlDbType.Boolean).Value = unreadThreadsOnly;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            threads = new ThreadCollection();

            while (dr.Read()) {
                threads.Add(PopulateThreadFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            // Only return the posts specified through paging

            return threads;

        }

        /// <summary>
        /// Returns all of the messages for a particular page of posts for a paticular forum in a
        /// particular ForumView mode.
        /// </summary>
        /// <param name="ForumID">The ID of the Forum whose posts you wish to display.</param>
        /// <param name="ForumView">How to display the Forum posts.  The ViewOptions enumeration
        /// supports one of three values: Flat, Mixed, and Threaded.</param>
        /// <param name="PagesBack">How many pages back of data to display.  A value of 0 displays
        /// the posts from the current time to a time that is the Forum's DaysToView days prior to the
        /// current day.</param>
        /// <returns>A PostCollection object containing all of the posts.</returns>
        public  PostCollection GetAllMessages(int ForumID, ViewOptions ForumView, int PagesBack) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallmessages(:forumid,:viewtype,:pagesback)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterForumId = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumId.Value = ForumID;
            myCommand.Parameters.Add(parameterForumId);

            NpgsqlParameter parameterViewType = new NpgsqlParameter("viewtype", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterViewType.Value = (int) ForumView;
            myCommand.Parameters.Add(parameterViewType);

            NpgsqlParameter parameterPagesBack = new NpgsqlParameter("pagesback", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPagesBack.Value = PagesBack;
            myCommand.Parameters.Add(parameterPagesBack);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            PostCollection posts = new PostCollection();
            while (dr.Read()) {
                posts.Add(PopulatePostFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            return posts;
        }

        /// <summary>
        /// Returns all of the messages for a particular page of posts for a paticular forum in a
        /// particular ForumView mode.
        /// </summary>
        /// <param name="ForumID">The ID of the Forum whose posts you wish to display.</param>
        /// <param name="ForumView">How to display the Forum posts.  The ViewOptions enumeration
        /// supports one of three values: Flat, Mixed, and Threaded.</param>
        /// <param name="PagesBack">How many pages back of data to display.  A value of 0 displays
        /// the posts from the current time to a time that is the Forum's DaysToView days prior to the
        /// current day.</param>
        /// <returns>A PostCollection object containing all of the posts.</returns>
        public  PostCollection GetSubjectsByForum(int ForumID, ViewOptions ForumView, int PagesBack) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallmessages(:forumid,:viewtype,:pagesback)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterForumId = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumId.Value = ForumID;
            myCommand.Parameters.Add(parameterForumId);

            NpgsqlParameter parameterViewType = new NpgsqlParameter("viewtype", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterViewType.Value = (int) ForumView;
            myCommand.Parameters.Add(parameterViewType);

            NpgsqlParameter parameterPagesBack = new NpgsqlParameter("pagesback", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPagesBack.Value = PagesBack;
            myCommand.Parameters.Add(parameterPagesBack);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            PostCollection posts = new PostCollection();
            while (dr.Read()) {
                posts.Add(PopulatePostFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            return posts;
        }

        /// is the user tracking this thread?
        public bool IsUserTrackingThread(int threadID, string username) {

            bool userIsTrackingPost = false; 

            // If username is null, don't continue
            if (username == null)
                return userIsTrackingPost;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_isusertrackingpost(:threadid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("threadid", NpgsqlTypes.NpgsqlDbType.Integer).Value = threadID;
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read())
                return userIsTrackingPost;

            userIsTrackingPost = Convert.ToBoolean(dr["isusertrackingpost"]);

            dr.Close();
            myConnection.Close();

            return userIsTrackingPost;
        }

        /// <summary>
        /// Gets the details for a particular post.  These details include the IDs of the next/previous
        /// post and the next/prev thread, along with information about the user who posted the post.
        /// </summary>
        /// <param name="PostID">The ID of the Post to get the information from.</param>
        /// <param name="Username">The Username of the person viewing the post.  Used to determine if
        /// the particular user has email tracking turned on for the thread that this message resides.</param>
        /// <returns>A PostDetails instance with rich information about the particular post.</returns>
        /// <remarks>If a PostID is passed in that is NOT found in the database, a PostNotFoundException
        /// exception is thrown.</remarks>
        public  PostDetails GetPostDetails(int postID, String username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getsinglemessage(:postid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;

            if ( (username == null) || (username == String.Empty))
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read())
                // we did not get back a post
                throw new Components.PostNotFoundException("Did not get back a post for PostID " + postID.ToString());

            // we have a post to work with
            PostDetails post = new PostDetails();
            post.PostID = postID;
            post.ParentID = Convert.ToInt32(dr["parentid"]);
            post.Body = Convert.ToString(dr["body"]);
            post.ForumID = Convert.ToInt32(dr["forumid"]);
            post.PostDate = Convert.ToDateTime(dr["postdate"]);
            post.PostLevel = Convert.ToInt32(dr["postlevel"]);
            post.SortOrder = Convert.ToInt32(dr["sortorder"]);
            post.Subject = Convert.ToString(dr["subject"]);
            post.ThreadDate = Convert.ToDateTime(dr["threaddate"]);
            post.ThreadID = Convert.ToInt32(dr["threadid"]);
            post.Replies = Convert.ToInt32(dr["replies"]);
            post.Username = Convert.ToString(dr["username"]);
            post.NextPostID = Convert.ToInt32(dr["nextpostid"]);
            post.PrevPostID = Convert.ToInt32(dr["prevpostid"]);
            post.NextThreadID = Convert.ToInt32(dr["nextthreadid"]);
            post.PrevThreadID = Convert.ToInt32(dr["prevthreadid"]);
            post.ThreadTracking = Convert.ToBoolean(dr["useristrackingthread"]);
            post.ForumName = Convert.ToString(dr["forumname"]);
            post.IsLocked = Convert.ToBoolean(dr["islocked"]);

            // populate information about the User
            User user = new User();
            user.Username = post.Username;
            user.PublicEmail = Convert.ToString(dr["fakeemail"]);
            user.Url = Convert.ToString(dr["url"]);
            user.Signature = Convert.ToString(dr["signature"]);
            
            post.UserInfo = user;

            dr.Close();
            myConnection.Close();

            return post;
        }


        /// <summary>
        /// Returns count of all posts in system
        /// </summary>
        /// <returns></returns>
        public int GetTotalPostCount() {
            int totalPostCount;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettotalpostcount()", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            dr.Read();
            
            totalPostCount = (int) dr[0];

            dr.Close();
            myConnection.Close();

            return totalPostCount;
        }

        /// <summary>
        /// Get basic information about a single post.  This method returns an instance of the Post class,
        /// which contains less information than the PostDeails class, which is what is returned by the
        /// GetPostDetails method.
        /// </summary>
        /// <param name="PostID">The ID of the post whose information we are interested in.</param>
        /// <returns>An instance of the Post class.</returns>
        /// <remarks>If a PostID is passed in that is NOT found in the database, a PostNotFoundException
        /// exception is thrown.</remarks>
        public  Post GetPost(int postID, string username, bool trackViews) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getpostinfo(:postid,:trackviews,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;
            myCommand.Parameters.Add("trackviews", NpgsqlTypes.NpgsqlDbType.Boolean).Value = trackViews;

            if (username == null)
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read()) {
                dr.Close();
                myConnection.Close();
                // we did not get back a post
                throw new Components.PostNotFoundException("Did not get back a post for PostID " + postID.ToString());
            }

            Post p = PopulatePostFromNpgsqlDataReader(dr);
            dr.Close();
            myConnection.Close();


            // we have a post to work with  
            return p;
        }


    
        /// <summary>
        /// Reverses a particular user's email thread tracking options for the thread that contains
        /// the post specified by PostID.  That is, if a User has email thread tracking turned on for
        /// a particular thread, a call to this method will turn off the email thread tracking; conversely,
        /// if a user has thread tracking turned off for a particular thread, a call to this method will
        /// turn it on.
        /// </summary>
        /// <param name="Username">The User whose email thread tracking options we wish to reverse.</param>
        /// <param name="PostID"></param>
        public  void ReverseThreadTracking(String Username, int PostID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_reversetrackingoption(:username, :postid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = Username;
            myCommand.Parameters.Add(parameterUsername);

            NpgsqlParameter parameterPostId = new NpgsqlParameter("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPostId.Value = PostID;
            myCommand.Parameters.Add(parameterPostId);

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }



        /// <summary>
        /// Returns a collection of Posts that make up a particular thread.
        /// </summary>
        /// <param name="ThreadID">The ID of the Thread to retrieve the posts of.</param>
        /// <returns>A PostCollection object that contains the posts in the thread specified by
        /// ThreadID.</returns>
        public  PostCollection GetThread(int ThreadID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getthread(:threadid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterThreadId = new NpgsqlParameter("threadid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterThreadId.Value = ThreadID;
            myCommand.Parameters.Add(parameterThreadId);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // loop through the results
            PostCollection posts = new PostCollection();
            while (dr.Read()) {
                posts.Add(PopulatePostFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            return posts;
        }


        /// <summary>
        /// Returns a collection of Posts that make up a particular thread with paging
        /// </summary>
        /// <param name="PostID">The ID of a Post in the thread that you are interested in retrieving.</param>
        /// <returns>A PostCollection object that contains the posts in the thread.</returns>
        public PostCollection GetThreadByPostID(int postID, int currentPageIndex, int pageSize, int sortBy, int sortOrder, string username) {
            NpgsqlParameter param;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getthreadbypostidpaged(:postid,:pageindex,:pagesize,:sortby,:sortorder,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // PostID Parameter
            param = new NpgsqlParameter("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            param.Value = postID;
            myCommand.Parameters.Add(param);

            // CurrentPage Parameter
            param = new NpgsqlParameter("pageindex", NpgsqlTypes.NpgsqlDbType.Integer);
            param.Value = currentPageIndex;
            myCommand.Parameters.Add(param);

            // PageSize Parameter
            param = new NpgsqlParameter("pagesize", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            param.Value = pageSize;
            myCommand.Parameters.Add(param);

            // Username
            if ( (username == null) || (username == String.Empty))
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Sort by
            myCommand.Parameters.Add("sortby", NpgsqlTypes.NpgsqlDbType.Integer).Value = sortBy;

            // Sort order
            myCommand.Parameters.Add("sortorder", NpgsqlTypes.NpgsqlDbType.Integer).Value = sortOrder;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // loop through the results
            PostCollection posts = new PostCollection();
            while (dr.Read()) {
                Post p = PopulatePostFromNpgsqlDataReader(dr);
                p.PostType = (Posts.PostType) dr["posttype"];
                posts.Add(p);
            }

            dr.Close();
            myConnection.Close();

            return posts;
        }

        
        /// <summary>
        /// Returns a collection of Posts that make up a particular thread.
        /// </summary>
        /// <param name="PostID">The ID of a Post in the thread that you are interested in retrieving.</param>
        /// <returns>A PostCollection object that contains the posts in the thread.</returns>
        public  PostCollection GetThreadByPostID(int postID, string username) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getthreadbypostid(:postid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer).Value = postID;

            if ( (username == null) || (username == String.Empty))
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // loop through the results
            PostCollection posts = new PostCollection();
            while (dr.Read()) {
                posts.Add(PopulatePostFromNpgsqlDataReader(dr));
            }

            dr.Close();
            myConnection.Close();

            return posts;
        }




        /// <summary>
        /// Adds a new Post.  This method checks the allowDuplicatePosts settings to determine whether
        /// or not to allow for duplicate posts.  If allowDuplicatePosts is set to false and the user
        /// attempts to enter a duplicate post, a PostDuplicateException exception is thrown.
        /// </summary>
        /// <param name="PostToAdd">A Post object containing the information needed to add a new
        /// post.  The essential fields of the Post class that must be set are: the Subject, the
        /// Body, the Username, and a ForumID or a ParentID (depending on whether the post to add is
        /// a new post or a reply to an existing post, respectively).</param>
        /// <returns>A Post object with information on the newly inserted post.  This returned Post
        /// object includes the ID of the newly added Post (PostID) as well as if the Post is
        /// Approved or not.</returns>
        public Post AddPost(Post postToAdd, string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlParameter param;
            myConnection.Open();

            NpgsqlParameter parameterUserName = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUserName.Value = postToAdd.Username;

            NpgsqlParameter parameterBody = new NpgsqlParameter("body", NpgsqlTypes.NpgsqlDbType.Text);
            parameterBody.Value = postToAdd.Body;

	     if (!Globals.AllowDuplicatePosts) {
                NpgsqlCommand checkForDupsCommand = new NpgsqlCommand("forums_isduplicatepost(:username,:body)", myConnection);
                checkForDupsCommand.CommandType = CommandType.StoredProcedure;  // Mark the Command as a SPROC
                checkForDupsCommand.Parameters.Add(parameterUserName);
                checkForDupsCommand.Parameters.Add(parameterBody);

                if (((int) checkForDupsCommand.ExecuteScalar()) > 0) {
                    myConnection.Close();
                    throw new PostDuplicateException("Attempting to insert a duplicate post.");
                }

                checkForDupsCommand.Parameters.Clear();         // clear the parameters
            }

            NpgsqlCommand myCommand = new NpgsqlCommand("forums_addpost(:forumid,:replytopostid,:subject,:username,:body,:islocked,:pinned)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterForumId = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumId.Value = postToAdd.ForumID;
            myCommand.Parameters.Add(parameterForumId);

            NpgsqlParameter parameterPostId = new NpgsqlParameter("replytopostid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPostId.Value = postToAdd.ParentID;
            myCommand.Parameters.Add(parameterPostId);

            NpgsqlParameter parameterSubject = new NpgsqlParameter("subject", NpgsqlTypes.NpgsqlDbType.Text, 256);
            parameterSubject.Value = postToAdd.Subject;
            myCommand.Parameters.Add(parameterSubject);

            param = new NpgsqlParameter("islocked", NpgsqlTypes.NpgsqlDbType.Boolean);
            param.Value = postToAdd.IsLocked;
            myCommand.Parameters.Add(param);

            param = new NpgsqlParameter("pinned", NpgsqlTypes.NpgsqlDbType.Timestamp);
            if (postToAdd.PostDate > DateTime.Now)
                param.Value = postToAdd.PostDate;
            else
                param.Value = System.DBNull.Value;
            myCommand.Parameters.Add(param);

            myCommand.Parameters.Add(parameterUserName);
            myCommand.Parameters.Add(parameterBody);

            // Execute the command
            int iNewPostID = 0;
        
            try {
                // Get the new PostID
                iNewPostID = Convert.ToInt32(myCommand.ExecuteScalar().ToString());
            } 
            catch (Exception e) {
                myConnection.Close();
                // if an exception occurred, throw it back
                throw new Exception(e.Message);
            }

            myConnection.Close();
            
            // Return a Post instance with info from the newly inserted post.
            return GetPost(iNewPostID, username, false);
        }

        

        /// <summary>
        /// Updates a post.
        /// </summary>
        /// <param name="UpdatedPost">The Post data used to update the Post.  The ID of the UpdatedPost
        /// Post object corresponds to what post is to be updated.  The only other fields used to update
        /// the Post are the Subject and Body.</param>
        public void UpdatePost(Post post, string editedBy) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updatepost(:postid,:subject,:body,:islocked,:editedby)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = post.PostID;
            myCommand.Parameters.Add("subject", NpgsqlTypes.NpgsqlDbType.Text, 256).Value = post.Subject;
            myCommand.Parameters.Add("body", NpgsqlTypes.NpgsqlDbType.Text).Value = post.Body;
            myCommand.Parameters.Add("islocked", NpgsqlTypes.NpgsqlDbType.Boolean).Value = post.IsLocked;
            myCommand.Parameters.Add("editedby", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = editedBy;

            // Execute the command
            myConnection.Open();
            try {
                myCommand.ExecuteNonQuery();
            } 
            catch (Exception e) {
                myConnection.Close();
                // oops, something went wrong
                throw new Exception(e.Message);
            }
            myConnection.Close();
        }


        
        /// <summary>
        /// This method deletes a particular post and all of its replies.
        /// </summary>
        /// <param name="postID">The PostID that you wish to delete.</param>
        public void DeletePost(int postID, string approvedBy, string reason) {
            // Delete the post
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_deletemoderatedpost(:postid,:approvedby,:reason)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = postID;
            myCommand.Parameters.Add("approvedby", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = approvedBy;
            myCommand.Parameters.Add("reason", NpgsqlTypes.NpgsqlDbType.Text, 1024).Value = reason;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }




        /*********************************************************************************/

        /************************ FORUM FUNCTIONS ***********************
                 * These functions return information about a forum.
                 * are called from the WebForums.Forums class.
                 * **************************************************************/
    
        /// <summary>
        /// Returns information about a particular forum that contains a particular thread.
        /// </summary>
        /// <param name="ThreadID">The ID of the thread that is contained in the Forum you wish to
        /// retrieve information about.</param>
        /// <returns>A Forum object instance containing the information about the Forum that the
        /// specified thread exists in.</returns>
        /// <remarks>If a ThreadID is passed in that is NOT found in the database, a ForumNotFoundException
        /// exception is thrown.</remarks>
        public  Forum GetForumInfoByThreadID(int ThreadID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumbythreadid(:threadid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterThreadId = new NpgsqlParameter("threadid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterThreadId.Value = ThreadID;
            myCommand.Parameters.Add(parameterThreadId);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read()) {
                dr.Close();
                myConnection.Close();
                // we didn't get a forum, handle it
                throw new Components.ForumNotFoundException("Did not get back a forum for ThreadID " + ThreadID.ToString());
            } 

            Forum f = PopulateForumFromNpgsqlDataReader(dr);
            dr.Close();
            myConnection.Close();

            return f;
        }



        /// <summary>
        /// Returns a Forum object with information on a particular forum.
        /// </summary>
        /// <param name="ForumID">The ID of the Forum you are interested in.</param>
        /// <returns>A Forum object.</returns>
        /// <remarks>If a ForumID is passed in that is NOT found in the database, a ForumNotFoundException
        /// exception is thrown.</remarks>
        public  Forum GetForumInfo(int forumID, string username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforuminfo(:forumid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumID;
            if (( username == null) || (username == String.Empty))
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read()) {
                dr.Close();
                myConnection.Close();
                // we didn't get a forum, handle it
                throw new Components.ForumNotFoundException("Did not get back a forum for ForumID " + forumID.ToString());
            }

            Forum f = PopulateForumFromNpgsqlDataReader(dr);
            f.TotalThreads = Convert.ToInt32(dr["totaltopics"]);

            dr.Close();
            myConnection.Close();

            return f;
        }




        /// <summary>
        /// Returns information about a particular forum that contains a particular post.
        /// </summary>
        /// <param name="PostID">The ID of the post that is contained in the Forum you wish to
        /// retrieve information about.</param>
        /// <returns>A Forum object instance containing the information about the Forum that the
        /// specified thread exists in.</returns>
        /// <remarks>If a Post is passed in that is NOT found in the database, a ForumNotFoundException
        /// exception is thrown.</remarks>
        public  Forum GetForumInfoByPostID(int PostID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumbypostid(:postid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterPostId = new NpgsqlParameter("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPostId.Value = PostID;
            myCommand.Parameters.Add(parameterPostId);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read()) {
                dr.Close();
                myConnection.Close();
                // we didn't get a forum, handle it
                throw new Components.ForumNotFoundException("Did not get back a forum for PostID " + PostID.ToString());
            }

            Forum f = PopulateForumFromNpgsqlDataReader(dr);
            dr.Close();
            myConnection.Close();
            return f;
        }

        public ForumCollection GetForumsByForumGroupId(int forumGroupId, string username) {

            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumsbyforumgroupid(:forumgroupid,:getallforums,:username)", myConnection);
            NpgsqlParameter param;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter forumGroups = new NpgsqlParameter("forumgroupid", NpgsqlTypes.NpgsqlDbType.Integer, 1);
            forumGroups.Value = forumGroupId;
            myCommand.Parameters.Add(forumGroups);

            // Add Parameters to SPROC
            param = new NpgsqlParameter("getallforums", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            param.Value = true; // TODO
            myCommand.Parameters.Add(param);

            // Add Parameters to SPROC
            param = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            if (username == null)
                param.Value = System.DBNull.Value;
            else
                param.Value = username;
            myCommand.Parameters.Add(param);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // populate a ForumCollection object
            ForumCollection forums = new ForumCollection();
            Forum forum;

            while (dr.Read()) {

                forum = PopulateForumFromNpgsqlDataReader(dr);

                forum.TotalPosts = Convert.ToInt32(dr["totalposts"]);
                forum.TotalThreads = Convert.ToInt32(dr["totaltopics"]);
                forum.ForumGroupId = (int) dr["forumgroupid"];

                // Handle Nulls in the case that we don't have a 'most recent post...'
                if (Convert.IsDBNull(dr["mostrecentpostauthor"]))
                    forum.MostRecentPostAuthor = null;
                else
                    forum.MostRecentPostAuthor = Convert.ToString(dr["mostrecentpostauthor"]);

                if (Convert.IsDBNull(dr["mostrecentpostid"])) {
                    forum.MostRecentPostId = 0;
                    forum.MostRecentThreadId = 0;
                } else {
                    forum.MostRecentPostId = Convert.ToInt32(dr["mostrecentpostid"]);
                    forum.MostRecentThreadId = Convert.ToInt32(dr["mostrecentthreadid"]);
                }

                if (Convert.IsDBNull(dr["mostrecentpostdate"]))
                    forum.MostRecentPostDate = DateTime.MinValue.AddMonths(1);
                else
                    forum.MostRecentPostDate = Convert.ToDateTime(dr["mostrecentpostdate"]);

                // Last time the user was active in the forum
                if (username != null) {
                    if (Convert.IsDBNull(dr["lastuseractivity"]))
                        forum.LastUserActivity = DateTime.MinValue.AddMonths(1);
                    else
                        forum.LastUserActivity = Convert.ToDateTime(dr["lastuseractivity"]);
                } else {
                    forum.LastUserActivity = DateTime.MinValue;
                }
            
                forums.Add(forum);

            }
            dr.Close();
            myConnection.Close();

            return forums;        
        }

        public ForumGroupCollection GetAllForumGroups(bool displayAllForumGroups, string username) {

            // Connect to the database
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallforumgroups(:getallforumsgroups,:username)", myConnection);

            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
			if (displayAllForumGroups) {
				myCommand.Parameters.Add("getallforumsgroups", NpgsqlTypes.NpgsqlDbType.Boolean).Value = true;
			} else {
				myCommand.Parameters.Add("getallforumsgroups", NpgsqlTypes.NpgsqlDbType.Boolean).Value = false;
			}
            if ( (username == null) || (username == String.Empty))
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
    
            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // populate a ForumGroupCollection object
            ForumGroupCollection forumGroups = new ForumGroupCollection();
            ForumGroup forumGroup;

            while (dr.Read()) {
                forumGroup = PopulateForumGroupFromNpgsqlDataReader(dr);

                forumGroups.Add(forumGroup);
            }
            dr.Close();
            myConnection.Close();

            return forumGroups;
        }

        /// <summary>
        /// Returns a list of all Forums.
        /// </summary>
        /// <returns>A ForumCollection object.</returns>
        public  ForumCollection GetAllForums(bool showAllForums, string username) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getallforums(:getallforums,:username)", myConnection);
            NpgsqlParameter param;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            param = new NpgsqlParameter("getallforums", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            param.Value = showAllForums;
            myCommand.Parameters.Add(param);

            // Add Parameters to SPROC
            param = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            if (username == null)
                param.Value = System.DBNull.Value;
            else
                param.Value = username;

            myCommand.Parameters.Add(param);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // populate a ForumCollection object
            ForumCollection forums = new ForumCollection();
            Forum forum;
            while (dr.Read()) {
                forum = PopulateForumFromNpgsqlDataReader(dr);

                forum.TotalPosts = Convert.ToInt32(dr["totalposts"]);
                forum.TotalThreads = Convert.ToInt32(dr["totaltopics"]);
                forum.ForumGroupId = (int) dr["forumgroupid"];
                
                // Handle Nulls
                if (Convert.IsDBNull(dr["mostrecentpostauthor"]))
                    forum.MostRecentPostAuthor = null;
                else
                    forum.MostRecentPostAuthor = Convert.ToString(dr["mostrecentpostauthor"]);

                if (Convert.IsDBNull(dr["mostrecentpostid"])) {
                    forum.MostRecentPostId = 0;
                    forum.MostRecentThreadId = 0;
                } else {
                    forum.MostRecentPostId = Convert.ToInt32(dr["mostrecentpostid"]);
                    forum.MostRecentThreadId = Convert.ToInt32(dr["mostrecentthreadid"]);
                }

                if (Convert.IsDBNull(dr["mostrecentpostdate"]))
                    forum.MostRecentPostDate = DateTime.MinValue.AddMonths(1);
                else
                    forum.MostRecentPostDate = Convert.ToDateTime(dr["mostrecentpostdate"]);

                // Last time the user was active in the forum
                if (username != null) {
                    if (Convert.IsDBNull(dr["lastuseractivity"]))
                        forum.LastUserActivity = DateTime.MinValue.AddMonths(1);
                    else
                        forum.LastUserActivity = Convert.ToDateTime(dr["lastuseractivity"]);
                } else {
                    forum.LastUserActivity = DateTime.MinValue;
                }

                forums.Add(forum);
            }
            dr.Close();
            myConnection.Close();

            return forums;
        }


    

        /// <summary>
        /// Deletes a forum and all of its posts.
        /// </summary>
        /// <param name="ForumID">The ID of the forum to delete.</param>
        /// <remarks>Be very careful when using this method.  It will permanently delete ALL of the
        /// posts associated with the forum.</remarks>
        public  void DeleteForum(int ForumID) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_deleteforum(:forumid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            NpgsqlParameter parameterForumID = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumID.Value = ForumID;
            myCommand.Parameters.Add(parameterForumID);

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }


        /// <summary>
        /// Adds a new forum.
        /// </summary>
        /// <param name="forum">A Forum object instance that defines the variables for the new forum to
        /// be added.  The Forum object properties used to create the new forum are: Name, Description,
        /// Moderated, and DaysToView.</param>
        public void AddForum(Forum forum) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_addforum(:name,:description,:forumgroupid,:moderated,:daystoview,:active)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterForumName = new NpgsqlParameter("name", NpgsqlTypes.NpgsqlDbType.Text, 100);
            parameterForumName.Value = forum.Name;
            myCommand.Parameters.Add(parameterForumName);

            NpgsqlParameter parameterForumDesc = new NpgsqlParameter("description", NpgsqlTypes.NpgsqlDbType.Text, 5000);
            parameterForumDesc.Value = forum.Description;
            myCommand.Parameters.Add(parameterForumDesc);

            NpgsqlParameter parameterForumGroupId = new NpgsqlParameter("forumgroupid", NpgsqlTypes.NpgsqlDbType.Integer);
            parameterForumGroupId.Value = forum.ForumGroupId;
            myCommand.Parameters.Add(parameterForumGroupId);
            
            NpgsqlParameter parameterModerated = new NpgsqlParameter("moderated", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            parameterModerated.Value = forum.Moderated;
            myCommand.Parameters.Add(parameterModerated);

            NpgsqlParameter parameterViewToDays = new NpgsqlParameter("daystoview", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterViewToDays.Value = forum.DaysToView;
            myCommand.Parameters.Add(parameterViewToDays);

            NpgsqlParameter parameterActive = new NpgsqlParameter("active", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            parameterActive.Value = forum.Active;
            myCommand.Parameters.Add(parameterActive);


            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }



        /// <summary>
        /// Updates an existing forum.
        /// </summary>
        /// <param name="forum">A Forum object with the new, updated properties.  The ForumID property
        /// specifies what forum to update, while hte Name, Description, Moderated, and DaysToView
        /// properties indicate the new values.</param>
        public  void UpdateForum(Forum forum) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updateforum(:forumid,:forumgroupid,:name,:description,:moderated,:daystoview,:active)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("forumgroupid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forum.ForumGroupId;

            NpgsqlParameter parameterForumId = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumId.Value = forum.ForumID;
            myCommand.Parameters.Add(parameterForumId);

            NpgsqlParameter parameterForumName = new NpgsqlParameter("name", NpgsqlTypes.NpgsqlDbType.Text, 100);
            parameterForumName.Value = forum.Name;
            myCommand.Parameters.Add(parameterForumName);

            NpgsqlParameter parameterForumDesc = new NpgsqlParameter("description", NpgsqlTypes.NpgsqlDbType.Text, 5000);
            parameterForumDesc.Value = forum.Description;
            myCommand.Parameters.Add(parameterForumDesc);

            NpgsqlParameter parameterModerated = new NpgsqlParameter("moderated", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            parameterModerated.Value = forum.Moderated;
            myCommand.Parameters.Add(parameterModerated);

            NpgsqlParameter parameterViewToDays = new NpgsqlParameter("daystoview", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterViewToDays.Value = forum.DaysToView;
            myCommand.Parameters.Add(parameterViewToDays);

            NpgsqlParameter parameterActive = new NpgsqlParameter("active", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            parameterActive.Value = forum.Active;
            myCommand.Parameters.Add(parameterActive);


            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }


        /// <summary>
        /// Returns the total number of forums.
        /// </summary>
        /// <returns>The total number of forums.</returns>
        public int TotalNumberOfForums() {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettotalnumberofforums()", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            myConnection.Open();
            int totalForums = Convert.ToInt32(myCommand.ExecuteScalar());
            myConnection.Close();

            return totalForums;

        }
        /*********************************************************************************/




        /*********************************************************************************/

        /************************ USER FUNCTIONS ***********************
                 * These functions return information about a user.
                 * are called from the WebForums.Users class.
                 * *************************************************************/
    
        /// <summary>
        /// Retrieves information about a particular user.
        /// </summary>
        /// <param name="Username">The name of the User whose information you are interested in.</param>
        /// <returns>A User object.</returns>
        /// <remarks>If a Username is passed in that is NOT found in the database, a UserNotFoundException
        /// exception is thrown.</remarks>
        public  User GetUserInfo(String username, bool updateIsOnline) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getuserinfo(:username,:updateisonline)", myConnection);
            NpgsqlParameter param;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            param = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = username;
            myCommand.Parameters.Add(param);

            // Add Parameters to SPROC
            param = new NpgsqlParameter("updateisonline", NpgsqlTypes.NpgsqlDbType.Boolean);
            param.Value = updateIsOnline;
            myCommand.Parameters.Add(param);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (!dr.Read()) {
                dr.Close();
                myConnection.Close();
                // we didn't get a user, handle it
                throw new Components.UserNotFoundException("User not found for Username " + username);
            }

            User u = PopulateUserFromNpgsqlDataReader(dr);
            dr.Close();
            myConnection.Close();

            return u;
        }

        /// <summary>
        /// Returns a depricated user collection of the user's currently online
        /// for the specified minutes. Only the username and whether they are an
        /// administrator is returned.
        /// </summary>
        /// <param name="pastMinutes">Minutes back in time</param>
        /// <returns></returns>
        public int TotalAnonymousUsersOnline() {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getanonymoususersonline()", myConnection);
            int anonymousUserCount = 0;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            if (dr.Read())
                anonymousUserCount = Convert.ToInt32(dr["anonymoususercount"]);

            dr.Close();
            myConnection.Close();

            return anonymousUserCount;
        }

        /// <summary>
        /// Returns a depricated user collection of the user's currently online
        /// for the specified minutes. Only the username and whether they are an
        /// administrator is returned.
        /// </summary>
        /// <param name="pastMinutes">Minutes back in time</param>
        /// <returns></returns>
        public UserCollection WhoIsOnline(int pastMinutes) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getusersonline(:pastminutes)", myConnection);
            UserCollection users = new UserCollection();

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("pastminutes", NpgsqlTypes.NpgsqlDbType.Integer);
            parameterUsername.Value = pastMinutes;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            while (dr.Read()) {
                OnlineUser u = new OnlineUser();
                u.Username = Convert.ToString(dr["username"]);
                u.IsAdministrator = Convert.ToBoolean(dr["administrator"]);
                u.IsModerator = Convert.ToBoolean(dr["ismoderator"]);

                users.Add(u);
            }

            dr.Close();
            myConnection.Close();

            return users;
        }
    
        /// <summary>
        /// Updates a user's information.
        /// </summary>
        /// <param name="user">A User object that contains information about the existing user.</param>
        /// <param name="NewPassword">The new password for the User.  (If the user has not changed their
        /// password, this property should be their existing password.)</param>
        /// <returns>A boolean - true if the user's password was correct, false otherwise.  In the case
        /// of an incorrect password being entered, the update is not performed.</returns>
        public  bool UpdateUserProfile(User user) {

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updateuserinfo(:username,:email,:fakeemail,:url,:signature,:forumview,:threadtracking,:timezone,:password,:occupation,:location,:interests,:msnim,:aolim,:yahooim,:icqim,:showunreadtopicsonly,:sitestyle,:avatartype,:hasavatar,:showavatar,:dateformat,:postvieworder)", myConnection);
            NpgsqlParameter param;
            bool succeded = false;

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Username
            param = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = user.Username;
            myCommand.Parameters.Add(param);

            // Email
            param = new NpgsqlParameter("email", NpgsqlTypes.NpgsqlDbType.Text, 75);
            param.Value = user.Email;
            myCommand.Parameters.Add(param);

            // Fake Email
            param = new NpgsqlParameter("fakeemail", NpgsqlTypes.NpgsqlDbType.Text, 75);
            param.Value = user.PublicEmail;
            myCommand.Parameters.Add(param);

            // Website
            param = new NpgsqlParameter("url", NpgsqlTypes.NpgsqlDbType.Text, 100);
            param.Value = user.Url;
            myCommand.Parameters.Add(param);

            // Occupation
            param = new NpgsqlParameter("occupation", NpgsqlTypes.NpgsqlDbType.Text, 100);
            param.Value = user.Occupation;
            myCommand.Parameters.Add(param);

            // Location
            param = new NpgsqlParameter("location", NpgsqlTypes.NpgsqlDbType.Text, 100);
            param.Value = user.Location;
            myCommand.Parameters.Add(param);

            // Interests
            param = new NpgsqlParameter("interests", NpgsqlTypes.NpgsqlDbType.Text, 200);
            param.Value = user.Interests;
            myCommand.Parameters.Add(param);

            // MSN IM
            param = new NpgsqlParameter("msnim", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = user.MsnIM;
            myCommand.Parameters.Add(param);

            // AOL IM
            param = new NpgsqlParameter("aolim", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = user.AolIM;
            myCommand.Parameters.Add(param);

            // Yahoo IM
            param = new NpgsqlParameter("yahooim", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = user.YahooIM;
            myCommand.Parameters.Add(param);

            // ICQ
            param = new NpgsqlParameter("icqim", NpgsqlTypes.NpgsqlDbType.Text, 50);
            param.Value = user.IcqIM;
            myCommand.Parameters.Add(param);

            // Signature
            param = new NpgsqlParameter("signature", NpgsqlTypes.NpgsqlDbType.Text, 256);
            param.Value = user.Signature;
            myCommand.Parameters.Add(param);

            // Forum View
            param = new NpgsqlParameter("forumview", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            param.Value = (int) user.ForumView;
            myCommand.Parameters.Add(param);

            // Thread tracking
            param = new NpgsqlParameter("threadtracking", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            param.Value = user.TrackPosts;
            myCommand.Parameters.Add(param);

            // Timezone
            param = new NpgsqlParameter("timezone", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            param.Value = user.Timezone;
            myCommand.Parameters.Add(param);

            // Date Format
            param = new NpgsqlParameter("dateformat", NpgsqlTypes.NpgsqlDbType.Text, 10);
            param.Value = user.DateFormat;
            myCommand.Parameters.Add(param);

            // HasAvatar
            myCommand.Parameters.Add("hasavatar", NpgsqlTypes.NpgsqlDbType.Boolean).Value = user.HasAvatar;

            // ShowAvatar
            myCommand.Parameters.Add("showavatar", NpgsqlTypes.NpgsqlDbType.Boolean).Value = user.ShowAvatar;

            // Post display order
            myCommand.Parameters.Add("postvieworder", NpgsqlTypes.NpgsqlDbType.Boolean).Value = Convert.ToBoolean(user.ShowPostsAscending);

            // Password
            param = new NpgsqlParameter("password", NpgsqlTypes.NpgsqlDbType.Text, 20);
            param.Value = user.Password;
            myCommand.Parameters.Add(param);

            // ShowUnreadThreadsOnly
            param = new NpgsqlParameter("showunreadtopicsonly", NpgsqlTypes.NpgsqlDbType.Boolean);
            param.Value = user.HideReadThreads;
            myCommand.Parameters.Add(param);

            // Site Style
            param = new NpgsqlParameter("sitestyle", NpgsqlTypes.NpgsqlDbType.Text, 20);
            param.Value = user.Skin;
            myCommand.Parameters.Add(param);

            // AvatarType
            param = new NpgsqlParameter("avatartype", NpgsqlTypes.NpgsqlDbType.Integer);
            param.Value = (int)user.Avatar;
            myCommand.Parameters.Add(param);

            // Execute the command
            myConnection.Open();

            succeded = Convert.ToBoolean(Convert.ToInt32(myCommand.ExecuteScalar().ToString()));

            myConnection.Close();
            return succeded;
        }

        /// <summary>
        /// Returns a collection of users whose Username begins with a specified character.
        /// </summary>
        /// <param name="FirstCharacter">The starting character.</param>
        /// <returns>A UserCollection object with Users whose Username begins with the specified
        /// FirstCharacter letter.</returns>
        public  UserCollection GetUsersByFirstCharacter(String FirstCharacter) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getusersbyfirstcharacter(:firstletter)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            NpgsqlParameter parameterUsername = new NpgsqlParameter("firstletter", NpgsqlTypes.NpgsqlDbType.Text, 1);
            parameterUsername.Value = FirstCharacter;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            UserCollection users = new UserCollection();
            while (dr.Read()) {
                users.Add(PopulateUserFromNpgsqlDataReader(dr));
            }

            dr.Close();
            myConnection.Close();
            return users;
        }

        

        /// <summary>
        /// Updates a user's information via the administration page.
        /// </summary>
        /// <param name="user">The information about the User you wish to update.  Note that the
        /// Username of the User identifies the user you wish to update, while the Approved,
        /// Trusted, and Administrator properties specify the new settings for those fields.</param>
        public void UpdateUserInfoFromAdminPage(User user) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updateuserfromadminpage(:username,:profileapproved,:approved,:trusted)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = user.Username;
            myCommand.Parameters.Add("profileapproved", NpgsqlTypes.NpgsqlDbType.Boolean, 1).Value = user.IsProfileApproved;
            myCommand.Parameters.Add("approved", NpgsqlTypes.NpgsqlDbType.Boolean, 1).Value = user.IsApproved;
            myCommand.Parameters.Add("trusted", NpgsqlTypes.NpgsqlDbType.Boolean, 1).Value = user.IsTrusted;

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }

        
        /// <summary>
        /// This method creates a new user if possible.  If the username or
        /// email addresses already exist, an appropriate CreateUserStatus message is
        /// returned.
        /// </summary>
        /// <param name="user">The email for the new user account.</param>
        /// <returns>An CreateUserStatus enumeration value, indicating if the user was created successfully
        /// (CreateUserStatus.Created) or if the new user couldn't be created because of a duplicate
        /// Username (CreateUserStatus.DuplicateUsername) or duplicate email address (CreateUserStatus.DuplicateEmailAddress).</returns>
        /// <remarks>All User accounts created must consist of a unique Username and a unique
        /// Email address.</remarks>
        public CreateUserStatus CreateNewUser(User user) {
            // make sure the user's name begins with an alphabetic character
            if (!Regex.IsMatch(user.Username, "^[A-Za-z].*"))
                return CreateUserStatus.InvalidFirstCharacter;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_createnewuser(:username,:email,:randompassword)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = user.Username;
            myCommand.Parameters.Add(parameterUsername);

            NpgsqlParameter parameterEmail = new NpgsqlParameter("email", NpgsqlTypes.NpgsqlDbType.Text, 75);
            parameterEmail.Value = user.Email;
            myCommand.Parameters.Add(parameterEmail);

            NpgsqlParameter parameterPassword = new NpgsqlParameter("randompassword", NpgsqlTypes.NpgsqlDbType.Text, 20);
            parameterPassword.Value = user.Password;
            myCommand.Parameters.Add(parameterPassword);
            

            // Execute the command
            myConnection.Open();
            
            int iStatusCode = Convert.ToInt32(myCommand.ExecuteScalar());
            
            CreateUserStatus status;
            switch (iStatusCode) {
                case 1:     // user created successfully
                    status = CreateUserStatus.Created;
                    break;

                case 2:     // username duplicate
                    status = CreateUserStatus.DuplicateUsername;
                    break;

                case 3:     // email address duplicate
                    status = CreateUserStatus.DuplicateEmailAddress;
                    break;

                default:    // oops, something bad happened
                    status = CreateUserStatus.UnknownFailure;
                    break;
            }

            myConnection.Close();

            return status;      // return the status result
        }

        
        /// <summary>
        /// This method determines whether or not a particular username/password combo
        /// is valid.
        /// </summary>
        /// <param name="user">The User to determine if he/she is valid.</param>
        /// <returns>A boolean value, indicating if the username and password are valid.</returns>
        public bool ValidUser(User user) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_checkusercredentials(:username,:password)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = user.Username;
            myCommand.Parameters.Add(parameterUsername);

            NpgsqlParameter parameterPassword = new NpgsqlParameter("password", NpgsqlTypes.NpgsqlDbType.Text, 20);
            parameterPassword.Value = user.Password;
            myCommand.Parameters.Add(parameterPassword);

            // Execute the command
            myConnection.Open();
            bool retVal = Convert.ToBoolean(myCommand.ExecuteScalar());
            myConnection.Close();
            return retVal;
        }


        /// <summary>
        /// Calculates and returns the total number of user accounts.
        /// </summary>
        /// <returns>The total number of user accounts created.</returns>
        public int TotalNumberOfUserAccounts(string usernameBeginsWith, string usernameToFind) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettotalusers(:usernamebeginswith,:usernametofind)", myConnection);

            // Set the command type to stored procedure
            myCommand.CommandType = CommandType.StoredProcedure;

            if ((usernameBeginsWith == "All") || (usernameBeginsWith == null))
                myCommand.Parameters.Add("usernamebeginswith", NpgsqlTypes.NpgsqlDbType.Text, 1).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("usernamebeginswith", NpgsqlTypes.NpgsqlDbType.Text, 1).Value = usernameBeginsWith;

            if (usernameToFind == null)
                myCommand.Parameters.Add("usernametofind", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("usernametofind", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = usernameToFind;

            // Execute the command
            myConnection.Open();
            int retVal = Convert.ToInt32(myCommand.ExecuteScalar());
            myConnection.Close();
            return retVal;
        }
        /*********************************************************************************/




        /*********************************************************************************/




        /// <summary>
        /// Performs a search, returning a PostCollection object with appropriate posts.
        /// </summary>
        /// <param name="ToSearch">Specifies what to search, specifically.  Must be set to a valid
        /// ToSearchEnum value, which supports two possible values: PostsSearch and PostsBySearch.</param>
        /// <param name="SearchWhat">A SearchWhatEnum value, this parameter specifies what to search. 
        /// Acceptable values are: SearchAllWords, SearchAnyWord, and SearchExactPhrase.</param>
        /// <param name="ForumToSearch">Specifies what forum to search.  To search all forums, pass in a
        /// value of 0.</param>
        /// <param name="SearchTerms">Specifies the terms to search on.</param>
        /// <param name="Page">Specifies what page of the search results to display.</param>
        /// <param name="RecsPerPage">Specifies how many records per page to show on the search
        /// results.</param>
        /// <returns>A PostCollection object, containing the posts to display for the particular page
        /// of the search results.</returns>
        public  PostCollection GetSearchResults(ToSearchEnum ToSearch, SearchWhatEnum SearchWhat, int ForumToSearch, String SearchTerms, int Page, int RecsPerPage, string username) {

            // return all of the forums and their total and daily posts
            // first, though, we've got to put our search phrase in the right order
            String strColumnName = "";
            String strWhereClause = " WHERE (";
            String [] aTerms = null;
			
            
            // Are we searching for a particular user?
            if (ToSearch == ToSearchEnum.PostsSearch) {
                strColumnName = "Body";

                // depending on the search style, our WHERE clause will differ
                switch(SearchWhat) {
                    case SearchWhatEnum.SearchExactPhrase:
                        // easy, we want to search for the exact search term
                        strWhereClause += strColumnName + " iLIKE '%" + SearchTerms + "%' ";
                        break;
					
                    case SearchWhatEnum.SearchAllWords:
                        // allrighty, we want to find rows where each word is found
                        // split up the search term string into an array
                        aTerms = SearchTerms.Split(new char[]{' '});
					
                        // now, loop through the aTerms array
                        strWhereClause += strColumnName + " iLIKE '%" + String.Join("%' AND " + strColumnName + " iLIKE '%", aTerms) + "%'";
                        break;

                    case SearchWhatEnum.SearchAnyWord:
                        // allrighty, we want to find rows where each word is found
                        // split up the search term string into an array
                        aTerms = SearchTerms.Split(new char[]{' '});
					
                        // now, loop through the aTerms array
                        strWhereClause += strColumnName + " iLIKE '%" + String.Join("%' OR " + strColumnName + " iLIKE '%", aTerms) + "%'";
                        break;
                }
			
                strWhereClause += ") AND Approved=true ";


            }
            else if (ToSearch == ToSearchEnum.PostsBySearch) {
                strColumnName = "UserName";

                strWhereClause += strColumnName + " = '" + SearchTerms + "') AND Approved = true ";
            }
			
            // see if we need to add a restriction on the ForumID
            if (ForumToSearch > 0)
                strWhereClause += " AND P.ForumID = " + ForumToSearch.ToString() + " ";
				
			
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getsearchresults(:searchterms,:page,:recsperpage,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;
            
            NpgsqlParameter parameterPage = new NpgsqlParameter("page", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPage.Value = Page;
            myCommand.Parameters.Add(parameterPage);

            NpgsqlParameter parameterRecsPerPage = new NpgsqlParameter("recsperpage", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterRecsPerPage.Value = RecsPerPage;
            myCommand.Parameters.Add(parameterRecsPerPage);

            NpgsqlParameter parameterSearchTerms = new NpgsqlParameter("searchterms", NpgsqlTypes.NpgsqlDbType.Text, 500);
            parameterSearchTerms.Value = strWhereClause;
            myCommand.Parameters.Add(parameterSearchTerms);
            
            if ( (username == null) || (username == String.Empty))
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            // populate the Posts collection
            PostCollection posts = new PostCollection();
            if (!dr.Read()) {
                dr.Close();
                myConnection.Close();
                // we have an empty result, return the empty post collection
                return posts;
            } else {
                // we have to populate our postcollection
                posts.TotalRecordCount = Convert.ToInt32(dr["morerecords"]);

                do {
                    posts.Add(PopulatePostFromNpgsqlDataReader(dr));
                    ((Post) posts[posts.Count - 1]).ForumName = Convert.ToString(dr["forumname"]);
                } while (dr.Read());

                dr.Close();
                myConnection.Close();

                return posts;
            }
        }
        /*********************************************************************************/





        /*********************************************************************************/

        /********************* MODERATION FUNCTIONS *********************
                 * These functions are used to perform moderation.  They are called
                 * from the WebForums.Moderate class.
                 * **************************************************************/


        // **********************************************************************
        /// <summary>
        /// Given a username, returns a boolean indicating whether or not the user has
        /// posts awaiting moderation.
        /// </summary>
        /// <param name="Username"></param>
        /// <returns></returns>
        // **********************************************************************
        public bool UserHasPostsAwaitingModeration(String username) {

            //TODO 

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_userhaspostsawaitingmoderation(:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;

            // Open the database connection and execute the command
            NpgsqlDataReader dr;

            myConnection.Open();
            dr = myCommand.ExecuteReader(CommandBehavior.CloseConnection);

            // create a String array from the data
            ArrayList userRoles = new ArrayList();


            dr.Close();

            // Return the String array of roles
            return false;
        }

        /// <summary>
        /// Gets a list of posts that are awaiting moderation that the current user has rights to moderate.
        /// </summary>
        /// <param name="Username">The User who is interested in viewing a list of posts awaiting
        /// moderation.</param>
        /// <returns>A PostCollection containing the posts the user can view that are awaiting moderation.</returns>
        public  PostCollection GetPostsAwaitingModeration(String Username) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getmoderatedposts(:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = Username;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            PostCollection posts = new PostCollection();
            Post post = null;

            while (dr.Read()) {
                post = PopulatePostFromNpgsqlDataReader(dr);
                post.ForumName = Convert.ToString(dr["forumname"]);

                posts.Add(post);
            }
            dr.Close();
            myConnection.Close();

            return posts;
        }



        /// <summary>
        /// Approves a particular post that is waiting to be moderated.
        /// </summary>
        /// <param name="PostID">The ID of the post to approve.</param>
        /// <returns>A boolean indicating if the post has already been approved.</returns>
        /// <remarks>Keep in mind that multiple moderators may be working on approving/moving/editing/deleting
        /// posts at the same time.  Hence, these moderation functions may not perform the desired task.
        /// For example, if one opts to delete a post that has already been approved, the deletion will
        /// fail.</remarks>
        public bool ApprovePost(int postID, string approvedBy, string updateUserAsTrusted) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_approvemoderatedpost(:postid,:approvedby,:trusted)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = postID;
            myCommand.Parameters.Add("approvedby", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = approvedBy;

            if (updateUserAsTrusted == null)
                myCommand.Parameters.Add("trusted", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = System.DBNull.Value;
            else
                myCommand.Parameters.Add("trusted", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = updateUserAsTrusted;

            // Execute the command
            myConnection.Open();
            int iResult = Convert.ToInt32(myCommand.ExecuteScalar().ToString());
            myConnection.Close();

            return iResult == 1;        // was the post previously approved?
        }


        /// <summary>
        /// Deletes a post that is currently waiting to be moderated.
        /// </summary>
        /// <param name="PostID">The ID of the post to delete.</param>
        /// <returns>A boolean, true if the post has been deleted, false otherwise.  The post might not
        /// be deleted if someone else has already approved the post.</returns>
        /// <remarks>Keep in mind that multiple moderators may be working on approving/moving/editing/deleting
        /// posts at the same time.  Hence, these moderation functions may not perform the desired task.
        /// For example, if one opts to delete a post that has already been approved, the deletion will
        /// fail.</remarks>
        public  bool DeleteModeratedPost(int postID, string approvedBy) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_DeleteNonApprovedPost", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = postID;
            myCommand.Parameters.Add("approvedby", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = approvedBy;

            // Execute the command
            myConnection.Open();
            int iRowsAffectedCount = Convert.ToInt32(myCommand.ExecuteScalar().ToString());
            myConnection.Close();
            
            return iRowsAffectedCount != 0;     
        }


        /// <summary>
        /// Indicates if a particular user can moderate posts.
        /// </summary>
        /// <param name="Username">The User to check.</param>
        /// <returns>True if the user can moderate, False otherwise.</returns>
        public  bool CanModerate(String Username) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_canmoderate(:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = Username;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();
            if (!dr.Read())
                throw new Components.UserNotFoundException("User not found for Username " + Username);
            
            // check to see if the user can moderate
            bool bolCanModerate = dr["canmoderate"].ToString() == "1";
            
            dr.Close();
            myConnection.Close();
            
            return bolCanModerate;
        }

        /// <summary>
        /// Indicates if a particular user can moderate posts.
        /// </summary>
        /// <param name="Username">The User to check.</param>
        /// <returns>True if the user can moderate, False otherwise.</returns>
        public  bool CanModerate(String username, int forumID) {
            // return all of the forums and their total and daily posts
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_canmoderateforum(:username,:forumid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = username;
            myCommand.Parameters.Add("forumid", NpgsqlTypes.NpgsqlDbType.Integer).Value = forumID;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();
            if (!dr.Read())
                throw new Components.UserNotFoundException("User not found for Username " + username);
            
            // check to see if the user can moderate
            bool boolCanModerate = dr["canmoderate"].ToString() == "1";
            
            dr.Close();
            myConnection.Close();
            
            return boolCanModerate;
        }

        /// <summary>
        /// Determines if a user can edit a particular post.
        /// </summary>
        /// <param name="Username">The name of the User.</param>
        /// <param name="PostID">The Post the User wants to edit.</param>
        /// <returns>A boolean value - True if the user can edit the Post, False otherwise.</returns>
        /// <remarks>An Administrator can edit any post.  Moderators may edit posts from forums that they
        /// have moderation rights to and that are awaiting approval.</remarks>
        public  bool CanEditPost(String Username, int PostID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_CanEditPost", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterPostID = new NpgsqlParameter("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPostID.Value = PostID;
            myCommand.Parameters.Add(parameterPostID);

            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = Username;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();
            int iResponse = Convert.ToInt32(myCommand.ExecuteScalar().ToString());
            myConnection.Close();
            
            return iResponse == 1;
        }


        /// <summary>
        /// Moves a post awaiting moderation from one Forum to another.
        /// </summary>
        /// <param name="PostID">The ID of the Post to move.</param>
        /// <param name="MoveToForumID">The ID of the forum to move the post to.</param>
        /// <param name="Username">The name of the User who is attempting to move the post.</param>
        /// <returns>A MovedPostStatus enumeration value that indicates the status of the attempted move.
        /// This enumeration has three values: NotMoved, MovedButNotApproved, and MovedAndApproved.</returns>
        /// <remarks>A value of NotMoved means the post was not moved (either it has been approved already
        /// or deleted); a value of MovedButNotApproved indicates that the post has been moved to a new
        /// forum, but the user moving the post was NOT a moderator for the forum it was moved to, hence
        /// the moved post is still waiting to be approved; a value of MovedAndApproved indicates that the
        /// moderator moved to post to a forum he moderates, hence the post is automatically approved.</remarks>
        public  MovedPostStatus MovePost(int postID, int moveToForumID, String approvedBy) {

            // moves a post to a specified forum
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_movepost(:postid,:movetoforumid,:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            myCommand.Parameters.Add("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = postID;
            myCommand.Parameters.Add("movetoforumid", NpgsqlTypes.NpgsqlDbType.Integer, 4).Value = moveToForumID;
            myCommand.Parameters.Add("username", NpgsqlTypes.NpgsqlDbType.Text, 50).Value = approvedBy;

            // Execute the command
            myConnection.Open();
            int iStatus = Convert.ToInt32(myCommand.ExecuteScalar().ToString());
            myConnection.Close();

            // Determine the status of the moved post
            switch (iStatus) {
                case 0:
                    return MovedPostStatus.NotMoved;
                    
                case 1:
                    return MovedPostStatus.MovedButNotApproved;
                    
                default:
                    return MovedPostStatus.MovedAndApproved;
            }
        }
        /*********************************************************************************/




        /*********************************************************************************/

        /********************* EMAIL FUNCTIONS *********************
                 * These functions are used to perform email functionality.
                 * They are called from the WebForums.Email class
                 * *********************************************************/

        /// <summary>
        /// Returns a list of Users that have email thread tracking turned on for a particular post
        /// in a particular thread.
        /// </summary>
        /// <param name="PostID">The ID of the Post of the thread to send a notification to.</param>
        /// <returns>A UserCollection listing the users who have email thread tracking turned on for
        /// the specified thread.</returns>
        public  UserCollection GetEmailList(int PostID) {
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_gettrackingemailsforthread(:postid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterPostId = new NpgsqlParameter("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPostId.Value = PostID;
            myCommand.Parameters.Add(parameterPostId);

    
            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            UserCollection users = new UserCollection();
            User u;
            while (dr.Read()) {
                u = new User();
                u.Email = dr["email"].ToString();
                users.Add(u);
            }

            dr.Close();
            myConnection.Close();

            return users;
        }


        /// <summary>
        /// Returns information about a particular Email Template.
        /// </summary>
        /// <param name="EmailTemplateID">The ID of the Email Template.</param>
        /// <returns>An EmailTemplate class instance.</returns>
        /// <remarks>If the passed in EmailTemplateID does not match to a database entry, a
        /// EmailTemplateNotFoundException exception is thrown.</remarks>
        public EmailTemplate GetEmailTemplateInfo(int EmailTemplateID) {
            EmailTemplate template;

            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getemailinfo(:emailid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterEmailId = new NpgsqlParameter("emailid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterEmailId.Value = EmailTemplateID;
            myCommand.Parameters.Add(parameterEmailId);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();
            if (!dr.Read())
                throw new Components.EmailTemplateNotFoundException("Email template not found for EmailTemplateID " + EmailTemplateID.ToString());
            
            template = PopulateEmailTemplateFromNpgsqlDataReader(dr);

            myConnection.Close();

            return template;
        }



        /// <summary>
        /// Returns a list of all of the Email Templates.
        /// </summary>
        /// <returns>An EmailTemplateCollection instance, that contains a listing of all of the available
        /// Email Templates.</returns>
        public  EmailTemplateCollection GetEmailTemplateList() {
            // Get the username from the approved Post
            
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getemaillist()", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            EmailTemplateCollection emails = new EmailTemplateCollection();
            while (dr.Read()) {
                emails.Add(PopulateEmailTemplateFromNpgsqlDataReader(dr));
            }
            dr.Close();
            myConnection.Close();

            return emails;
        }


        /// <summary>
        /// Updates an existing Email Template.
        /// </summary>
        /// <param name="email">An EmailTemplate object instance that contains information on the
        /// Email Template to update.  The EmailID property of the passed in EmailTemplate instance
        /// specifies the Email Template to update, while the Subject and Message properties indicate
        /// the updated Subject and Message values for the Email Template.</param>
        public void UpdateEmailTemplate(EmailTemplate email) {
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_updateemailtemplate(:emailid,:subject,:message)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterEmailId = new NpgsqlParameter("emailid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterEmailId.Value = email.EmailTemplateID;
            myCommand.Parameters.Add(parameterEmailId);

            NpgsqlParameter parameterSubject = new NpgsqlParameter("subject", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterSubject.Value = email.Subject;
            myCommand.Parameters.Add(parameterSubject);

            NpgsqlParameter parameterMessage = new NpgsqlParameter("message", NpgsqlTypes.NpgsqlDbType.Text);
            parameterMessage.Value = email.Body;
            myCommand.Parameters.Add(parameterMessage);

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }
        /*********************************************************************************/





        /*********************************************************************************/

        /**************** MODERATOR LISTING FUNCTIONS **************
                 * These functions are used to edit/update/work with the list
                 * of forums a user can moderate.
                 * *********************************************************/

        /// <summary>
        /// Retrieves a list of the Forums moderated by a particular user.
        /// </summary>
        /// <param name="user">The User whose list of moderated forums we are interested in.</param>
        /// <returns>A ModeratedForumCollection.</returns>
        public  ModeratedForumCollection GetForumsModeratedByUser(String Username) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumsmoderatedbyuser(:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = Username;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            ModeratedForumCollection forums = new ModeratedForumCollection();
            ModeratedForum forum;
            while (dr.Read()) {
                forum = new ModeratedForum();
                forum.ForumID = Convert.ToInt32(dr["forumid"]);
                forum.Name = Convert.ToString(dr["forumname"]);
                forum.DateCreated = Convert.ToDateTime(dr["datecreated"]);
                forum.EmailNotification = Convert.ToBoolean(dr["emailnotification"]);

                forums.Add(forum);
            }
            dr.Close();
            myConnection.Close();

            return forums;
        }


        /// <summary>
        /// Returns a list of forms NOT moderated by the user.
        /// </summary>
        /// <param name="user">The User whose list of non-moderated forums we are interested in
        /// viewing.</param>
        /// <returns>A ModeratedForumCollection containing the list of forums NOT moderated by
        /// the particular user.</returns>
        public ModeratedForumCollection GetForumsNotModeratedByUser(String Username) {          
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforumsnotmoderatedbyuser(:username)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = Username;
            myCommand.Parameters.Add(parameterUsername);

            // Execute the command
            myConnection.Open();

            NpgsqlDataReader dr = myCommand.ExecuteReader();

            ModeratedForumCollection forums = new ModeratedForumCollection();
            ModeratedForum forum;
            while (dr.Read()) {
                forum = new ModeratedForum();
                forum.ForumID = Convert.ToInt32(dr["forumid"]);
                forum.Name = Convert.ToString(dr["forumname"]);

                forums.Add(forum);
            }
            dr.Close();
            myConnection.Close();

            return forums;
        }


        /// <summary>
        /// Adds a forum to the list of moderatable forums for a particular user.
        /// </summary>
        /// <param name="forum">A ModeratedForum instance that contains the settings for the new user's
        /// moderatable forum.  The Username property indicates the user who can moderate the forum,
        /// the ForumID property indicates what forum the user can moderate, and the
        /// EmailNotification property indicates whether or not the moderator receives email
        /// notification when a new post has been made to the forum.</param>
        public void AddModeratedForumForUser(ModeratedForum forum) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_addmoderatedforumforuser(:username,:forumid,:emailnotification)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = forum.Username;
            myCommand.Parameters.Add(parameterUsername);

            NpgsqlParameter parameterForumID = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumID.Value = forum.ForumID;
            myCommand.Parameters.Add(parameterForumID);

            NpgsqlParameter parameterEmailNotification = new NpgsqlParameter("emailnotification", NpgsqlTypes.NpgsqlDbType.Boolean, 1);
            parameterEmailNotification.Value = forum.EmailNotification;
            myCommand.Parameters.Add(parameterEmailNotification);

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }


        /// <summary>
        /// Removes a moderated forum for a particular user.  
        /// </summary>
        /// <param name="forum">A ModeratedForum instance.  The Username and ForumID properties specify
        /// what Forum to remove from what User's list of moderatable forums.</param>
        public  void RemoveModeratedForumForUser(ModeratedForum forum) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_removemoderatedforumforuser(:username,:forumid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterUsername = new NpgsqlParameter("username", NpgsqlTypes.NpgsqlDbType.Text, 50);
            parameterUsername.Value = forum.Username;
            myCommand.Parameters.Add(parameterUsername);

            NpgsqlParameter parameterForumID = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumID.Value = forum.ForumID;
            myCommand.Parameters.Add(parameterForumID);

            // Execute the command
            myConnection.Open();
            myCommand.ExecuteNonQuery();
            myConnection.Close();
        }


        /// <summary>
        /// Returns a list of users who are interested in receiving email notification for a newly
        /// added post.
        /// </summary>
        /// <param name="PostID">The ID of the newly added post.</param>
        /// <returns>A UserCollection instance containing the users who want to be emailed when a new
        /// post is added to the moderation system.</returns>
        public  UserCollection GetModeratorsInterestedInPost(int PostID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getmoderatorsforemailnotification(:postid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterPostID = new NpgsqlParameter("postid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterPostID.Value = PostID;
            myCommand.Parameters.Add(parameterPostID);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            UserCollection users = new UserCollection();
            User user;
            while (dr.Read()) {
                user = new User();
                user.Username = Convert.ToString(dr["username"]);
                user.Email = Convert.ToString(dr["email"]);
                users.Add(user);
            }
            dr.Close();
            myConnection.Close();

            return users;
        }

    

        /// <summary>
        /// Returns a list of the moderators of a particular forum.
        /// </summary>
        /// <param name="ForumID">The ID of the Forum whose moderators we are interested in listing.</param>
        /// <returns>A ModeratedForumCollection containing the moderators of a particular Forum.</returns>
        public  ModeratedForumCollection GetForumModerators(int ForumID) {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getforummoderators(:forumid)", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Add Parameters to SPROC
            NpgsqlParameter parameterForumId = new NpgsqlParameter("forumid", NpgsqlTypes.NpgsqlDbType.Integer, 4);
            parameterForumId.Value = ForumID;
            myCommand.Parameters.Add(parameterForumId);

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            ModeratedForumCollection forums = new ModeratedForumCollection();
            ModeratedForum forum;
            while (dr.Read()) {
                forum = new ModeratedForum();
                forum.Username = Convert.ToString(dr["username"]);
                forum.ForumID = ForumID;
                forum.EmailNotification = Convert.ToBoolean(dr["emailnotification"]);
                forum.DateCreated = Convert.ToDateTime(dr["datecreated"]);

                forums.Add(forum);
            }
            dr.Close();
            myConnection.Close();

            return forums;
        }
        /*********************************************************************************/



        /*********************************************************************************/

        /**************** SUMMARY FUNCTIONS **************
                 * This function is used to get Summary information about WebForums.NET
                 * *********************************************************/

    
        /// <summary>
        /// Returns a SummaryObject object with summary information about the message board.
        /// </summary>
        /// <returns>A SummaryObject object populated with the summary information.</returns>
        public Statistics GetSiteStatistics() {
            // Create Instance of Connection and Command Object
            NpgsqlConnection myConnection = new NpgsqlConnection(Globals.DatabaseConnectionString);
            NpgsqlCommand myCommand = new NpgsqlCommand("forums_getstatistics()", myConnection);

            // Mark the Command as a SPROC
            myCommand.CommandType = CommandType.StoredProcedure;

            // Execute the command
            myConnection.Open();
            NpgsqlDataReader dr = myCommand.ExecuteReader();

            Statistics statistics = new Statistics();           

            dr.Read();

            statistics.TotalUsers = Convert.ToInt32(dr["totalusers"]);
            statistics.TotalPosts = Convert.ToInt32(dr["totalposts"]);
            statistics.TotalModerators = Convert.ToInt32(dr["totalmoderators"]);
            statistics.TotalModeratedPosts = Convert.ToInt32(dr["totalmoderatedposts"]);
            statistics.TotalThreads = Convert.ToInt32(dr["totaltopics"]);
            statistics.NewPostsInPast24Hours = Convert.ToInt32(dr["newpostsinpast24hours"]);
            statistics.NewThreadsInPast24Hours = Convert.ToInt32(dr["newthreadsinpast24hours"]);
            statistics.NewUsersInPast24Hours = Convert.ToInt32(dr["newusersinpast24hours"]);
            statistics.MostViewsPostID = Convert.ToInt32(dr["mostviewspostid"]);
            statistics.MostViewsSubject = Convert.ToString(dr["mostviewssubject"]);
            statistics.MostActivePostID = Convert.ToInt32(dr["mostactivepostid"]);
            statistics.MostActiveSubject = Convert.ToString(dr["mostactivesubject"]);
            statistics.MostReadPostID = Convert.ToInt32(dr["mostreadpostid"]);
            statistics.MostReadPostSubject = Convert.ToString(dr["mostreadsubject"]);
            statistics.MostActiveUser = Convert.ToString(dr["mostactiveuser"]);
            statistics.NewestUser = Convert.ToString(dr["newestuser"]);

            dr.Close();
            myConnection.Close();

            return statistics;
        }

        /*********************************************************************************/
    }
}

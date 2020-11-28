ifndef TARGET
	TARGET=./bin/Debug
else
	TARGET=./bin/$(TARGET)
endif

MCS=mcs
ifndef (RELEASE)
	MCSFLAGS=-debug --stacktrace
endif

ASPNETFORUMS_DLL=$(TARGET)/AspNetForums.dll
ASPNETFORUMS_PDB=$(TARGET)/AspNetForums.pdb
ASPNETFORUMS_SRC=AssemblyInfo.cs \
	Emails.cs \
	ForumGroups.cs \
	ForumMessages.cs \
	Forums.cs \
	Posts.cs \
	Search.cs \
	Threads.cs \
	UserRoles.cs \
	Users.cs \
	Votes.cs \
	Administration/Controls/AdminForumPostListing.cs \
	Administration/Controls/CreateEditForum.cs \
	Administration/Controls/CreateEditForumGroup.cs \
	Administration/Controls/CreateEditRole.cs \
	Administration/Controls/EditForum.cs \
	Administration/Controls/EmailTemplateAdmin.cs \
	Administration/Controls/MessageTemplateAdmin.cs \
	Administration/Controls/UserAdmin.cs \
	Components/EmailTemplate.cs \
	Components/EmailTemplateCollection.cs \
	Components/Exceptions.cs \
	Components/Forum.cs \
	Components/ForumCollection.cs \
	Components/ForumGroup.cs \
	Components/ForumGroupCollection.cs \
	Components/ForumMessage.cs \
	Components/ForumMessageTemplateCollection.cs \
	Components/Globals.cs \
	Components/IWebForumsDataProvider.cs \
	Components/OnlineUser.cs \
	Components/Post.cs \
	Components/PostCollection.cs \
	Components/PostDetail.cs \
	Components/SourceMarkUp.cs \
	Components/Statistics.cs \
	Components/Thread.cs \
	Components/ThreadCollection.cs \
	Components/Transforms.cs \
	Components/User.cs \
	Components/UserCollection.cs \
	Components/VoteDetails.cs \
	Components/VoteResult.cs \
	Components/VoteResultCollection.cs \
	Controls/CreateEditPost.cs \
	Controls/ForumGroupRepeater.cs \
	Controls/ForumRepeater.cs \
	Controls/Login.cs \
	Controls/Message.cs \
	Controls/MiscStyles.cs \
	Controls/MyForums.cs \
	Controls/PostList.cs \
	Controls/PostThreaded.cs \
	Controls/PostView.cs \
	Controls/SiteStats.cs \
	Controls/StyleSkin.cs \
	Controls/ThreadList.cs \
	Controls/ThreadView.cs \
	Controls/WhoIsOnline.cs \
	Controls/BaseClasses/ForumDataListControl.cs \
	Controls/BaseClasses/ForumRepeaterControl.cs \
	Controls/BaseClasses/SkinnedForumWebControl.cs \
	Controls/Design/ForumGroupRepeaterDesigner.cs \
	Controls/Design/ForumRepeaterDesigner.cs \
	Controls/Navigation/JumpDropDownList.cs \
	Controls/Navigation/NavigationMenu.cs \
	Controls/Navigation/WhereAmI.cs \
	Controls/Search/Search.cs \
	Controls/Search/SearchOptions.cs \
	Controls/Search/SearchRedirect.cs \
	Controls/Search/SearchView.cs \
	Controls/Specialized/ProgressBar.cs \
	Controls/Specialized/Vote.cs \
	Controls/User/CreateUser.cs \
	Controls/User/EditUserProfile.cs \
	Controls/User/ShowAllUsers.cs \
	Controls/User/UserList.cs \
	Controls/User/UserProfile.cs \
	Controls/Utility/AlphaPicker.cs \
	Controls/Utility/CurrentTime.cs \
	Controls/Utility/Paging.cs \
	Data/NpgsqlDataProvider.cs \
	Moderation/Moderate.cs \
	Moderation/Components/ModeratedForum.cs \
	Moderation/Components/ModeratedForumCollection.cs \
	Moderation/Components/ModerationAudit.cs \
	Moderation/Components/ModerationAuditCollection.cs \
	Moderation/Components/ModerationQueueStatus.cs \
	Moderation/Components/Moderator.cs \
	Moderation/Components/ModeratorCollection.cs \
	Moderation/Controls/DeletePost.cs \
	Moderation/Controls/ModeratedForumGroupRepeater.cs \
	Moderation/Controls/ModeratedForumRepeater.cs \
	Moderation/Controls/ModeratedForums.cs \
	Moderation/Controls/ModerationMenu.cs \
	Moderation/Controls/ModerationStats.cs \
	Moderation/Controls/ModerationView.cs \
	Moderation/Controls/MovePost.cs \
	Moderation/WebServices/QueueStatus.cs
ASPNETFORUMS_RES=-resource:Controls/MiscStyles.resx,AspNetForums.Controls.MiscStyles.resx

$(ASPNETFORUMS_DLL): $(ASPNETFORUMS_SRC) 
	-mkdir -p $(TARGET)
	$(MCS) $(MCSFLAGS) -r:System.dll -r:System.Data.dll -r:Npgsql.dll -r:System.Xml.dll -r:System.Web.dll -r:System.Drawing.dll -r:System.Design.dll -r:System.Web.Services.dll -target:library -out:$(ASPNETFORUMS_DLL) $(ASPNETFORUMS_RES) $(ASPNETFORUMS_SRC)


# common targets

all:	$(ASPNETFORUMS_DLL)

clean:
	-rm -f "$(ASPNETFORUMS_DLL)" 2> /dev/null
	-rm -f "$(ASPNETFORUMS_PDB)" 2> /dev/null


# project names as targets

AspNetForums: $(ASPNETFORUMS_DLL)


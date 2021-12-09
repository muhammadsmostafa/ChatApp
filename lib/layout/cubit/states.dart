abstract class AppStates {}

class AppInitialState extends AppStates {}

class AppGetUserSuccessState extends AppStates {}

class AppGetUserLoadingState extends AppStates {}

class AppLogoutSuccessState extends AppStates {}

class AppLogoutLoadingState extends AppStates {}

class AppLogoutErrorState extends AppStates {}

class AppGetUserErrorState extends AppStates
{
  late final String error;
  AppGetUserErrorState(this.error);
}

class AppGetAllUsersSuccessState extends AppStates {}

class AppGetAllUsersLoadingState extends AppStates {}

class AppGetChatsSuccessState extends AppStates {}

class AppGetChatsErrorState extends AppStates {}

class AppGetAllUsersErrorState extends AppStates
{
  late final String error;
  AppGetAllUsersErrorState(this.error);
}

class AppChangeBottomNavBarState extends AppStates {}

class AppRemoveImageSuccessState extends AppStates {}

class AppProfileImagePickedSuccessState extends AppStates {}

class AppProfileImagePickedErrorState extends AppStates {}

class AppUploadProfileImagePickedSuccessState extends AppStates {}

class AppUploadProfileImagePickedErrorState extends AppStates {}

class AppUploadProfileImagePickedLoadingState extends AppStates {}

class AppUserUpdateErrorState extends AppStates {}

class AppUserUpdateLoadingState extends AppStates {}

class AppSendMessageSuccessState extends AppStates {}

class AppGetChatsLoadingState extends AppStates {}

class AppFollowSuccessState extends AppStates {}

class AppUnfollowSuccessState extends AppStates {}

class AppGetFollowingLoadingState extends AppStates {}

class AppGetFollowingErrorState extends AppStates {}

class AppGetFollowingSuccessState extends AppStates {}

class AppSendMessageErrorState extends AppStates {}

class AppGetMessagesSuccessState extends AppStates {}

class AppSendImageMessagesSuccessState extends AppStates {}

class AppSendMessageLoadingState extends AppStates {}

class AppMessageImagePickedSuccessState extends AppStates {}

class AppSendImageMessagesErrorState extends AppStates {}

class AppChangeModeState extends AppStates {}

class AppShowSuccess extends AppStates {}
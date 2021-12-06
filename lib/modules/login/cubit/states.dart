abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class LoginLoadingState extends LoginStates {}

class LoginSuccessState extends LoginStates
{
  late final String uId;
  LoginSuccessState(this.uId);
}

class LoginErrorState extends LoginStates {}

class LoginChangePasswordVisibilityState extends LoginStates {}
abstract class RegisterStates {}

class RegisterInitialState extends RegisterStates {}

class RegisterLoadingState extends RegisterStates {}

class RegisterSuccessState extends RegisterStates {}

class RegisterErrorState extends RegisterStates
{
  late final String error;
  RegisterErrorState(this.error);
}

class CreateUserSuccessState extends RegisterStates {}

class CreateUserErrorState extends RegisterStates
{
  late final String error;
  CreateUserErrorState(this.error);
}

class RegisterChangePasswordVisibilityState extends RegisterStates{}
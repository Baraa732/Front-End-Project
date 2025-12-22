import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const LoginRequested(this.phone, this.password);

  @override
  List<Object?> get props => [phone, password];
}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String role;
  final String city;
  final String governorate;

  const RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    required this.role,
    required this.city,
    required this.governorate,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, password, role, city, governorate];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

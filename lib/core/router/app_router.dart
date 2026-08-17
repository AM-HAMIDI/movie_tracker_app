import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/navigation/main_navigation_screen.dart';
import '../../screens/detail/media_detail_screen.dart';
import '../../screens/lists/list_detail_screen.dart';
import '../../screens/profile/admin_users_screen.dart';
import '../../screens/profile/edit_profile_screen.dart'; // Make sure this screen is imported!

class AppRouter {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String mainNav = '/main-nav';
  static const String mediaDetail = '/media-detail';
  static const String editProfile = '/edit-profile'; // Route key
  static const String listDetail = '/list-detail';
  static const String adminUsers = '/admin-users';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case mainNav:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case mediaDetail:
        final imdbId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MediaDetailScreen(imdbId: imdbId),
        );
      case listDetail:
        final listId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ListDetailScreen(listId: listId),
        );
      case editProfile:
        // ADDED ROUTE CASE HERE
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case adminUsers:
        return MaterialPageRoute(builder: (_) => const AdminUsersScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
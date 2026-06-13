import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/services/storage_service.dart';
import '../../../app/routes/app_routes.dart';

/// Guards a route to users with a specific role.
/// Redirects to [Routes.LOGIN] if the stored role is absent or doesn't match.
class RoleMiddleware extends GetMiddleware {
  RoleMiddleware({required this.requiredRole, super.priority});

  final String requiredRole;

  @override
  RouteSettings? redirect(String? route) {
    final role = StorageService.to.userRole;
    if (role == null || role != requiredRole) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

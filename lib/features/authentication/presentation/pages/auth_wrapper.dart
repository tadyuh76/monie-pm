import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monie/core/services/notification_service.dart';
import 'package:monie/core/widgets/loading_screen.dart';
import 'package:monie/core/widgets/main_screen.dart';
import 'package:monie/di/injection.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_event.dart';
import 'package:monie/features/authentication/presentation/bloc/auth_state.dart';
import 'package:monie/features/authentication/presentation/pages/login_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _lastUpdatedUserId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        print('🔍 [AuthWrapper] listenWhen - previous: ${previous.runtimeType}, current: ${current.runtimeType}');
        // Only trigger navigation when auth state changes between authenticated/unauthenticated
        final shouldListen = (previous is Authenticated && current is Unauthenticated) ||
            (previous is Unauthenticated && current is Authenticated) ||
            (previous is AuthInitial);
        print('🔍 [AuthWrapper] listenWhen result: $shouldListen');
        return shouldListen;
      },
      listener: (context, state) {
        print('👂 [AuthWrapper] listener triggered - state: ${state.runtimeType}');
        if (!context.mounted) return;
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is Unauthenticated) {
          // Force navigation to login when unauthenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          });
        } else if (state is Authenticated) {
          // Get FCM token and update it in the database
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateFcmToken(context, state.user.id);
          });

          // Force navigation to main screen when authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainScreen()),
              (route) => false,
            );
          });
        }
      },
      builder: (context, state) {
        print('🏗️ [AuthWrapper] builder - state: ${state.runtimeType}');
        if (state is AuthInitial) {
          // If we're in initial state, trigger auth check
          context.read<AuthBloc>().add(GetCurrentUserEvent());
          return const LoadingScreen();
        } else if (state is AuthLoading) {
          return const LoadingScreen();
        } else if (state is Authenticated) {
          // Also update FCM token here to ensure it's called
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _updateFcmToken(context, state.user.id);
            }
          });
          return MainScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  void _updateFcmToken(BuildContext context, String userId) async {
    // Prevent duplicate updates for the same user
    if (_lastUpdatedUserId == userId) {
      print('⏭️ [AuthWrapper] FCM token already updated for user: $userId');
      return;
    }

    try {
      print('🔄 [AuthWrapper] Starting FCM token update for user: $userId');
      final notificationService = sl<NotificationService>();
      final token = await notificationService.getToken();
      
      if (token != null && context.mounted) {
        print('📤 [AuthWrapper] Sending FCM token to AuthBloc: ${token.substring(0, 20)}...');
        // Update FCM token in the database
        context.read<AuthBloc>().add(UpdateFcmTokenEvent(token: token));
        
        // Mark as updated for this user
        setState(() {
          _lastUpdatedUserId = userId;
        });
        print('✅ [AuthWrapper] FCM token update initiated successfully');
      } else {
        print('⚠️ [AuthWrapper] Cannot update FCM token: token=${token != null ? "exists" : "null"}, mounted=${context.mounted}');
      }
    } catch (e) {
      print('❌ [AuthWrapper] Failed to update FCM token: $e');
      print('   Stack trace: ${StackTrace.current}');
      // Silently fail - FCM token update is not critical
    }
  }
}

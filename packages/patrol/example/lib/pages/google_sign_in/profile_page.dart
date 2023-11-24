import 'package:example/cubit/auth_cubit.dart';
import 'package:example/handlers/notification_handler.dart';
import 'package:example/pages/push_notification/notification_success_page.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/style/colors.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Route<void> get profileRoute =>
    MaterialPageRoute(builder: (_) => const _ProfilePage());

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state case AuthStateUnauthenticated()) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: switch (state) {
            AuthStateAuthenticated(:final user) => _ProfilePageBody(user: user),
            _ => const SizedBox(),
          },
        );
      },
    );
  }
}

class _ProfilePageBody extends StatelessWidget {
  const _ProfilePageBody({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      top: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: IconButton(
            color: PTColors.lcYellow,
            icon: const Icon(
              Icons.power_settings_new,
              color: PTColors.lcYellow,
            ),
            onPressed: context.read<AuthCubit>().signOut,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${user.displayName}!',
              textAlign: TextAlign.center,
              style: PTTextStyles.bodyBold,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<NotificationHandler>()
                  .triggerPushNotification(
                    onPressed: () => Navigator.push(context, notificationRoute),
                  ),
              child: const Text('Notify me!'),
            ),
          ],
        ),
      ),
    );
  }
}

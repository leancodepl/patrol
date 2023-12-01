import 'package:example/cubit/auth_cubit.dart';
import 'package:example/handlers/notification_handler.dart';
import 'package:example/pages/google_sign_in/profile_page.dart';
import 'package:example/pages/push_notification/notification_success_page.dart';
import 'package:example/pages/quiz/welcome_page.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:example/ui/components/scaffold.dart';
import 'package:example/ui/style/test_style.dart';
import 'package:example/ui/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PTScaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state case AuthStateAuthenticated()) {
            await Navigator.push(context, profileRoute);
          } else if (state case AuthStateUnauthenticated()) {
            if (state.showError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login failed')),
              );
            }
          }
        },
        builder: (context, state) {
          return switch (state) {
            AuthStateLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            _ => const _HomePageBody(),
          };
        },
      ),
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PTElevatedButton(
          caption: 'Sign In with Google',
          onPressed: context.read<AuthCubit>().signInWithGoogle,
        ),
        const _TextSeparator(),
        PTElevatedButton(
          caption: 'Go to the quiz',
          onPressed: () => Navigator.push(context, quizWelcomeRoute),
        ),
        const _TextSeparator(),
        PTElevatedButton(
          caption: 'Send notification',
          onPressed: () =>
              context.read<NotificationHandler>().triggerPushNotification(
                    onPressed: () => Navigator.push(context, notificationRoute),
                  ),
        ),
      ],
    ).horizontallyPadded24;
  }
}

class _TextSeparator extends StatelessWidget {
  const _TextSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Text(
        'or',
        style: PTTextStyles.h4,
      ),
    );
  }
}

//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/pages/user/user_page.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/presentation/blocs/auth/logout/logout_bloc.dart';
import 'package:texas_buddy/presentation/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:texas_buddy/service_locator.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogoutBloc>(),
      child: BlocListener<LogoutBloc, LogoutState>(
        listenWhen: (prev, curr) =>
        curr is LogoutSuccess || curr is LogoutFailure,
        listener: (context, state) {
          if (state is LogoutSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/', // ← route to LoginPage
                  (route) => false, // ← delete all former routess
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out successfully")),
            );
          } else if (state is LogoutFailure) {
            // ✅ Utilisation correcte de `state.error`
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: const _UserPageContent(),
      ),
    );
  }
}

class _UserPageContent extends StatelessWidget {
  const _UserPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        backgroundColor: AppColors.texasBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea( // ✅ Ajout SafeArea
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.person, size: 120, color: AppColors.texasBlue),
              const SizedBox(height: 20),
              const Text(
                "You're logged in!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              BlocBuilder<LogoutBloc, LogoutState>(
                builder: (context, state) {
                  if (state is LogoutInProgress) {
                    return const CircularProgressIndicator();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.texasBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        onPressed: () {
                          context.read<LogoutBloc>().add(LogoutRequested());
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

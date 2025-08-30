//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : presentation/pages/user/user_page.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/logout/logout_bloc.dart';
import 'package:texas_buddy/features/user/presentation/cubits/user_overview_cubit.dart';
import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';

// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LogoutBloc>()),
        BlocProvider(create: (_) => getIt<UserOverviewCubit>()..loadCached()),
      ],
      child: const _UserPageContent(),
    );
  }
}

Widget _kv(String k, String v) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 160,
        child: Text(k, style: const TextStyle(color: Colors.black54)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          v,
          style: const TextStyle(fontFamily: 'monospace'),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _UserPageContent extends StatelessWidget {
  const _UserPageContent();

  Widget _avatar(UserProfile? u) {
    if (u?.avatarUrl != null && u!.avatarUrl!.isNotEmpty) {
      return CircleAvatar(radius: 48, backgroundImage: NetworkImage(u.avatarUrl!));
    }
    return const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 36));
  }

  String _cityStateZip(UserProfile u) {
    final parts = <String>[];
    if ((u.city ?? '').isNotEmpty) parts.add(u.city!.trim());
    final stateZip = [u.state, u.zipCode].where((s) => (s ?? '').isNotEmpty).join(' ');
    if (stateZip.isNotEmpty) parts.add(stateZip.trim());
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
        backgroundColor: AppColors.texasBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<UserOverviewCubit>().refresh(),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              const SizedBox(height: 24),
              BlocBuilder<UserOverviewCubit, UserOverviewState>(
                builder: (context, st) {
                  final u = st.user;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _avatar(u),
                      const SizedBox(height: 12),
                      Text(
                        u != null
                            ? (u.nickname ?? '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim())
                            : l10n.guest,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (u?.email != null)
                        Text(u!.email, style: const TextStyle(color: Colors.black54), textAlign: TextAlign.center),
                      if (u?.city != null || u?.state != null)
                        Text(
                          [u?.city, u?.state].where((e) => (e?.isNotEmpty ?? false)).join(', '),
                          style: const TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 8),

                      // Address card
                      Card(
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.home, color: AppColors.texasBlue),
                                  const SizedBox(width: 8),
                                  Text(l10n.address, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: Text(l10n.modify),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.profileEditComingSoon)),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (u?.address?.isNotEmpty ?? false) ? u!.address! : '—',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (u != null && _cityStateZip(u).isNotEmpty)
                                Text(_cityStateZip(u), style: const TextStyle(color: Colors.black54)),
                              if (u?.country?.isNotEmpty == true)
                                Text(u!.country!, style: const TextStyle(color: Colors.black54)),
                              if (u?.phone?.isNotEmpty == true) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 16, color: Colors.black54),
                                    const SizedBox(width: 6),
                                    Text(u!.phone!, style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Account & Security card
                      Card(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_user, color: AppColors.texasBlue),
                                  const SizedBox(width: 8),
                                  Text(l10n.accountSecurity, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _kv(l10n.registrationNumber, u?.registrationNumber ?? '—'),
                              const SizedBox(height: 6),
                              _kv(l10n.firstIp, u?.firstIp ?? '—'),
                              const SizedBox(height: 6),
                              _kv(l10n.secondIp, u?.secondIp ?? '—'),
                            ],
                          ),
                        ),
                      ),

                      if (st.loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (st.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(child: Text(st.error!, style: const TextStyle(color: Colors.red))),
                        ),
                    ],
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.editProfile),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.profileEditComingSoon)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<LogoutBloc, LogoutState>(
                      builder: (context, state) {
                        final busy = state is LogoutInProgress;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.texasBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: busy
                                ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Icon(Icons.logout),
                            label: Text(l10n.logout),
                            onPressed: busy ? null : () => context.read<LogoutBloc>().add(LogoutRequested()),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

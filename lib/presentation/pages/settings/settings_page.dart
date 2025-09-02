import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/core/l10n/locale_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (ctx, st) {
            String current = st.locale.languageCode; // 'en' | 'fr' | 'es'

            Widget tile({
              required String code,
              required IconData icon,
              required String title,
            }) {
              final selected = current == code;
              return ListTile(
                leading: Icon(icon),
                title: Text(title),
                trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () async {
                  final cubit = ctx.read<LocaleCubit>();
                  if (code == 'en') await cubit.setEnglish();
                  if (code == 'fr') await cubit.setFrench();
                  if (code == 'es') await cubit.setSpanish();
                },
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(l10n.settingsLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  tile(code: 'en', icon: Icons.language, title: l10n.languageEnglish),
                  const Divider(height: 0),
                  tile(code: 'fr', icon: Icons.language, title: l10n.languageFrench),
                  const Divider(height: 0),
                  tile(code: 'es', icon: Icons.language, title: l10n.languageSpanish),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

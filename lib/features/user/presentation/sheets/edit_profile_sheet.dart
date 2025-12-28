//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : feature/user/presentation/sheets/interests_sheet.dart
// Author : Morice
//-------------------------------------------------------------------------

//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/user/presentation/sheets/edit_profile_sheet.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';

class EditProfileSheet extends StatefulWidget {
  final UserProfile? initial;

  const EditProfileSheet({
    super.key,
    required this.initial,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late String _country;

  @override
  void initState() {
    super.initState();
    final u = widget.initial;
    _email = TextEditingController(text: u?.email ?? '');
    _address = TextEditingController(text: u?.address ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _country = (u?.country ?? '').trim().isEmpty ? 'US' : u!.country!.trim(); // placeholder simple
  }

  @override
  void dispose() {
    _email.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final bottomSafe = media.viewPadding.bottom;
    final keyboard = media.viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          // ✅ important: on garde l’espace clavier
          bottom: 12 + bottomSafe + keyboard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (fixe)
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.editProfile,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: l10n.cancel,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.profileEditSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Divider(),

            // ✅ FORM scrollable (clé)
            Flexible(
              child: SingleChildScrollView(
                // ✅ pour que le scroll parte bien du haut et évite les sauts
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.email,
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) {
                          final s = (v ?? '').trim();
                          if (s.isEmpty) return l10n.fieldRequired;
                          if (!s.contains('@') || !s.contains('.')) return l10n.invalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _address,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.address,
                          prefixIcon: const Icon(Icons.home),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.phone,
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _country.isEmpty ? 'US' : _country,
                        items: const [
                          DropdownMenuItem(value: 'US', child: Text('United States (US)')),
                          DropdownMenuItem(value: 'FR', child: Text('France (FR)')),
                          DropdownMenuItem(value: 'MX', child: Text('Mexico (MX)')),
                        ],
                        onChanged: (v) => setState(() => _country = v ?? 'US'),
                        decoration: InputDecoration(
                          labelText: l10n.country,
                          prefixIcon: const Icon(Icons.flag),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      // ✅ petit padding en bas pour ne pas coller aux boutons
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Actions (fixes)
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.texasBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) return;

                      Navigator.of(context).pop(<String, dynamic>{
                        'email': _email.text.trim(),
                        'address': _address.text.trim(),
                        'phone': _phone.text.trim(),
                        'country': _country,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.texasBlue,
                      foregroundColor: AppColors.whiteGlow,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      l10n.save,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteGlow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:texas_buddy/presentation/widgets/texas_buddy_loader.dart';
import 'package:texas_buddy/domain/usecases/auth/check_session_usecase.dart';
import 'package:texas_buddy/service_locator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _checkSessionUseCase = getIt<CheckSessionUseCase>();

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    final isLoggedIn = await _checkSessionUseCase();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/landing');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TexasBuddyLoader(message: "Chargement de Texas Buddy..."),
    );
  }
}

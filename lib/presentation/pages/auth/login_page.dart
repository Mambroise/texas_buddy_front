// lib/presentation/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../blocs/auth/login_bloc.dart';
import '../../blocs/auth/login_event.dart';
import '../../blocs/auth/login_state.dart';
import '../../../service_locator.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/texas_flag_floating.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.setVolume(0);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1) Vidéo plein écran
            Positioned.fill(
              child: _videoController.value.isInitialized
                  ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              )
                  : Container(color: Colors.black),
            ),

            // 2) Formulaire centré
            Center(
              child: Container(
                width: mq.width * 0.9,
                height: mq.height * 0.35,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildLoginForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) => curr.status != prev.status,
      listener: (context, state) {
        if (state.status == FormStatus.submissionFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.status == FormStatus.submissionSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (email) =>
                context.read<LoginBloc>().add(LoginEmailChanged(email)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (pwd) =>
                context.read<LoginBloc>().add(LoginPasswordChanged(pwd)),
          ),
          const SizedBox(height: 24),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              return state.status == FormStatus.submissionInProgress
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: state.status == FormStatus.valid
                    ? () =>
                    context.read<LoginBloc>().add(LoginSubmitted())
                    : null,
                child: const Text('Login'),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              // Pour garder la vidéo, on utilise une route semi-transparente
              Navigator.of(context).push(PageRouteBuilder(
                opaque: false, // la page signup ne cache pas le fond
                pageBuilder: (_, __, ___) => const SignupPage(),
              ));
            },
            child: const Text("first time ? Signup now"),
          ),
        ],
      ),
    );
  }
}

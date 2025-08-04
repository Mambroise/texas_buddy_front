//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/pages/auth/login_page.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:texas_buddy/presentation/theme/app_colors.dart';

import '../../../service_locator.dart';
import '../../blocs/form_status.dart';
import '../../blocs/auth/login_bloc.dart';
import '../../blocs/auth/login_event.dart';
import '../../blocs/auth/login_state.dart';
import '../../blocs/auth/signup_bloc.dart';
import '../../blocs/auth/signup_event.dart';
import '../../blocs/auth/signup_state.dart';
import '../../blocs/auth/forgot_password_bloc.dart';
import '../../blocs/auth/forgot_password_event.dart';
import '../../blocs/auth/forgot_password_state.dart';
import '../../blocs/auth/resend_registration_bloc.dart';
import '../../blocs/auth/resend_registration_event.dart';
import '../../blocs/auth/resend_registration_state.dart';

enum AuthFormType { login, register, forgotPassword, forgotRegistration }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late VideoPlayerController _videoController;
  AuthFormType _formType = AuthFormType.login;

  final _regEmailController    = TextEditingController();
  final _regNumberController   = TextEditingController();
  final _forgotEmailController = TextEditingController();
  final _resendRegEmailController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/t_b_intro_vid.mp4',
    )..initialize().then((_) {
      setState(() {});
      _videoController
        ..setLooping(true)
        ..setVolume(0)
        ..play();
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _regEmailController.dispose();
    _regNumberController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  void _toggleForm(AuthFormType type) {
    setState(() => _formType = type);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (_) => getIt<LoginBloc>()),
        BlocProvider<SignupBloc>(create: (_) => getIt<SignupBloc>()),
        BlocProvider<ForgotPasswordBloc>(
          create: (_) => getIt<ForgotPasswordBloc>(),
        ),
        BlocProvider<ResendRegistrationBloc>(
            create: (_) => getIt<ResendRegistrationBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.texasBlue,
          title: const Text('Texas Buddy'),
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Vidéo en fond
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

            // Container semi-transparent
            Center(
              child: Builder(
                builder: (innerCtx) {
                  return Container(
                    width: mq.width * 0.9,
                    height: mq.height * 0.43,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _formType == AuthFormType.login
                        ? _buildLoginForm(innerCtx)
                        : _formType == AuthFormType.register
                        ? _buildRegisterForm(innerCtx)
                        : _formType == AuthFormType.forgotPassword
                        ? _buildForgotPasswordForm(innerCtx)
                        : _buildForgotRegistrationForm(innerCtx),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOGIN ───────────────────────────────────────────────────────────────
  Widget _buildLoginForm(BuildContext ctx) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (e) =>
              BlocProvider.of<LoginBloc>(ctx).add(LoginEmailChanged(e)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          onChanged: (p) =>
              BlocProvider.of<LoginBloc>(ctx).add(LoginPasswordChanged(p)),
        ),
        const SizedBox(height: 24),
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (ctx, state) {
            if (state.status == FormStatus.submissionInProgress) {
              return const CircularProgressIndicator();
            }
            final mq = MediaQuery.of(context).size;
            return SizedBox(
              width: mq.width * 0.8,
              child: ElevatedButton(
                onPressed: state.status == FormStatus.valid
                    ? () => BlocProvider.of<LoginBloc>(ctx).add(LoginSubmitted())
                    : null,
                child: const Text('Login'),
              ),
            );
          },
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _toggleForm(AuthFormType.register),
          child: const Text("First time? Signup now!"),
        ),
        TextButton(
          onPressed: () => _toggleForm(AuthFormType.forgotPassword),
          child: const Text("Forgot password?"),
        ),
      ],
    );
  }

  // ─── REGISTER ────────────────────────────────────────────────────────────
  Widget _buildRegisterForm(BuildContext ctx) {
    return BlocListener<SignupBloc, SignupState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (ctx, state) {
        final msg = state.message ?? '';
        if (state.status == FormStatus.submissionFailure) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(msg)));
        } else if (state.status == FormStatus.submissionSuccess) {
          ScaffoldMessenger.of(ctx)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      child: Column(
        children: [
          TextFormField(
            controller: _regEmailController,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (e) =>
                BlocProvider.of<SignupBloc>(ctx)
                    .add(RegistrationEmailChanged(e)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regNumberController,
            decoration:
            const InputDecoration(labelText: 'Registration number'),
            onChanged: (n) =>
                BlocProvider.of<SignupBloc>(ctx)
                    .add(RegistrationNumberChanged(n)),
          ),
          const SizedBox(height: 24),
          BlocBuilder<SignupBloc, SignupState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (ctx, state) {
              if (state.status == FormStatus.submissionInProgress) {
                return const CircularProgressIndicator();
              }
              final mq = MediaQuery.of(context).size;
              return SizedBox(
              width: mq.width * 0.8,
              child: ElevatedButton(
              onPressed: state.status == FormStatus.valid
              ? () => BlocProvider.of<SignupBloc>(ctx)
                  .add(RegistrationSubmitted())
                  : null,
              child: const Text('Verify & Signup'),
              ),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.forgotRegistration),
            child: const Text('Forgot registration number?'),
          ),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.login),
            child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }

  // ─── RESET PWD REQUEST FORM ──────────────────────────────────────────────────
  Widget _buildForgotPasswordForm(BuildContext ctx) {
    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      buildWhen: (p, c) =>
      p.status != c.status || p.reset2FAStatus != c.reset2FAStatus,
      builder: (ctx, state) {
        // Étape 3 : formulaire de nouveau mot de passe
        if (state.reset2FAStatus == FormStatus.submissionSuccess) {
          return _buildSetPasswordForm(ctx);
        }

        // Étape 2 : formulaire de code de vérification
        if (state.status == FormStatus.submissionSuccess) {
          return _buildVerifyResetCodeForm(ctx);
        }

        // Étape 1 : formulaire de demande de reset
        return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (ctx, state) {
            final msg = state.message ?? '';
            if (state.status == FormStatus.submissionFailure) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
            } else if (state.status == FormStatus.submissionSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
            }
          },
          child: Column(
            children: [
              TextFormField(
                controller: _forgotEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (e) => BlocProvider.of<ForgotPasswordBloc>(ctx)
                    .add(ForgotPasswordEmailChanged(e)),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (ctx, state) {
                  if (state.status == FormStatus.submissionInProgress) {
                    return const CircularProgressIndicator();
                  }
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: state.status == FormStatus.valid
                          ? () => BlocProvider.of<ForgotPasswordBloc>(ctx)
                          .add(ForgotPasswordSubmitted())
                          : null,
                      child: const Text('Send reset code'),
                    ),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _toggleForm(AuthFormType.login),
                child: const Text("Back to Login"),
              ),
            ],
          ),
        );
      },
    );
  }



  // ─── RESEND REGISTRATION FORM ──────────────────────────────────────────────────────
  Widget _buildForgotRegistrationForm(BuildContext ctx) {
    return BlocListener<ResendRegistrationBloc, ResendRegistrationState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (ctx, state) {
        final msg = state.message ?? '';
        if (state.status == FormStatus.submissionFailure) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
        } else if (state.status == FormStatus.submissionSuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      child: Column(
        children: [
          TextFormField(
            controller: _resendRegEmailController,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (e) => BlocProvider.of<ResendRegistrationBloc>(ctx)
                .add(ResendRegistrationEmailChanged(e)),
          ),
          const SizedBox(height: 24),
          BlocBuilder<ResendRegistrationBloc, ResendRegistrationState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (ctx, state) {
              if (state.status == FormStatus.submissionInProgress) {
                return const CircularProgressIndicator();
              }
              final mq = MediaQuery.of(context).size;
              return SizedBox(
                width: mq.width * 0.8,
                child: ElevatedButton(
                  onPressed: state.status == FormStatus.valid
                      ? () => BlocProvider.of<ResendRegistrationBloc>(ctx)
                      .add(ResendRegistrationSubmitted())
                      : null,
                  child: const Text('Send registration number'),
                ),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.register),
            child: const Text("Back to Register"),
          ),
        ],
      ),
    );

  }

  // ─── RESET PWD 2FA FORM ──────────────────────────────────────────────────────
  Widget _buildVerifyResetCodeForm(BuildContext ctx) {
    return Column(
      children: [
        const Text(
          "Enter your secret verification code",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Code'),
          onChanged: (code) =>
              BlocProvider.of<ForgotPasswordBloc>(ctx).add(ResetPassword2FACodeChanged(code)),
        ),
        const SizedBox(height: 24),
        BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
          buildWhen: (p, c) => p.reset2FAStatus != c.reset2FAStatus,
          builder: (ctx, state) {
            if (state.reset2FAStatus == FormStatus.submissionInProgress) {
              return const CircularProgressIndicator();
            }
            final mq = MediaQuery.of(context).size;
            return SizedBox(
              width: mq.width * 0.8,
              child: ElevatedButton(
                onPressed: () => BlocProvider.of<ForgotPasswordBloc>(ctx)
                    .add(ResetPassword2FACodeSubmitted()),
                child: const Text("Send"),
              ),
            );
          },
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            BlocProvider.of<ForgotPasswordBloc>(ctx)
                .add(ForgotPasswordResetStateCleared());
            _toggleForm(AuthFormType.login);
          },
          child: const Text("Back to login"),
        ),
      ],
    );
  }

// ─── SET PWD FORM ──────────────────────────────────────────────────────
  Widget _buildSetPasswordForm(BuildContext ctx) {
    final mq = MediaQuery.of(context).size;

    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set your new password",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // New password field
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "New password"),
              onChanged: (value) {
                BlocProvider.of<ForgotPasswordBloc>(ctx)
                    .add(NewPasswordChanged(value));
              },
            ),
            const SizedBox(height: 12),

            // Confirm password field
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm password"),
              onChanged: (value) {
                BlocProvider.of<ForgotPasswordBloc>(ctx)
                    .add(ConfirmPasswordChanged(value));
              },
            ),
            const SizedBox(height: 12),

            // Password rules
            _buildPasswordValidation(state),

            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: mq.width * 0.8,
              child: ElevatedButton(
                onPressed: state.isPasswordValid && state.passwordsMatch
                    ? () {
                  BlocProvider.of<ForgotPasswordBloc>(ctx)
                      .add(NewPasswordSubmitted());
                }
                    : null,
                child: const Text("Submit"),
              ),
            ),

            const Spacer(),

            // Back to login
            TextButton(
              onPressed: () {
                BlocProvider.of<ForgotPasswordBloc>(ctx)
                    .add(ForgotPasswordResetStateCleared());
                _toggleForm(AuthFormType.login);
              },
              child: const Text("Back to login"),
            ),
          ],
        );
      },
    );
  }

  // ─── PWD VALIDATION FORM ──────────────────────────────────────────────────────
  Widget _buildPasswordValidation(ForgotPasswordState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRule("At least 8 characters", state.lengthOK),
        _buildRule("At least one number", state.hasNumber),
        _buildRule("At least one special character", state.hasSpecial),
        _buildRule("At least one uppercase letter", state.hasUpper),
        _buildRule("At least one letter", state.hasLetter),
      ],
    );
  }

  Widget _buildRule(String label, bool satisfied) {
    return Row(
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.cancel,
          color: satisfied ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: satisfied ? Colors.green : Colors.red),
        ),
      ],
    );
  }

}


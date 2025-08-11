//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/pages/auth/login_page.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

import 'package:texas_buddy/app/router/app_router.dart';
import 'package:texas_buddy/presentation/widgets/texas_buddy_loader.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/core/utils/form_status.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/login/login_event.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/login/login_state.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/signup/signup_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/signup/signup_event.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/signup/signup_state.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/password/forgot_password_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/password/forgot_password_event.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/password/forgot_password_state.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/registration/resend_registration_bloc.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/registration/resend_registration_event.dart';
import 'package:texas_buddy/features/auth/presentation/blocs/registration/resend_registration_state.dart';

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
  bool _showNewPassword = false;
  bool _isLoading = true;


  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();




  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/t_b_intro_vid.mp4',
    )..initialize().then((_) async {
      _videoController
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      // 🕐 Attendre 2 secondes minimum (simulateur d’intro/splash fluide)
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _regEmailController.dispose();
    _regNumberController.dispose();
    _forgotEmailController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();

    super.dispose();
  }

  void _toggleForm(AuthFormType type) {
    setState(() => _formType = type);
  }

  void _prefillLogin(BuildContext ctx,String email, String password) {
    _loginEmailController.text = email;
    _loginPasswordController.text = password;

    // Envoie dans le bloc
    ctx.read<LoginBloc>().add(LoginEmailChanged(email));
    ctx.read<LoginBloc>().add(LoginPasswordChanged(password));

    // Revient au formulaire login
    _toggleForm(AuthFormType.login);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: TexasBuddyLoader(message: "Bienvenue sur Texas Buddy..."),
        ),
      );
    }

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
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
      prev.status != curr.status &&
          curr.status == FormStatus.submissionFailure,
      listener: (ctx, state) {
        // Affiche l’erreur si le usecase a échoué
        final msg = state.errorMessage ?? 'Login failed';
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (e) => ctx.read<LoginBloc>().add(LoginEmailChanged(e)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _showNewPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _showNewPassword = !_showNewPassword);
                },
              ),
            ),
            obscureText: !_showNewPassword,
            onChanged: (p) => ctx.read<LoginBloc>().add(LoginPasswordChanged(p)),
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
                      ? () => ctx.read<LoginBloc>().add(LoginSubmitted())
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
      ),
    );
  }



  // ─── REGISTER ────────────────────────────────────────────────────────────
  Widget _buildRegisterForm(BuildContext ctx) {
    final signupState = ctx.watch<SignupBloc>().state;

    // ✅ Étape 3 : formulaire de mot de passe après succès du code 2FA
    if (signupState.verificationStatus == FormStatus.submissionSuccess) {
      return _buildSetPasswordForm(ctx);
    }

    // ✅ Étape 2 : formulaire de code 2FA après succès du code d'inscription
    if (signupState.status == FormStatus.submissionSuccess) {
      return _buildVerifyResetCodeForm(ctx);
    }

    // ✅ Étape 1 : formulaire initial email + sign_up_number
    return BlocListener<SignupBloc, SignupState>(
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
            controller: _regEmailController,
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (e) =>
                ctx.read<SignupBloc>().add(RegistrationEmailChanged(e)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regNumberController,
            decoration: const InputDecoration(labelText: 'Registration number'),
            onChanged: (n) =>
                ctx.read<SignupBloc>().add(RegistrationNumberChanged(n)),
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
                      ? () => ctx.read<SignupBloc>().add(RegistrationSubmitted())
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

  // ─── RESET PWD / REGISTRATION 2FA FORM ──────────────────────────────────────────────────────
  Widget _buildVerifyResetCodeForm(BuildContext ctx) {
    final signupState = ctx.watch<SignupBloc>().state;
    final forgotPwdState = ctx.watch<ForgotPasswordBloc>().state;
    final mq = MediaQuery.of(context).size;

    final isRegister2FA = _formType == AuthFormType.register &&
        signupState.status == FormStatus.submissionSuccess;

    final isForgot2FA = _formType == AuthFormType.forgotPassword &&
        forgotPwdState.status == FormStatus.submissionSuccess;

    final status = isRegister2FA
        ? signupState.verificationStatus
        : forgotPwdState.reset2FAStatus;

    return Column(
      children: [
        Text(
          isRegister2FA
              ? "Enter the code sent to complete registration"
              : "Enter your secret verification code",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Code input
        TextFormField(
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Code'),
          onChanged: (code) {
            if (isRegister2FA) {
              ctx.read<SignupBloc>().add(Registration2FACodeChanged(code));
            } else {
              ctx.read<ForgotPasswordBloc>().add(ResetPassword2FACodeChanged(code));
            }
          },
        ),
        const SizedBox(height: 24),
        // Submit button
        status == FormStatus.submissionInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
          width: mq.width * 0.8,
          child: ElevatedButton(
            onPressed: () {
              if (isRegister2FA) {
                ctx.read<SignupBloc>().add(
                    VerifyRegistration2FACodeSubmitted(signupState.verificationCode));
              } else {
                ctx.read<ForgotPasswordBloc>().add(ResetPassword2FACodeSubmitted());
              }
            },
            child: const Text("Send"),
          ),
        ),
        const Spacer(),
        // Back to login
        TextButton(
          onPressed: () {
            if (isRegister2FA) {
              _toggleForm(AuthFormType.login);
              ctx.read<SignupBloc>().add(RegistrationPasswordStateCleared());
            } else {
              ctx.read<ForgotPasswordBloc>().add(ForgotPasswordResetStateCleared());
              _toggleForm(AuthFormType.login);
            }
          },
          child: const Text("Back to login"),
        ),
      ],
    );
  }


// ─── SET PWD FORM (unifié register + reset) ─────────────────────────────
  Widget _buildSetPasswordForm(BuildContext ctx) {
    final mq = MediaQuery.of(context).size;
    final isRegistration = _formType == AuthFormType.register;
    final signupState = ctx.watch<SignupBloc>().state;
    final forgotState = ctx.watch<ForgotPasswordBloc>().state;

    if (isRegistration) {
      return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listenWhen: (_, curr) => curr.passwordStatus == FormStatus.submissionSuccess,
        listener: (ctx, state) {
          _prefillLogin(ctx, state.email, state.newPassword);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset. You can log in now.")),
          );
        },
        child: _buildSetPasswordFormContent(
          ctx,
          isRegistration,
          signupState,
          forgotState,
          mq,
        ),
      );
    } else {
      return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
        listenWhen: (_, curr) => curr.passwordStatus == FormStatus.submissionSuccess,
        listener: (ctx, state) {
          _prefillLogin(ctx, state.email, state.newPassword);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password reset. You can log in now.")),
          );
        },
        child: _buildSetPasswordFormContent(
          ctx,
          isRegistration,
          signupState,
          forgotState,
          mq,
        ),
      );
    }
  }

  Widget _buildSetPasswordFormContent(
      BuildContext ctx,
      bool isRegistration,
      SignupState signupState,
      ForgotPasswordState forgotState,
      Size mq,
      ) {
    final newPassword = isRegistration ? signupState.newPassword : forgotState.newPassword;
    final confirmPassword = isRegistration ? signupState.confirmPassword : forgotState.confirmPassword;
    final isPasswordValid = isRegistration ? signupState.isPasswordValid : forgotState.isPasswordValid;
    final passwordsMatch = isRegistration ? signupState.passwordsMatch : forgotState.passwordsMatch;

    return Column(
      children: [
        Text(
          isRegistration ? "Set your password" : "Set your new password",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        TextFormField(
          obscureText: !_showNewPassword,
          decoration: InputDecoration(
            labelText: "New password",
            suffixIcon: IconButton(
              icon: Icon(
                _showNewPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() => _showNewPassword = !_showNewPassword);
              },
            ),
          ),
          onChanged: (value) {
            if (isRegistration) {
              ctx.read<SignupBloc>().add(RegistrationPasswordChanged(value));
            } else {
              ctx.read<ForgotPasswordBloc>().add(NewPasswordChanged(value));
            }
          },
        ),

        const SizedBox(height: 8),

        TextFormField(
          obscureText: !_showNewPassword,
          decoration: const InputDecoration(labelText: "Confirm password"),
          onChanged: (value) {
            if (isRegistration) {
              ctx.read<SignupBloc>().add(RegistrationConfirmPasswordChanged(value));
            } else {
              ctx.read<ForgotPasswordBloc>().add(ConfirmPasswordChanged(value));
            }
          },
        ),

        if (!passwordsMatch && confirmPassword.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              "Passwords do not match",
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),

        const SizedBox(height: 10),
        isRegistration
            ? _buildPasswordValidationFromSignup(signupState)
            : _buildPasswordValidation(forgotState),
        const SizedBox(height: 10),

        SizedBox(
          width: mq.width * 0.8,
          child: ElevatedButton(
            onPressed: isPasswordValid && passwordsMatch
                ? () {
              if (isRegistration) {
                ctx.read<SignupBloc>().add(RegistrationSetPasswordSubmitted());
              } else {
                ctx.read<ForgotPasswordBloc>().add(NewPasswordSubmitted());
              }
            }
                : null,
            child: const Text("Submit"),
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: () {
            if (isRegistration) {
              ctx.read<SignupBloc>().add(RegistrationPasswordChanged(''));
              ctx.read<SignupBloc>().add(RegistrationConfirmPasswordChanged(''));
            } else {
              ctx.read<ForgotPasswordBloc>().add(ForgotPasswordResetStateCleared());
            }
            _toggleForm(AuthFormType.login);
          },
          child: const Text("Back to login"),
        ),
      ],
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

  Widget _buildPasswordValidationFromSignup(SignupState state) {
    // On refait les tests à partir du mot de passe
    final pwd = state.newPassword;
    final hasLength = pwd.length >= 8;
    final hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(pwd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRule("At least 8 characters", hasLength),
        _buildRule("At least one number", hasNumber),
        _buildRule("At least one special character", hasSpecial),
        _buildRule("At least one uppercase letter", hasUpper),
        _buildRule("At least one letter", hasLetter),
      ],
    );
  }


}


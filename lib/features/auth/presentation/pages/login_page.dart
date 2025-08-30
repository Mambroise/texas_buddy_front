//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : presentation/pages/auth/login_page.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

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

// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

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

  bool _bgVisible = false;
  bool _cardVisible = false;
  static const _fade300 = Duration(milliseconds: 300);
  static const _fade450 = Duration(milliseconds: 450);

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/t_b_intro_vid.mp4')
      ..initialize().then((_) async {
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();

        setState(() => _isLoading = false);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          setState(() => _bgVisible = true);
          await Future.delayed(const Duration(milliseconds: 120));
          if (!mounted) return;
          setState(() => _cardVisible = true);
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
    ctx.read<LoginBloc>().add(LoginEmailChanged(email));
    ctx.read<LoginBloc>().add(LoginPasswordChanged(password));
    _toggleForm(AuthFormType.login);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final l10n = context.l10n;

    return AnimatedSwitcher(
      duration: _fade450,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _isLoading
          ? Scaffold(
        key: const ValueKey('loader'),
        backgroundColor: Colors.white,
        body: Center(child: TexasBuddyLoader(message: l10n.loginLoading)),
      )
          : _buildMainScaffold(mq),
    );
  }

  Widget _buildMainScaffold(Size mq) {
    final l10n = context.l10n;

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (_) => getIt<LoginBloc>()),
        BlocProvider<SignupBloc>(create: (_) => getIt<SignupBloc>()),
        BlocProvider<ForgotPasswordBloc>(create: (_) => getIt<ForgotPasswordBloc>()),
        BlocProvider<ResendRegistrationBloc>(create: (_) => getIt<ResendRegistrationBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.texasBlue,
          title: Text(l10n.appTitle),
          titleTextStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background video
            Positioned.fill(
              child: _videoController.value.isInitialized
                  ? AnimatedOpacity(
                opacity: _bgVisible ? 1 : 0,
                duration: _fade450,
                curve: Curves.easeOut,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              )
                  : Container(color: Colors.black),
            ),
            // Card + content with fade
            Center(
              child: AnimatedOpacity(
                opacity: _cardVisible ? 1 : 0,
                duration: _fade300,
                curve: Curves.easeOut,
                child: Builder(
                  builder: (innerCtx) => _buildAuthCard(innerCtx, mq),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard(BuildContext innerCtx, Size mq) {
    return Container(
      width: mq.width * 0.9,
      height: mq.height * 0.43,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSwitcher(
        duration: _fade300,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: _buildFormContent(innerCtx, key: ValueKey(_formType)),
      ),
    );
  }

  Widget _buildFormContent(BuildContext ctx,{Key? key}) {
    switch (_formType) {
      case AuthFormType.login:
        return KeyedSubtree(key: key, child: _buildLoginForm(ctx));
      case AuthFormType.register:
        return KeyedSubtree(key: key, child: _buildRegisterForm(ctx));
      case AuthFormType.forgotPassword:
        return KeyedSubtree(key: key, child: _buildForgotPasswordForm(ctx));
      case AuthFormType.forgotRegistration:
        return KeyedSubtree(key: key, child: _buildForgotRegistrationForm(ctx));
    }
  }

  // ─── LOGIN ───────────────────────────────────────────────────────────────
  Widget _buildLoginForm(BuildContext ctx) {
    final l10n = context.l10n;

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
      prev.status != curr.status && curr.status == FormStatus.submissionFailure,
      listener: (ctx, state) {
        final msg = state.errorMessage ?? l10n.loginFailed;
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: InputDecoration(labelText: l10n.email),
            onChanged: (e) => ctx.read<LoginBloc>().add(LoginEmailChanged(e)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            decoration: InputDecoration(
              labelText: l10n.password,
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
              final mq = MediaQuery.of(ctx).size;
              return SizedBox(
                width: mq.width * 0.8,
                child: ElevatedButton(
                  onPressed: state.status == FormStatus.valid
                      ? () => ctx.read<LoginBloc>().add(LoginSubmitted())
                      : null,
                  child: Text(l10n.login),
                ),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.register),
            child: Text(l10n.firstTimeSignup),
          ),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.forgotPassword),
            child: Text(l10n.forgotPasswordQ),
          ),
        ],
      ),
    );
  }

  // ─── REGISTER ────────────────────────────────────────────────────────────
  Widget _buildRegisterForm(BuildContext ctx) {
    final l10n = context.l10n;
    final signupState = ctx.watch<SignupBloc>().state;

    if (signupState.verificationStatus == FormStatus.submissionSuccess) {
      return _buildSetPasswordForm(ctx);
    }
    if (signupState.status == FormStatus.submissionSuccess) {
      return _buildVerifyResetCodeForm(ctx);
    }

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
            decoration: InputDecoration(labelText: l10n.email),
            onChanged: (e) => ctx.read<SignupBloc>().add(RegistrationEmailChanged(e)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regNumberController,
            decoration: InputDecoration(labelText: l10n.registrationNumber),
            onChanged: (n) => ctx.read<SignupBloc>().add(RegistrationNumberChanged(n)),
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
                  child: Text(l10n.verifyAndSignup),
                ),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.forgotRegistration),
            child: Text(l10n.forgotRegistrationNumberQ),
          ),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.login),
            child: Text(l10n.backToLogin),
          ),
        ],
      ),
    );
  }

  // ─── RESET PWD REQUEST FORM ─────────────────────────────────────────────
  Widget _buildForgotPasswordForm(BuildContext ctx) {
    final l10n = context.l10n;

    return BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
      buildWhen: (p, c) => p.status != c.status || p.reset2FAStatus != c.reset2FAStatus,
      builder: (ctx, state) {
        if (state.reset2FAStatus == FormStatus.submissionSuccess) {
          return _buildSetPasswordForm(ctx);
        }
        if (state.status == FormStatus.submissionSuccess) {
          return _buildVerifyResetCodeForm(ctx);
        }

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
                decoration: InputDecoration(labelText: l10n.email),
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
                    width: MediaQuery.of(ctx).size.width * 0.8,
                    child: ElevatedButton(
                      onPressed: state.status == FormStatus.valid
                          ? () => BlocProvider.of<ForgotPasswordBloc>(ctx)
                          .add(ForgotPasswordSubmitted())
                          : null,
                      child: Text(l10n.sendResetCode),
                    ),
                  );
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _toggleForm(AuthFormType.login),
                child: Text(l10n.backToLogin),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── RESEND REGISTRATION FORM ───────────────────────────────────────────
  Widget _buildForgotRegistrationForm(BuildContext ctx) {
    final l10n = context.l10n;

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
            decoration: InputDecoration(labelText: l10n.email),
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
                  child: Text(l10n.sendRegistrationNumber),
                ),
              );
            },
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _toggleForm(AuthFormType.register),
            child: Text(l10n.backToRegister),
          ),
        ],
      ),
    );
  }

  // ─── RESET PWD / REGISTRATION 2FA FORM ──────────────────────────────────
  Widget _buildVerifyResetCodeForm(BuildContext ctx) {
    final l10n = context.l10n;
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
              ? l10n.enterRegistrationCodeTitle
              : l10n.enterResetCodeTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        TextFormField(
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.codeLabel),
          onChanged: (code) {
            if (isRegister2FA) {
              ctx.read<SignupBloc>().add(Registration2FACodeChanged(code));
            } else {
              ctx.read<ForgotPasswordBloc>().add(ResetPassword2FACodeChanged(code));
            }
          },
        ),
        const SizedBox(height: 24),
        status == FormStatus.submissionInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
          width: mq.width * 0.8,
          child: ElevatedButton(
            onPressed: () {
              if (isRegister2FA) {
                ctx.read<SignupBloc>().add(
                  VerifyRegistration2FACodeSubmitted(signupState.verificationCode),
                );
              } else {
                ctx.read<ForgotPasswordBloc>().add(ResetPassword2FACodeSubmitted());
              }
            },
            child: Text(l10n.send),
          ),
        ),
        const Spacer(),
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
          child: Text(l10n.backToLogin),
        ),
      ],
    );
  }

  // ─── SET PWD FORM (shared for register + reset) ─────────────────────────
  Widget _buildSetPasswordForm(BuildContext ctx) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context).size;
    final isRegistration = _formType == AuthFormType.register;
    final signupState = ctx.watch<SignupBloc>().state;
    final forgotState = ctx.watch<ForgotPasswordBloc>().state;

    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listenWhen: (_, curr) => curr.passwordStatus == FormStatus.submissionSuccess,
      listener: (ctx, state) {
        _prefillLogin(ctx, state.email, state.newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordResetSuccess)),
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

  Widget _buildSetPasswordFormContent(
      BuildContext ctx,
      bool isRegistration,
      SignupState signupState,
      ForgotPasswordState forgotState,
      Size mq,
      ) {
    final l10n = context.l10n;

    final newPassword = isRegistration ? signupState.newPassword : forgotState.newPassword;
    final confirmPassword = isRegistration ? signupState.confirmPassword : forgotState.confirmPassword;
    final isPasswordValid = isRegistration ? signupState.isPasswordValid : forgotState.isPasswordValid;
    final passwordsMatch = isRegistration ? signupState.passwordsMatch : forgotState.passwordsMatch;

    return Column(
      children: [
        Text(
          isRegistration ? l10n.setYourPassword : l10n.setYourNewPassword,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        TextFormField(
          obscureText: !_showNewPassword,
          decoration: InputDecoration(
            labelText: l10n.newPassword,
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
          decoration: InputDecoration(labelText: l10n.confirmPassword),
          onChanged: (value) {
            if (isRegistration) {
              ctx.read<SignupBloc>().add(RegistrationConfirmPasswordChanged(value));
            } else {
              ctx.read<ForgotPasswordBloc>().add(ConfirmPasswordChanged(value));
            }
          },
        ),

        if (!passwordsMatch && confirmPassword.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l10n.passwordsDoNotMatch,
              style: const TextStyle(color: Colors.red, fontSize: 13),
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
            child: Text(l10n.submit),
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
          child: Text(l10n.backToLogin),
        ),
      ],
    );
  }

  // ─── PWD VALIDATION FORM ────────────────────────────────────────────────
  Widget _buildPasswordValidation(ForgotPasswordState state) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRule(l10n.passwordRuleLength, state.lengthOK),
        _buildRule(l10n.passwordRuleNumber, state.hasNumber),
        _buildRule(l10n.passwordRuleSpecial, state.hasSpecial),
        _buildRule(l10n.passwordRuleUpper, state.hasUpper),
        _buildRule(l10n.passwordRuleLetter, state.hasLetter),
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
    final l10n = context.l10n;

    final pwd = state.newPassword;
    final hasLength = pwd.length >= 8;
    final hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(pwd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRule(l10n.passwordRuleLength, hasLength),
        _buildRule(l10n.passwordRuleNumber, hasNumber),
        _buildRule(l10n.passwordRuleSpecial, hasSpecial),
        _buildRule(l10n.passwordRuleUpper, hasUpper),
        _buildRule(l10n.passwordRuleLetter, hasLetter),
      ],
    );
  }
}

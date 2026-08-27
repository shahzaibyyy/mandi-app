import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: AppConstants.loginEmail);
  final _password = TextEditingController();
  var _loading = false;
  var _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await ref.read(authControllerProvider.notifier).login(
      _email.text,
      _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.ok) {
      context.go('/');
      return;
    }
    final message = switch (result.failure) {
      AuthFailure.invalidCredentials => 'Invalid email or password.',
      AuthFailure.deviceAlreadyRegistered =>
        'This account is already active on another device.',
      null => 'Login failed.',
    };
    SnackbarUtils.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(AppConstants.logoAsset, width: 88),
                    const SizedBox(height: 16),
                    const Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to start collecting mandi fees.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      requiredField: true,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Password',
                      controller: _password,
                      requiredField: true,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        child: Text(_obscure ? 'Show password' : 'Hide password'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: _loading ? 'Signing in…' : 'Sign in',
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'One account works on the first device where you sign in.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

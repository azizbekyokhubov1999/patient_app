import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    if (!isValid) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? value) {
    if ((value ?? '').length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topHeight = screenHeight * 0.43;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  SizedBox(height: topHeight),
                  Expanded(child: Container(color: AppColors.background)),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                children: [
                  SizedBox(height: (topHeight * 0.12).clamp(18, 38)),
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 70,
                    fit: BoxFit.contain,
                    width: 100,
                    colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                    semanticsLabel: 'Logo',
                  ),
                  SizedBox(height: (topHeight * 0.11).clamp(12, 24)),
                  Text(
                    'Let\'s get you Login!',
                    style: textTheme.headlineLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hi! Welcome back, you\'ve been missed',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: (topHeight * 0.09).clamp(10, 20)),
                  _SignInCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    emailValidator: _emailValidator,
                    passwordValidator: _passwordValidator,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onForgotPassword: () => context.go(AppPaths.newPassword),
                    onSignIn: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.go(AppPaths.home);
                      }
                    },
                    onSignUp: () => context.go(AppPaths.createAccount),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.emailValidator,
    required this.passwordValidator,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSignIn,
    required this.onSignUp,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const fieldFill = Color(0xFFF2F2F2);

    InputDecoration fieldDecoration({
      required String hint,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        filled: true,
        fillColor: fieldFill,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialCircleButton(child:     SvgPicture.asset(
                            'assets/images/apple-black-logo.svg',
                            height: 32,
                            fit: BoxFit.contain,
                            width: 32,
                          
                          ),),
                SizedBox(width: 14),
                _SocialCircleButton(
                  child: SvgPicture.asset(
                            'assets/images/google-icon.svg',
                            height: 32,
                            fit: BoxFit.contain,
                            width: 32,
                          
                            ),
                ),
                SizedBox(width: 14),
                _SocialCircleButton(
                  child: SvgPicture.asset(
                            'assets/images/facebook-2-logo.svg',
                            height: 32,
                            fit: BoxFit.contain,
                            width: 32,
                          
                            ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.stroke)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Or sign in with',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.stroke)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Email', style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: fieldDecoration(hint: 'example@gmail.com'),
              validator: emailValidator,
            ),
            const SizedBox(height: 10),
            Text('Password', style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 6),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: fieldDecoration(
                hint: '***************',
                suffixIcon: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              validator: passwordValidator,
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.yellow,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.yellow,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                  children: [
                    const TextSpan(text: 'Don\'t have an account? '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: onSignUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.yellow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.stroke),
      ),
      child: Center(child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topHeight = constraints.maxHeight * 0.42;

            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: topHeight),
                    Expanded(child: Container(color: AppColors.background)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        children: [
                          SizedBox(height: (topHeight * 0.2).clamp(20, 46)),
                          Text(
                            'Create Account',
                            style: textTheme.headlineLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Fill your information below or register\nwith your social account.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: (topHeight * 0.18).clamp(14, 24)),
                          _CreateAccountCard(
                            formKey: _formKey,
                            nameController: _nameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            acceptedTerms: _acceptedTerms,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            onTermsChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                            onSignUp: () {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              if (!_acceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please accept Terms & Condition')),
                                );
                                return;
                              }
                              context.go(AppPaths.verifyCode);
                            },
                            onSignIn: () => context.go(AppPaths.signIn),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CreateAccountCard extends StatelessWidget {
  const _CreateAccountCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.acceptedTerms,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onTermsChanged,
    required this.onSignUp,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool acceptedTerms;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onSignUp;
  final VoidCallback onSignIn;

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialCircleButton(
                  child: SvgPictureAsset(path: 'assets/images/apple-black-logo.svg'),
                ),
                SizedBox(width: 14),
                _SocialCircleButton(
                  child: SvgPictureAsset(path: 'assets/images/google-icon.svg'),
                ),
                SizedBox(width: 14),
                _SocialCircleButton(
                  child: SvgPictureAsset(path: 'assets/images/facebook-2-logo.svg'),
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
                    'Or sign up with',
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.stroke)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Name', style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: fieldDecoration(hint: 'John Doe'),
              validator: (value) => (value ?? '').trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 10),
            Text('Email', style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.primaryText),
              decoration: fieldDecoration(hint: 'example@gmail.com'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                  return 'Enter a valid email';
                }
                return null;
              },
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
              validator: (value) =>
                  (value ?? '').length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.secondaryText, width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: onTermsChanged,
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                      children: const [
                        TextSpan(text: 'Agree with '),
                        TextSpan(
                          text: 'Terms & Condition',
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Sign Up'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: onSignIn,
                        child: const Text(
                          'Sign In',
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

class SvgPictureAsset extends StatelessWidget {
  const SvgPictureAsset({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      height: 32,
      width: 32,
      fit: BoxFit.contain,
    );
  }
}

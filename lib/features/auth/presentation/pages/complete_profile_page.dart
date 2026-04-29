import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_paths.dart';
import '../../../../core/theme/app_colors.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _gender;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    InputDecoration baseDecoration({
      required String hintText,
      Color hintColor = AppColors.secondaryText,
      Widget? prefixIcon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: AppColors.stroke,
        prefixIcon: prefixIcon,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () => context.go(AppPaths.verifyCode),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.stroke),
                              ),
                              child: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Complete Your Profile',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Don’t worry, only you can see your personal\ndata. No one else will be able to see it.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 26),
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.stroke,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 74,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 6,
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          'Name',
                          style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.primaryText),
                          decoration: baseDecoration(hintText: 'Ex. John Doe'),
                          validator: (value) =>
                              (value ?? '').trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Phone Number',
                          style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.primaryText),
                          decoration: baseDecoration(
                            hintText: 'Enter Phone Number',
                            prefixIcon: SizedBox(
                              width: 72,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '+1',
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.secondaryText,
                                  ),
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 1,
                                    height: 22,
                                    color: AppColors.stroke,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Phone number is required'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Gender',
                          style: textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          decoration: baseDecoration(
                            hintText: 'Select',
                            hintColor: AppColors.stroke,
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.secondaryText),
                          dropdownColor: AppColors.primary,
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male', style: TextStyle(color: AppColors.secondaryText)),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female', style: TextStyle(color: AppColors.secondaryText)),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other', style: TextStyle(color: AppColors.secondaryText)),
                            ),
                          ],
                          onChanged: (value) => setState(() => _gender = value),
                          validator: (value) => value == null ? 'Gender is required' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.go(AppPaths.home);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Complete Profile'),
                          ),
                        ),
                        const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

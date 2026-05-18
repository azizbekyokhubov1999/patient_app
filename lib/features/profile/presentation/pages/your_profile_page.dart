import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../manager/profile_cubit.dart';
import '../manager/profile_state.dart';
import '../../data/models/user_model.dart';
import '../widgets/profile_form_field.dart';

class YourProfilePage extends StatefulWidget {
  const YourProfilePage({super.key});

  @override
  State<YourProfilePage> createState() => _YourProfilePageState();
}

class _YourProfilePageState extends State<YourProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String _countryCode = '+1';
  String _gender = 'Female';
  bool _fieldsInitialized = false;

  static const List<String> _countryCodes = ['+1', '+44', '+91', '+998'];
  static const List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _populateFields(UserModel user) {
    _nameController.text = user.displayName;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _dobController.text = user.dateOfBirth;
    _countryCode = user.countryCode;
    _gender = user.gender;
  }

  Future<void> _pickDateOfBirth() async {
    final initial = _parseDob(_dobController.text) ?? DateTime(2002, 2, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  DateTime? _parseDob(String value) {
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  void _showAvatarPickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<ProfileCubit>().updateProfilePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<ProfileCubit>().updateProfilePicture();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  void _onUpdatePressed() {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<ProfileCubit>().state.user;
    if (user == null) return;

    final updated = user.copyWith(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      countryCode: _countryCode,
      dateOfBirth: _dobController.text.trim(),
      gender: _gender,
    );

    context.read<ProfileCubit>().updateUserProfile(updatedUser: updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          (current.user != null && !_fieldsInitialized),
      listener: (context, state) {
        if (state.user != null && !_fieldsInitialized) {
          setState(() {
            _populateFields(state.user!);
            _fieldsInitialized = true;
          });
        }

        if (state.isUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile successfully updated!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<ProfileCubit>().resetUpdateStatus();
          context.pop();
        }

        if (state.isUpdateFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<ProfileCubit>().resetUpdateStatus();
        }
      },
      builder: (context, state) {
        final user = state.user;
        final isUpdating = state.isUpdating;
        final photoUrl = user?.photoUrl ?? '';

        if (state.isLoading && user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomAppBar(
            title: 'Your Profile',
            backgroundColor: AppColors.white,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.viewInsetsOf(context).bottom + 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: _ProfileAvatar(
                            photoUrl: photoUrl,
                            isUpdating: state.isUpdatingAvatar,
                            onEdit: _showAvatarPickerSheet,
                          ),
                        ),
                        const SizedBox(height: 28),
                        ProfileFormField(
                          label: 'Name',
                          child: TextFormField(
                            controller: _nameController,
                            decoration: profileInputDecoration(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        ProfileFormField(
                          label: 'Email',
                          child: TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: profileInputDecoration(
                              suffixIcon: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Email change flow coming soon',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ProfileFormField(
                          label: 'Phone Number',
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _countryCodes.contains(_countryCode)
                                          ? _countryCode
                                          : '+1',
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      items: _countryCodes
                                          .map(
                                            (code) => DropdownMenuItem(
                                              value: code,
                                              child: Text(code),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _countryCode = value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 28,
                                  color: AppColors.stroke,
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ProfileFormField(
                          label: 'Date of Birth',
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: _pickDateOfBirth,
                            decoration: profileInputDecoration(
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.secondaryText,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ProfileFormField(
                          label: 'Gender',
                          child: DropdownButtonFormField<String>(
                            initialValue:
                                _genders.contains(_gender) ? _gender : 'Female',
                            decoration: profileInputDecoration(),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                            ),
                            items: _genders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _gender = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isUpdating ? null : _onUpdatePressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.isUpdating,
    required this.onEdit,
  });

  final String photoUrl;
  final bool isUpdating;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.neutral200,
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Icon(
                    Icons.person_rounded,
                    size: 56,
                    color: AppColors.secondaryText.withValues(alpha: 0.45),
                  )
                : null,
          ),
          if (isUpdating)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isUpdating ? null : onEdit,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/card_model.dart';
import '../widgets/card_preview.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Jennifer Aaker');
  final _numberController = TextEditingController(text: '4716 9627 1635 8047');
  final _expiryController = TextEditingController(text: '02/30');
  final _cvvController = TextEditingController(text: '000');
  bool _saveCard = true;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = CardModel(
      id: '',
      cardHolderName: _nameController.text,
      cardNumber: _numberController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.stroke),
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.primaryText,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Text('Add Card', style: AppTextStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardPreview(card: preview),
              const SizedBox(height: AppSpacing.xl),
              const _Label('Card Holder Name'),
              TextFormField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter card holder name' : null,
                decoration: _decoration(),
              ),
              const SizedBox(height: AppSpacing.md),
              const _Label('Card Number'),
              TextFormField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: _validateCardNumber,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: _decoration(),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('Expiry Date'),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: _validateExpiry,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _ExpiryDateFormatter(),
                          ],
                          decoration: _decoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('CVV'),
                        TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Enter CVV';
                            if (v.length < 3 || v.length > 4) return 'Invalid CVV';
                            return null;
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: _decoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () => setState(() => _saveCard = !_saveCard),
                child: Row(
                  children: [
                    Checkbox(
                      value: _saveCard,
                      onChanged: (v) => setState(() => _saveCard = v ?? false),
                      activeColor: AppColors.primary,
                    ),
                    const Text(
                      'Save Card',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final card = CardModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                cardHolderName: _nameController.text.trim(),
                cardNumber: _numberController.text.trim(),
                expiryDate: _expiryController.text.trim(),
                cvv: _cvvController.text.trim(),
              );
              context.pop<CardModel>(card);
            },
            child: const Text('Add Card', style: AppTextStyles.buttonLabel),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.neutral100,
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
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.length < 13) return 'Invalid card number';
    if (!_isValidLuhn(digits)) return 'Card number is not valid';
    return null;
  }

  String? _validateExpiry(String? value) {
    final v = value ?? '';
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v)) return 'Invalid expiry';

    final month = int.tryParse(v.substring(0, 2));
    final year = int.tryParse(v.substring(3, 5));
    if (month == null || year == null || month < 1 || month > 12) return 'Invalid expiry';

    final now = DateTime.now();
    final fullYear = 2000 + year;
    final lastDate = DateTime(fullYear, month + 1, 0);
    if (lastDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Card expired';
    }
    return null;
  }

  bool _isValidLuhn(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

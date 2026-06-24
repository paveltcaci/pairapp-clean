import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/services/auth_service.dart';
import '../../shared/services/functions_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _gender = 'prefer_not_to_say';
  String _language = 'ru';
  DateTime? _birthDate;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  static const _genderOptions = <String, String>{
    'male': 'Мужской',
    'female': 'Женский',
    'other': 'Другой',
    'prefer_not_to_say': 'Предпочитаю не указывать',
  };

  static const _languageOptions = <String, String>{
    'ru': 'Русский',
    'en': 'English',
  };

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.purple,
              onPrimary: Colors.white,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.bgSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_birthDate == null) {
      setState(() => _errorMessage = 'Выбери дату рождения.');
      return;
    }
    if (!_acceptTerms || !_acceptPrivacy) {
      setState(
        () => _errorMessage =
            'Необходимо принять Условия использования и Политику конфиденциальности.',
      );
      return;
    }
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create Firebase Auth user
      await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 2. Complete profile via callable (with built-in retry)
      await _userService.completeUserProfile(
        displayName: _displayNameController.text.trim(),
        gender: _gender,
        birthDate: DateFormat('yyyy-MM-dd').format(_birthDate!),
        language: _language,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
    } on FunctionsCallException catch (e) {
      _setError('Ошибка заполнения профиля: ${e.message}');
    } catch (_) {
      _setError('Что-то пошло не так. Попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setError(String msg) {
    if (mounted) setState(() => _errorMessage = msg);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован.';
      case 'invalid-email':
        return 'Некорректный email.';
      case 'weak-password':
        return 'Пароль слишком простой. Минимум 6 символов.';
      case 'network-request-failed':
        return 'Проблема с интернетом.';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуй позже.';
      default:
        return 'Ошибка регистрации: ${e.message ?? e.code}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildCard(context),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 14),
                            _buildErrorBanner(),
                          ],
                          const SizedBox(height: 20),
                          _isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.purple,
                                ),
                              )
                              : GradientButton(
                                  label: 'Зарегистрироваться',
                                  icon: Icons.person_add_rounded,
                                  onTap: _submit,
                                  width: double.infinity,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            'Регистрация',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          const SizedBox(width: 48), // balance the back button
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Создать аккаунт',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Заполни данные, чтобы начать.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.bgCardLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(context, 'Основное'),
          const SizedBox(height: 14),
          _field(
            controller: _displayNameController,
            label: 'Имя',
            hint: 'Как тебя зовут?',
            icon: Icons.person_outline,
            action: TextInputAction.next,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Введи имя.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _field(
            controller: _emailController,
            label: 'Email',
            hint: 'you@example.com',
            icon: Icons.mail_outline,
            type: TextInputType.emailAddress,
            action: TextInputAction.next,
            validator: (v) {
              final email = (v ?? '').trim();
              if (email.isEmpty) return 'Введи email.';
              if (!email.contains('@')) return 'Email выглядит некорректно.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _field(
            controller: _passwordController,
            label: 'Пароль',
            icon: Icons.lock_outline,
            obscure: _obscurePassword,
            action: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if ((v ?? '').length < 6) return 'Минимум 6 символов.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          _field(
            controller: _confirmPasswordController,
            label: 'Повтори пароль',
            icon: Icons.lock_outline,
            obscure: _obscureConfirm,
            action: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v != _passwordController.text) return 'Пароли не совпадают.';
              return null;
            },
          ),
          const SizedBox(height: 22),
          _sectionLabel(context, 'О себе'),
          const SizedBox(height: 14),
          _dropdown(
            context,
            label: 'Пол',
            icon: Icons.wc_outlined,
            value: _gender,
            items: _genderOptions,
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 14),
          _birthDateTile(context),
          const SizedBox(height: 14),
          _dropdown(
            context,
            label: 'Язык',
            icon: Icons.language_outlined,
            value: _language,
            items: _languageOptions,
            onChanged: (v) => setState(() => _language = v!),
          ),
          const SizedBox(height: 22),
          _sectionLabel(context, 'Соглашения'),
          const SizedBox(height: 10),
          _checkbox(
            value: _acceptTerms,
            label: 'Я принимаю Условия использования',
            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
          ),
          const SizedBox(height: 6),
          _checkbox(
            value: _acceptPrivacy,
            label: 'Я принимаю Политику конфиденциальности',
            onChanged: (v) => setState(() => _acceptPrivacy = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String value,
    required Map<String, String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgCardLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.bgSurface,
          icon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.textMuted,
          ),
          hint: Row(
            children: [
              Icon(icon, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
          selectedItemBuilder: (_) => items.entries.map((e) {
            return Row(
              children: [
                Icon(icon, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(
                  e.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }).toList(),
          items: items.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(
                e.value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _birthDateTile(BuildContext context) {
    final formatted = _birthDate == null
        ? null
        : DateFormat('d MMMM yyyy', 'ru').format(_birthDate!);

    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bgCardLight),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatted ?? 'Дата рождения',
                style: TextStyle(
                  color: formatted != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkbox({
    required bool value,
    required String label,
    required void Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.purple,
              side: const BorderSide(color: AppColors.textMuted, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

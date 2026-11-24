import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_strings.dart';
import '../services/api_service.dart';
import '../widgets/glowup_logo.dart';

class AuthScreen extends StatefulWidget {
  final bool isPortuguese;
  final VoidCallback onToggleLanguage;
  final void Function(Map<String, dynamic> userData) onAuthenticated;

  const AuthScreen({
    super.key,
    required this.isPortuguese,
    required this.onToggleLanguage,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluatePasswordStrength);
  }

  void _evaluatePasswordStrength() {
    final pwd = _passwordController.text;
    setState(() {
      _hasMinLength = pwd.length >= 8;
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(pwd);
      _hasLowercase = RegExp(r'[a-z]').hasMatch(pwd);
      _hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
      _hasSpecialChar = RegExp(r'[!@#\$%\^&\*\(\),.?":\{\}\|<>_\-\+=\[\]\;/~`]').hasMatch(pwd);
    });
  }

  bool get _isPasswordStrong =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (!_isLoginMode && !_isPasswordStrong) {
      setState(() => _errorMessage = AppStrings.t(widget.isPortuguese, 'pwd_weak_err'));
      return;
    }

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = _isLoginMode
        ? await ApiService.loginUser(email: email, password: password)
        : await ApiService.registerUser(name: _nameController.text.trim(), email: email, password: password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true && result['user'] != null) {
      widget.onAuthenticated(result['user']);
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pt = widget.isPortuguese;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: widget.onToggleLanguage,
                      icon: const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
                      label: Text(pt ? 'PT / EN' : 'EN / PT', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(child: GlowUpLogo(size: 72)),
                  const SizedBox(height: 16),
                  Text(AppStrings.t(pt, _isLoginMode ? 'welcome_title' : 'register_title'),
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(AppStrings.t(pt, _isLoginMode ? 'welcome_sub' : 'register_sub'),
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!_isLoginMode) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: AppStrings.t(pt, 'full_name'),
                                hintText: AppStrings.t(pt, 'full_name_hint'),
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                              ),
                              validator: (val) => (val == null || val.trim().length < 2) ? AppStrings.t(pt, 'name_error') : null,
                            ),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: AppStrings.t(pt, 'email'),
                              hintText: AppStrings.t(pt, 'email_hint'),
                              prefixIcon: const Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (val) => (val == null || !val.contains('@')) ? AppStrings.t(pt, 'email_error') : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.t(pt, 'password'),
                              hintText: AppStrings.t(pt, 'password_hint'),
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? AppStrings.t(pt, 'password_empty') : null,
                          ),
                          if (!_isLoginMode) ...[
                            const SizedBox(height: 12),
                            _reqRow(AppStrings.t(pt, 'pwd_min'), _hasMinLength),
                            _reqRow(AppStrings.t(pt, 'pwd_upper'), _hasUppercase),
                            _reqRow(AppStrings.t(pt, 'pwd_lower'), _hasLowercase),
                            _reqRow(AppStrings.t(pt, 'pwd_num'), _hasNumber),
                            _reqRow(AppStrings.t(pt, 'pwd_spec'), _hasSpecialChar),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _submit,
                              child: Text(AppStrings.t(pt, _isLoginMode ? 'sign_in' : 'create_account')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() {
                      _isLoginMode = !_isLoginMode;
                      _errorMessage = null;
                      _nameController.clear();
                      _emailController.clear();
                      _passwordController.clear();
                    }),
                    child: Text(AppStrings.t(pt, _isLoginMode ? 'no_account' : 'has_account'),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reqRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 15, color: met ? AppColors.success : AppColors.textSecondary),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 12.5, color: met ? AppColors.success : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

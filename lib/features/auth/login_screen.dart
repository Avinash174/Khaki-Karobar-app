import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_selector_dialog.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: '9876543211');
  final _passwordController = TextEditingController(text: 'OwnerPassword@123');
  final _otpController = TextEditingController(text: '123456');
  bool _isOtpMode = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Select Theme',
            icon: Icon(
              context.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: context.isDarkMode ? Colors.indigo.shade200 : Colors.amber.shade700,
            ),
            onPressed: () => showThemeSelectorDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header with official logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.isDarkMode ? Colors.white24 : Colors.grey.shade200,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Run Your Business Smarter • All-in-One ERP & Billing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // Error Message
                if (authState.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: context.isDarkMode ? 0.4 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade600.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),

                // Mode Tabs
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Password')),
                        selected: !_isOtpMode,
                        onSelected: (val) => setState(() => _isOtpMode = false),
                        selectedColor: AppTheme.primaryRed,
                        backgroundColor: context.surfaceColor,
                        labelStyle: TextStyle(
                          color: !_isOtpMode ? Colors.white : context.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Instant OTP')),
                        selected: _isOtpMode,
                        onSelected: (val) => setState(() => _isOtpMode = true),
                        selectedColor: AppTheme.primaryRed,
                        backgroundColor: context.surfaceColor,
                        labelStyle: TextStyle(
                          color: _isOtpMode ? Colors.white : context.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Input Fields
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: context.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone_android, color: context.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                if (!_isOtpMode)
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: context.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: context.textSecondary),
                    ),
                  )
                else
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.textPrimary),
                    decoration: InputDecoration(
                      labelText: '6-Digit OTP (Pre-filled: 123456)',
                      prefixIcon: Icon(Icons.security, color: context.textSecondary),
                    ),
                  ),

                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          bool success = false;
                          if (!_isOtpMode) {
                            success = await ref.read(authProvider.notifier).login(
                                  _phoneController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                          } else {
                            success = await ref.read(authProvider.notifier).verifyOtp(
                                  _phoneController.text.trim(),
                                  _otpController.text.trim(),
                                );
                          }
                          if (success && context.mounted) {
                            context.go('/dashboard');
                          }
                        },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isOtpMode ? 'Verify & Enter' : 'Sign In'),
                ),

                const SizedBox(height: 20),
                Text(
                  'Connected to Live PostgreSQL Backend API',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

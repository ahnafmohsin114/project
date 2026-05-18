import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _isLoading     = false;
  bool _obscurePass   = true;

  late AnimationController _animCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on AuthException catch (e) {
      if (!mounted) return;
      String msg = e.message;
      if (msg.contains('Email not confirmed')) {
        msg = 'Please verify your email first.';
      } else if (msg.contains('Invalid login credentials')) {
        msg = 'Wrong email or password.';
      }
      _snack(msg, isError: true);
    } catch (_) {
      if (!mounted) return;
      _snack('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          // Top gradient blob
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom decoration
          Positioned(
            bottom: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary.withOpacity(0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8))
                            ],
                          ),
                          child: const Icon(Icons.sticky_note_2_rounded,
                              size: 42, color: AppColors.primary),
                        ),
                        const SizedBox(height: 20),
                        Text('SheetNote',
                            style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Welcome back! Sign in to continue.',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 48),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8))
                            ],
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Email Address'),
                              const SizedBox(height: 8),
                              _textField(
                                controller: _emailCtrl,
                                hint: 'you@example.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email is required';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(v))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _label('Password'),
                              const SizedBox(height: 8),
                              _textField(
                                controller: _passwordCtrl,
                                hint: 'Your password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePass,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _obscurePass
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textMuted,
                                      size: 20),
                                  onPressed: () => setState(
                                      () => _obscurePass = !_obscurePass),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Password is required'
                                    : null,
                              ),
                              const SizedBox(height: 28),
                              _primaryBtn(
                                label: 'Sign In',
                                icon: Icons.login_rounded,
                                onTap: _isLoading ? null : _login,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                  color: AppColors.borderLight,
                                  thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Text('OR',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                            ),
                            Expanded(
                              child: Divider(
                                  color: AppColors.borderLight,
                                  thickness: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (_) => const RegisterScreen())),
                            child: Text('Create New Account',
                                style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(
          color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.8)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.8)),
        errorStyle:
            GoogleFonts.poppins(color: AppColors.error, fontSize: 11),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

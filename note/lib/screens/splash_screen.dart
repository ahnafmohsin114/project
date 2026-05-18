import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset>  _textSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _textCtrl = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);

    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(_textCtrl);
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _textCtrl, curve: Curves.easeOutCubic));

    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Future.delayed(const Duration(seconds: 3), _checkAuth);
  }

  void _checkAuth() {
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            session != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: Stack(
        children: [
          // Soft background blobs
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 32,
                              spreadRadius: 4,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: const Icon(Icons.sticky_note_2_rounded,
                          size: 54, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text('SheetNote',
                            style: GoogleFonts.poppins(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Text('Your thoughts, beautifully organized',
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (i) => _LoadingDot(delay: i * 200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDot extends StatefulWidget {
  final int delay;
  const _LoadingDot({required this.delay});

  @override
  State<_LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<_LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FadeTransition(
        opacity: _anim,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

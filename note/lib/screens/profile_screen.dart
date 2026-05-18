import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int totalNotes;

  const ProfileScreen({super.key, required this.totalNotes});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final ok = await _confirmLogout();
    if (ok != true) return;
    await _supabase.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<bool?> _confirmLogout() => showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text('Sign Out?',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('You will need to sign in again to access your notes.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderMid),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('Cancel',
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('Sign Out',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  String _memberSince(String? createdAt) {
    if (createdAt == null) return 'Unknown';
    final date = DateTime.parse(createdAt).toLocal();
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[date.month - 1]} ${date.year}';
  }

  int _daysSinceJoined(String? createdAt) {
    if (createdAt == null) return 0;
    return DateTime.now().difference(DateTime.parse(createdAt)).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final user     = _supabase.auth.currentUser;
    final email    = user?.email ?? 'Unknown';
    final letter   = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final since    = _memberSince(user?.createdAt);
    final days     = _daysSinceJoined(user?.createdAt);
    final username = email.contains('@') ? email.split('@')[0] : email;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.primary,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text('My Profile',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -40,
                          right: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Avatar + name
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6))
                                    ],
                                  ),
                                  child: Center(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.secondary
                                        ],
                                      ).createShader(bounds),
                                      child: Text(letter,
                                          style: GoogleFonts.poppins(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text('@$username',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(email,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stats row ───────────────────────────────
                      Row(
                        children: [
                          _statCard(
                            icon: Icons.sticky_note_2_rounded,
                            label: 'Total Notes',
                            value: '${widget.totalNotes}',
                            color: AppColors.primary,
                            bg: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            icon: Icons.calendar_month_rounded,
                            label: 'Days Active',
                            value: '$days',
                            color: AppColors.secondary,
                            bg: AppColors.secondaryLight,
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            icon: Icons.emoji_events_rounded,
                            label: 'Member Since',
                            value: since,
                            color: AppColors.success,
                            bg: AppColors.successLight,
                            small: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Account section ─────────────────────────
                      _sectionTitle('Account'),
                      const SizedBox(height: 12),
                      _infoCard(
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        subtitle: email,
                        color: AppColors.primary,
                        bg: AppColors.primaryLight,
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Account Status',
                        subtitle: 'Verified & Active',
                        color: AppColors.success,
                        bg: AppColors.successLight,
                      ),
                      const SizedBox(height: 10),
                      _infoCard(
                        icon: Icons.access_time_rounded,
                        title: 'Member Since',
                        subtitle: since,
                        color: AppColors.warning,
                        bg: AppColors.warningLight,
                      ),
                      const SizedBox(height: 28),

                      // ── Danger zone ─────────────────────────────
                      _sectionTitle('Account Actions'),
                      const SizedBox(height: 12),
                      _actionCard(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        subtitle: 'Log out of your account',
                        color: AppColors.error,
                        bg: AppColors.errorLight,
                        onTap: _logout,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Text('ShitNote v3.0.0',
                            style: GoogleFonts.poppins(
                                color: AppColors.textMuted, fontSize: 12)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text('Made with ❤️',
                            style: GoogleFonts.poppins(
                                color: AppColors.textMuted, fontSize: 11)),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700),
      );
  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bg,
    bool small = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: small ? 12 : 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          color: color.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }
}

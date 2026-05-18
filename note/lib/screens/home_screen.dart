import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../models/note_model.dart';
import 'note_editor_screen.dart';
import 'profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _supabase     = Supabase.instance.client;
  List<Note> _notes   = [];
  bool _isLoading     = true;
  String _searchQuery = '';
  int _selectedTab    = 0; 
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadNotes();
  }
  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
  Color _accentFor(String hex) {
    final idx = AppColors.noteHexColors.indexOf(hex);
    return idx >= 0 ? AppColors.noteAccents[idx] : AppColors.primary;
  }
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1)   return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)    return '${diff.inHours}h ago';
    if (diff.inDays < 7)    return '${diff.inDays}d ago';
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${m[date.month - 1]}';
  }
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
  List<Note> get _filteredNotes {
    List<Note> base = _selectedTab == 1
        ? _notes.where((n) =>
            DateTime.now().difference(n.updatedAt).inDays < 1).toList()
        : _notes;
    if (_searchQuery.isEmpty) return base;
    final q = _searchQuery.toLowerCase();
    return base
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList();
  }
  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final uid = _supabase.auth.currentUser!.id;
      final res = await _supabase
          .from('notes')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      setState(() {
        _notes = (res as List).map((e) => Note.fromMap(e)).toList();
        _isLoading = false;
      });
      _animCtrl.forward(from: 0);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _createNote(
      String title, String content, String color) async {
    final uid = _supabase.auth.currentUser!.id;
    final res = await _supabase.from('notes').insert({
      'user_id': uid,
      'title': title,
      'content': content,
      'color': color,
    }).select().single();
    setState(() => _notes.insert(0, Note.fromMap(res)));
    _snack('Note saved ✨');
  }
  Future<void> _updateNote(
      String id, String title, String content, String color) async {
    final res = await _supabase.from('notes').update({
      'title': title,
      'content': content,
      'color': color,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id).select().single();
    setState(() {
      final i = _notes.indexWhere((n) => n.id == id);
      if (i != -1) _notes[i] = Note.fromMap(res);
    });
    _snack('Note updated ✅');
  }
  Future<void> _deleteNote(String id) async {
    await _supabase.from('notes').delete().eq('id', id);
    setState(() => _notes.removeWhere((n) => n.id == id));
    _snack('Note deleted');
  }
  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }
  void _openEditor({Note? note}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: NoteEditorScreen(
            note: note,
            onCreate: _createNote,
            onUpdate: _updateNote,
            onDelete: _deleteNote,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(totalNotes: _notes.length),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final user     = _supabase.auth.currentUser;
    final email    = user?.email ?? '';
    final letter   = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final username = email.contains('@') ? email.split('@')[0] : email;
    final filtered = _filteredNotes;
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: _loadNotes,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 160,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        right: 60,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(_greeting(),
                                            style: GoogleFonts.poppins(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w500)),
                                        Text(username,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight.w800)),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openProfile,
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.15),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3))
                                        ],
                                      ),
                                      child: Center(
                                        child: ShaderMask(
                                          shaderCallback: (b) =>
                                              const LinearGradient(colors: [
                                            AppColors.primary,
                                            AppColors.secondary
                                          ]).createShader(b),
                                          child: Text(letter,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _headerStat(
                                      '${_notes.length}',
                                      'Notes',
                                      Icons.sticky_note_2_rounded),
                                  const SizedBox(width: 16),
                                  _headerStat(
                                      '${_notes.where((n) => DateTime.now().difference(n.updatedAt).inDays < 1).length}',
                                      'Today',
                                      Icons.today_rounded),
                                ],
                              ),
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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: TextField(
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        style: GoogleFonts.poppins(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search your notes...',
                          hintStyle: GoogleFonts.poppins(
                              color: AppColors.textMuted, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.primary, size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      color: AppColors.textMuted, size: 18),
                                  onPressed: () => setState(
                                      () => _searchQuery = ''),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _tab(0, 'All Notes'),
                        const SizedBox(width: 10),
                        _tab(1, 'Recent'),
                        const Spacer(),
                        if (_searchQuery.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${filtered.length} found',
                                style: GoogleFonts.poppins(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: _emptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final note = filtered[i];
                      return FadeTransition(
                        opacity: _fadeAnim,
                        child: _noteCard(note),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: AppColors.primary,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: Text('New Note',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
  Widget _noteCard(Note note) {
    final bg     = _hexToColor(note.color);
    final accent = _accentFor(note.color);
    return GestureDetector(
      onTap: () => _openEditor(note: note),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.description_rounded,
                        color: accent, size: 16),
                  ),
                  const Spacer(),
                  Text(_timeAgo(note.updatedAt),
                      style: GoogleFonts.poppins(
                          color: accent.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3)),
              const SizedBox(height: 6),
              Expanded(
                child: Text(note.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.55)),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: accent.withOpacity(0.12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 10,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: accent.withOpacity(0.6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sticky_note_2_outlined,
                size: 54, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'No notes yet!' : 'Nothing found',
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Tap "New Note" to write\nyour first note 🌸'
                : 'Try a different search term',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14, height: 1.6),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text('Create First Note',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tab(int index, String label) {
    final sel = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? AppColors.primary : AppColors.borderLight),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: sel ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _headerStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }
}

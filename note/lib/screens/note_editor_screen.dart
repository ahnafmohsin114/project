import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../models/note_model.dart';
class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final Future<void> Function(String title, String content, String color) onCreate;
  final Future<void> Function(String id, String title, String content, String color) onUpdate;
  final Future<void> Function(String id) onDelete;
  const NoteEditorScreen({
    super.key,
    this.note,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });
  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}
class _NoteEditorScreenState extends State<NoteEditorScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late String _selectedColor;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  bool _isSaving   = false;
  bool _isDeleting = false;
  bool _hasChanges = false;

  
  Color get _accentColor {
    final idx = AppColors.noteHexColors.indexOf(_selectedColor);
    return idx >= 0 ? AppColors.noteAccents[idx] : AppColors.primary;
  }

  Color get _bgColor {
    final hex = _selectedColor.replaceAll('#', '');
    final full = hex.length == 6 ? 'FF$hex' : hex;
    return Color(int.parse(full, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    _titleCtrl   = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _selectedColor = widget.note?.color ?? AppColors.noteHexColors[0];

    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  void _onChanged() => setState(() => _hasChanges = true);

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty) {
      _snack('Please add a title', isError: true);
      return;
    }
    if (content.isEmpty) {
      _snack('Please write something', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      if (widget.note == null) {
        await widget.onCreate(title, content, _selectedColor);
      } else {
        await widget.onUpdate(widget.note!.id, title, content, _selectedColor);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await _confirmDelete();
    if (ok != true) return;
    setState(() => _isDeleting = true);
    try {
      await widget.onDelete(widget.note!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _isDeleting = false);
    }
  }

  Future<bool?> _confirmDelete() => showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 32),
                ),
                const SizedBox(height: 16),
                Text('Delete Note?',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('This note will be permanently deleted.',
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
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('Delete',
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
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final accent    = _accentColor;
    final bg        = _bgColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: accent),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: GoogleFonts.poppins(
              color: accent, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: _isDeleting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.error))
                  : Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                    ),
              onPressed: _isDeleting ? null : _delete,
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _isSaving ? null : _save,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text('Save',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            Container(
              color: bg,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Text('Color:',
                      style: GoogleFonts.poppins(
                          color: accent.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppColors.noteHexColors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final hex = AppColors.noteHexColors[i];
                          final c   = AppColors.noteAccents[i];
                          final sel = _selectedColor == hex;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedColor = hex;
                              _hasChanges = true;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: sel ? AppColors.textPrimary : Colors.transparent,
                                    width: 2.5),
                                boxShadow: sel
                                    ? [BoxShadow(
                                        color: c.withOpacity(0.5),
                                        blurRadius: 8)]
                                    : [],
                              ),
                              child: sel
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, -4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _NotebookLinePainter(
                              lineColor: accent.withOpacity(0.07)),
                        ),
                      ),
                      Positioned(
                        left: 68,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1.5,
                          color: AppColors.secondary.withOpacity(0.18),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(80, 28, 24, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            TextField(
                              controller: _titleCtrl,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4),
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Title your note...',
                                hintStyle: GoogleFonts.poppins(
                                    color: AppColors.textMuted,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800),
                                border: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Date stamp
                            Text(
                              _formatDate(widget.note?.updatedAt ?? DateTime.now()),
                              style: GoogleFonts.poppins(
                                  color: accent.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            // Content
                            TextField(
                              controller: _contentCtrl,
                              style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  height: 1.9),
                              maxLines: null,
                              minLines: 12,
                              decoration: InputDecoration(
                                hintText: 'Start writing your thoughts...',
                                hintStyle: GoogleFonts.poppins(
                                    color: AppColors.textMuted,
                                    fontSize: 15,
                                    height: 1.9),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 28,
                        child: SizedBox(
                          width: 64,
                          child: Column(
                            children: List.generate(30, (i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.5),
                              child: Text(
                                '${i + 1}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: accent.withOpacity(0.18),
                                    fontSize: 10,
                                    fontFamily: 'monospace'),
                              ),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final wd = weekdays[date.weekday - 1];
    return '$wd, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
class _NotebookLinePainter extends CustomPainter {
  final Color lineColor;
  _NotebookLinePainter({required this.lineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    const lineSpacing = 36.0;
    double y = lineSpacing + 20;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += lineSpacing;
    }
  }
  @override
  bool shouldRepaint(_NotebookLinePainter old) => old.lineColor != lineColor;
}

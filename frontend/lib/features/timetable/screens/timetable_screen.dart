import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart' as picker;

import '../../../core/theme_data/app_colors.dart';
import '../../../core/theme_data/app_radius.dart';
import '../../../core/widgets/blue_btn.dart';
import '../../../core/widgets/app_back_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_role.dart';
import '../models/timetable_slot.dart';
import '../providers/timetable_provider.dart';
import '../../department/providers/department_provider.dart';
import '../../department/models/department_class.dart';
import '../../department/models/department_teacher.dart';
import '../../department/models/department_subject.dart';

// ---------------------------------------------------------------------------
// Sizing constants derived from Figma node 1378-5595
// ---------------------------------------------------------------------------
const double _kPeriodColWidth = 32.0;
const double _kDayColWidth = 111.8;
const double _kHeaderHeight = 37.0;
const double _kRowHeight = 49.7;
const double _kTableWidth = _kPeriodColWidth + _kDayColWidth * 5; // ~591 px

class TimetableScreen extends ConsumerStatefulWidget {
  /// When true, skip HOD admin/edit controls and show the teacher timetable.
  final bool forceTeacherMode;

  /// Specific class ID if viewed from inside a class (no dropdown).
  final String? classId;

  const TimetableScreen({
    super.key,
    this.forceTeacherMode = false,
    this.classId,
  });

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  // Navigation segments for HOD: "Classes" vs "Teachers"
  String _selectedSegment = "Classes";

  // Class selection filter ("Sort by")
  String? _selectedSortClass;

  // Teacher selection (for Teachers mode)
  String _selectedTeacher = "Anju miss";

  // State machine for Swap -> Request workflow
  bool _isSwapMode = false;
  bool _isHodEditing = false;

  late ScrollController _tableScrollController;
  double _scrollProgress = 0.0;

  final List<String> _classesList = ["S2 BCA", "S4 BCA", "S6 BCA", "S8 BCA"];
  final List<String> _teachersList = [
    "Anju miss",
    "Anu Varghese",
    "Rijina NM",
    "Sheetal",
    "Anju krishna",
    "Lakshmi",
  ];

  @override
  void initState() {
    super.initState();
    _tableScrollController = ScrollController();
    _tableScrollController.addListener(_onTableScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onTableScroll();
      final auth = ref.read(authProvider);
      final user = auth.user;

      if (widget.classId != null) {
        setState(() {
          _selectedSortClass = widget.classId!;
          _selectedSegment = "Classes";
        });
      } else if (user != null) {
        if (user.role == UserRole.student && user.className != null) {
          setState(() {
            _selectedSortClass = user.className!;
            _selectedSegment = "Classes";
          });
        } else if (user.role == UserRole.teacher) {
          if (user.isHOD && !widget.forceTeacherMode) {
            setState(() {
              _selectedSegment = "Classes";
              _selectedSortClass = user.assignedClassId ?? "S2 BCA";
            });
          } else {
            final cleanName = user.name.trim();
            final matchingTeacher = _teachersList.firstWhere(
              (t) => t.toLowerCase() == cleanName.toLowerCase(),
              orElse: () => _teachersList.first,
            );
            setState(() {
              _selectedTeacher = matchingTeacher;
              _selectedSegment = "Teachers";
            });
          }
        }
      }
    });
  }

  void _onTableScroll() {
    if (_tableScrollController.hasClients) {
      final maxScroll = _tableScrollController.position.maxScrollExtent;
      final current = _tableScrollController.position.pixels;
      if (maxScroll > 0) {
        setState(() {
          _scrollProgress = (current / maxScroll).clamp(0.0, 1.0);
        });
      }
    }
  }

  void _scrollToProgress(double newProgress) {
    if (_tableScrollController.hasClients) {
      final maxScroll = _tableScrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        _tableScrollController.jumpTo(newProgress * maxScroll);
      }
    }
  }

  @override
  void dispose() {
    _tableScrollController.removeListener(_onTableScroll);
    _tableScrollController.dispose();
    super.dispose();
  }

  bool _matchesTeacher(String slotTeacher, String targetTeacher) {
    final st = slotTeacher.toLowerCase().replaceAll('.', '').trim();
    final tt = targetTeacher.toLowerCase().replaceAll('.', '').trim();
    if (st == tt) return true;
    if (st.contains(tt) || tt.contains(st)) return true;
    final tTokens = tt.split(RegExp(r'\s+'));
    for (var t in tTokens) {
      if (t.length >= 3 && st.contains(t)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final isHOD =
        (user?.isHOD ?? false) &&
        !widget.forceTeacherMode &&
        widget.classId == null;
    final isStudent = auth.role == UserRole.student;
    final bool isClassSpecific = widget.classId != null;
    final bool isTeacherMode =
        widget.forceTeacherMode || (!isHOD && !isStudent && !isClassSpecific);
    final bool isOwnTeacher =
        isTeacherMode &&
        user != null &&
        _matchesTeacher(_selectedTeacher, user.name);

    final deptClasses = ref.watch(departmentClassesProvider).value ?? [];
    final currentClasses = deptClasses.isNotEmpty
        ? deptClasses.map((c) => c.name).toList()
        : _classesList;

    final deptTeachers = ref.watch(departmentTeachersProvider).value ?? [];
    final currentTeachers = deptTeachers.isNotEmpty
        ? deptTeachers.map((t) => t.name).toList()
        : _teachersList;
    final selectedTeacherRecord = deptTeachers.cast<dynamic?>().firstWhere(
      (teacher) =>
          teacher != null &&
          _matchesTeacher(teacher.name.toString(), _selectedTeacher),
      orElse: () => null,
    );
    final selectedTeacherId = selectedTeacherRecord?.id?.toString();

    if (isStudent && user?.className != null) {
      _selectedSortClass = user!.className!;
    } else if (isClassSpecific) {
      _selectedSortClass = widget.classId!;
    }

    // Watch backend timetable data
    final allTimetableAsync = ref.watch(allTimetableProvider);
    final rawSlots = allTimetableAsync.value ?? [];
    // MongoDB query is the source of truth; successful CRUD invalidates it.
    final allSlots = rawSlots;

    // Use actual start times to determine period rows. MongoDB ObjectIds
    // must never be interpreted as period numbers.
    final classView = isStudent || isClassSpecific ||
        (isHOD && _selectedSegment == "Classes");
    final targetClass = _selectedSortClass ?? "S2 BCA";
    final visibleSlots = allSlots.where((slot) {
      if (classView) {
        // Match batch by its MongoDB ID when possible, with the display
        // name as a fallback for older/unpopulated records.
        final selectedBatch = deptClasses.cast<dynamic?>().firstWhere(
          (batch) => batch != null && batch.name.toString() == targetClass,
          orElse: () => null,
        );
        final selectedBatchId = selectedBatch?.id?.toString();
        if (selectedBatchId != null &&
            selectedBatchId.isNotEmpty &&
            slot.batchId != null &&
            slot.batchId!.isNotEmpty) {
          return slot.batchId == selectedBatchId;
        }
        return slot.classId.trim().toLowerCase() ==
            targetClass.trim().toLowerCase();
      }

      // Teacher timetable is derived from the same all-batches collection.
      // Prefer MongoDB reference IDs; fall back to names for legacy records.
      if (selectedTeacherId != null &&
          selectedTeacherId.isNotEmpty &&
          slot.teacherId != null &&
          slot.teacherId!.isNotEmpty) {
        return slot.teacherId == selectedTeacherId;
      }
      return _matchesTeacher(slot.teacherName, _selectedTeacher);
    }).toList();

    int minutes(TimeOfDay t) => t.hour * 60 + t.minute;
    final periodStarts = visibleSlots.map((e) => minutes(e.startTime)).toSet().toList()
      ..sort();
    final List<List<TimetableSlot?>> gridSlots = List.generate(
      5, (_) => List<TimetableSlot?>.filled(5, null),
    );
    for (final slot in visibleSlots) {
      final dayIndex = slot.dayOfWeek - 1;
      final periodIndex = periodStarts.indexOf(minutes(slot.startTime));
      if (dayIndex >= 0 && dayIndex < 5 && periodIndex >= 0 && periodIndex < 5) {
        gridSlots[periodIndex][dayIndex] = slot;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackHeader(
                title: 'Time Table',
                subtitle: isClassSpecific
                    ? 'Timetable for ${widget.classId}'
                    : (isTeacherMode
                          ? 'Teacher Timetable ($_selectedTeacher)'
                          : 'View your timetable here'),
                onBack: () {
                  if (!context.mounted) return;
                  context.pop();
                },
                padding: const EdgeInsets.only(
                  left: 8,
                  top: 16,
                  right: 16,
                  bottom: 8,
                ),
              ),

              const SizedBox(height: 12),

              // ── HOD controls ────────────────────────────────────────────
              if (isHOD) ...[
                _HodControls(
                  selectedSegment: _selectedSegment,
                  selectedSortClass: _selectedSortClass,
                  selectedTeacher: _selectedTeacher,
                  classesList: currentClasses,
                  teachersList: currentTeachers,
                  isHodEditing: _isHodEditing,
                  onSegmentChanged: (seg) {
                    setState(() {
                      _selectedSegment = seg;
                      _isHodEditing = false;
                    });
                  },
                  onClassSelected: (val) {
                    setState(() => _selectedSortClass = val);
                  },
                  onTeacherSelected: (val) {
                    setState(() => _selectedTeacher = val);
                  },
                  onEditToggle: () {
                    setState(() => _isHodEditing = !_isHodEditing);
                  },
                  onUploadTap: _pickAndPreviewTimetable,
                ),
              ] else if (isTeacherMode) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _OutlinedDropdown(
                          label: _selectedTeacher,
                          items: currentTeachers,
                          onSelected: (val) {
                            setState(() {
                              _selectedTeacher = val;
                              _isSwapMode = false;
                            });
                          },
                        ),
                      ),
                      if (isOwnTeacher) ...[
                        const SizedBox(width: 12),
                        if (_isSwapMode) ...[
                          GestureDetector(
                            onTap: () {
                              setState(() => _isSwapMode = false);
                            },
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                border: Border.all(
                                  color: AppColors.outline,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.inter(
                                    color: AppColors.headingText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _SwapButton(
                          isSwapMode: _isSwapMode,
                          onTap: () {
                            if (_isSwapMode) {
                              _submitSwapRequest();
                            } else {
                              setState(() => _isSwapMode = true);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ── Timetable table card ─────────────────────────────────────
              _TimetableTableCard(
                gridSlots: gridSlots,
                scrollController: _tableScrollController,
                scrollProgress: _scrollProgress,
                onScrollChanged: _scrollToProgress,
                isSwapMode: _isSwapMode,
                isHOD: isHOD,
                isHodEditing: _isHodEditing,
                isTeacherSchedule: !classView,
                onCellTap: _handleCellTap,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cell interaction dispatcher ───────────────────────────────────────────

  void _handleCellTap(TimetableSlot? slot, int day, int period) {
    final auth = ref.read(authProvider);
    final isHOD = (auth.user?.isHOD ?? false) && !widget.forceTeacherMode;

    if (isHOD && _isHodEditing) {
      _showTimetableEditor(slot, day);
    } else if (slot != null) {
      _showSlotDetailsModal(slot);
    }
  }

  void _showSlotDetailsModal(TimetableSlot slot) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    slot.subjectName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    slot.classId,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text('Teacher: ${slot.teacherName}')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('Time: ${slot.startTime.format(sheetContext)} - ${slot.endTime.format(sheetContext)}'),
              ],
            ),
            if (slot.roomNo.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.room_outlined, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Room: ${slot.roomNo}'),
                ],
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimetableEditor(TimetableSlot? existing, int day) async {
    final classes = ref.read(departmentClassesProvider).value ?? [];
    final teachers = ref.read(departmentTeachersProvider).value ?? [];
    final subjects = ref.read(departmentSubjectsProvider).value ?? [];

    if (classes.isEmpty || teachers.isEmpty || subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load batches, teachers or subjects. Please refresh and try again.')),
      );
      return;
    }

    final matchingBatches = classes.where(
      (e) => e.name == (existing?.classId ?? _selectedSortClass),
    ).toList();
    final batch = matchingBatches.isNotEmpty ? matchingBatches.first : classes.first;
    final selectedBatchId = batch.id;
    final matchingTeachers = teachers.where((e) => e.id == existing?.teacherId).toList();
    final selectedTeacher = matchingTeachers.isNotEmpty ? matchingTeachers.first : teachers.first;
    final matchingSubjects = subjects.where((e) => e.id == existing?.subjectId).toList();
    final selectedSubject = matchingSubjects.isNotEmpty ? matchingSubjects.first : subjects.first;


    if (selectedBatchId == null || selectedTeacher.id == null || selectedSubject.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch, teacher or subject is missing a database ID.')),
      );
      return;
    }

    final roomController = TextEditingController(text: existing?.roomNo ?? '');
    String batchId = selectedBatchId;
    String teacherId = selectedTeacher.id!;
    String subjectId = selectedSubject.id!;
    int selectedDay = existing?.dayOfWeek ?? day;
    TimeOfDay start = existing?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay end = existing?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add timetable entry' : 'Edit timetable entry'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                value: batchId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Batch / Class'),
                items: classes.where((e) => e.id != null).map((e) =>
                  DropdownMenuItem(value: e.id!, child: Text(e.name))).toList(),
                onChanged: existing == null ? (v) => setDialogState(() => batchId = v!) : null,
              ),
              DropdownButtonFormField<String>(
                value: subjectId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: subjects.where((e) => e.id != null).map((e) =>
                  DropdownMenuItem(value: e.id!, child: Text(e.name))).toList(),
                onChanged: (v) => setDialogState(() => subjectId = v!),
              ),
              DropdownButtonFormField<String>(
                value: teacherId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Teacher'),
                items: teachers.where((e) => e.id != null).map((e) =>
                  DropdownMenuItem(value: e.id!, child: Text(e.name))).toList(),
                onChanged: (v) => setDialogState(() => teacherId = v!),
              ),
              DropdownButtonFormField<int>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Day'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                ],
                onChanged: (v) => setDialogState(() => selectedDay = v!),
              ),
              TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: start);
                    if (picked != null) setDialogState(() => start = picked);
                  },
                  child: Text('Start: ${start.format(context)}'),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: end);
                    if (picked != null) setDialogState(() => end = picked);
                  },
                  child: Text('End: ${end.format(context)}'),
                )),
              ]),
            ]),
          ),
          actions: [
            if (existing != null)
              TextButton(
                onPressed: saving ? null : () async {
                  setDialogState(() => saving = true);
                  try {
                    await ref.read(timetableNotifierProvider.notifier).deleteSlot(existing.id);
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Timetable entry deleted')),
                    );
                  } catch (e) {
                    setDialogState(() => saving = false);
                    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: saving ? null : () async {
                if (roomController.text.trim().isEmpty || end.hour * 60 + end.minute <= start.hour * 60 + start.minute) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Enter a room and a valid end time.')),
                  );
                  return;
                }
                final selectedBatch = classes.firstWhere((e) => e.id == batchId);
                final selectedSub = subjects.firstWhere((e) => e.id == subjectId);
                final selectedTeach = teachers.firstWhere((e) => e.id == teacherId);
                final slot = TimetableSlot(
                  id: existing?.id ?? '',
                  dayOfWeek: selectedDay,
                  startTime: start,
                  endTime: end,
                  roomNo: roomController.text.trim(),
                  subjectName: selectedSub.name,
                  teacherName: selectedTeach.name,
                  classId: selectedBatch.name,
                  batchId: batchId,
                  subjectId: subjectId,
                  teacherId: teacherId,
                );
                setDialogState(() => saving = true);
                try {
                  final notifier = ref.read(timetableNotifierProvider.notifier);
                  if (existing == null) {
                    await notifier.createSlot(slot);
                  } else {
                    await notifier.saveSlot(slot);
                  }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  if (mounted) ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(existing == null ? 'Timetable entry created' : 'Timetable entry updated')),
                  );
                } catch (e) {
                  setDialogState(() => saving = false);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Could not save timetable: $e')),
                  );
                }
              },
              child: Text(saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
    roomController.dispose();
  }

  void _submitSwapRequest() {
    setState(() => _isSwapMode = false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Swap request submitted to HOD and selected teacher."),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickAndPreviewTimetable() async {
    try {
      final files = await picker.FilePicker.pickFiles(
        type: picker.FileType.custom,
        allowedExtensions: ['pdf', 'csv'],
      );

      if (files.isEmpty || !mounted) return;

      _showTimetablePreviewModal(files.first);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error picking file: $e"),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showTimetablePreviewModal(picker.PlatformFile file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      builder: (context) {
        final extension = file.extension?.toLowerCase() ?? 'pdf';
        final isPdf = extension == 'pdf';
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Timetable Preview",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headingText,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      extension.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.outline, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPdf
                          ? Icons.picture_as_pdf_rounded
                          : Icons.table_chart_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.headingText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            file.lengthSync() == null
                                ? "Size unavailable"
                                : file.lengthSync()! >= 1024 * 1024
                                ? "${(file.lengthSync()! / (1024 * 1024)).toStringAsFixed(1)} MB"
                                : "${(file.lengthSync()! / 1024).toStringAsFixed(1)} KB",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Parsed Preview Summary",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.headingText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• Target Class: ${_selectedSortClass ?? 'S2 BCA'}",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Detected Days: Monday — Friday (5 days)",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Periods per day: 5 periods",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "• Status: Ready for import",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: BlueBtn(
                      text: "Cancel",
                      backgroundColor: const Color(0xFF6E6E6E),
                      borderColor: const Color(0xFF6E6E6E),
                      textColor: AppColors.surface,
                      borderRadius: AppRadius.pill,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlueBtn(
                      text: "Import Timetable",
                      backgroundColor: AppColors.primary,
                      borderColor: AppColors.primary,
                      textColor: AppColors.surface,
                      borderRadius: AppRadius.pill,
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Timetable imported successfully!"),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// HOD controls row
// ============================================================================

class _HodControls extends StatelessWidget {
  final String selectedSegment;
  final String? selectedSortClass;
  final String selectedTeacher;
  final List<String> classesList;
  final List<String> teachersList;
  final bool isHodEditing;
  final ValueChanged<String> onSegmentChanged;
  final ValueChanged<String> onClassSelected;
  final ValueChanged<String> onTeacherSelected;
  final VoidCallback onEditToggle;
  final VoidCallback onUploadTap;

  const _HodControls({
    required this.selectedSegment,
    required this.selectedSortClass,
    required this.selectedTeacher,
    required this.classesList,
    required this.teachersList,
    required this.isHodEditing,
    required this.onSegmentChanged,
    required this.onClassSelected,
    required this.onTeacherSelected,
    required this.onEditToggle,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Segment toggle: Classes / Teachers
              _PillSegment(
                labels: const ["Classes", "Teachers"],
                selected: selectedSegment == "Classes" ? 0 : 1,
                onChanged: (i) =>
                    onSegmentChanged(i == 0 ? "Classes" : "Teachers"),
              ),
              const SizedBox(width: 12),
              // Dropdown for class or teacher
              Expanded(
                child: _OutlinedDropdown(
                  label: selectedSegment == "Classes"
                      ? (selectedSortClass ?? "S2 BCA")
                      : selectedTeacher,
                  items: selectedSegment == "Classes"
                      ? classesList
                      : teachersList,
                  onSelected: selectedSegment == "Classes"
                      ? onClassSelected
                      : onTeacherSelected,
                ),
              ),
            ],
          ),
        ),
        if (selectedSegment == "Classes") ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _UploadButton(onTap: onUploadTap),
                const SizedBox(width: 8),
                _EditButton(isEditing: isHodEditing, onTap: onEditToggle),
              ],
            ),
          ),
        ],
        const SizedBox(height: 4),
      ],
    );
  }
}

// ============================================================================
// Upload button (HOD)
// ============================================================================

class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;

  const _UploadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.outline, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.upload_file_rounded,
              color: AppColors.headingText,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              "Upload Timetable",
              style: GoogleFonts.inter(
                color: AppColors.headingText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================

// ============================================================================
// Timetable Table Card (the main card containing scrollable grid & scrollbar)
// ============================================================================

class _TimetableTableCard extends StatelessWidget {
  final List<List<TimetableSlot?>> gridSlots;
  final ScrollController scrollController;
  final double scrollProgress;
  final ValueChanged<double> onScrollChanged;
  final bool isSwapMode;
  final bool isHOD;
  final bool isHodEditing;
  final bool isTeacherSchedule;
  final void Function(TimetableSlot? slot, int day, int period) onCellTap;

  const _TimetableTableCard({
    required this.gridSlots,
    required this.scrollController,
    required this.scrollProgress,
    required this.onScrollChanged,
    required this.isSwapMode,
    required this.isHOD,
    required this.isHodEditing,
    required this.isTeacherSchedule,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.outline, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Horizontally scrollable table ──
          SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: _kTableWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row
                  _buildHeaderRow(),
                  // Divider between header and body
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
                  // Period rows
                  for (int period = 1; period <= 5; period++) ...[
                    _buildPeriodRow(period),
                    if (period < 5)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                  ],
                ],
              ),
            ),
          ),
          // ── Divider separating table body from scrollbar area ──
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          // ── Scrollbar inside the timetable card ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _ScrollTrack(
              progress: scrollProgress,
              onScrolled: onScrollChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    const days = ["", "MON", "TUE", "WED", "THU", "FRI"];
    return SizedBox(
      height: _kHeaderHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(6, (i) {
          final hasLeftBorder = i >= 1;
          return Container(
            width: i == 0 ? _kPeriodColWidth : _kDayColWidth,
            decoration: hasLeftBorder
                ? const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  )
                : null,
            child: i == 0
                ? const SizedBox.shrink()
                : Center(
                    child: Text(
                      days[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriodRow(int period) {
    final isInteractive = isSwapMode || (isHOD && isHodEditing);
    return SizedBox(
      height: _kRowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Period number column
          SizedBox(
            width: _kPeriodColWidth,
            child: Center(
              child: Text(
                "$period",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          // Day columns (Mon to Fri) — all 5 day columns have left dividers
          for (int day = 1; day <= 5; day++)
            _DataCell(
              slot: gridSlots[period - 1][day - 1],
              secondaryLabel: isTeacherSchedule
                  ? gridSlots[period - 1][day - 1]?.classId
                  : gridSlots[period - 1][day - 1]?.teacherName,
              isInteractive: isInteractive,
              showLeftBorder: true,
              onTap: () =>
                  onCellTap(gridSlots[period - 1][day - 1], day, period),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Individual data cell
// ============================================================================

class _DataCell extends StatelessWidget {
  final TimetableSlot? slot;
  final bool isInteractive;
  final bool showLeftBorder;
  final String? secondaryLabel;
  final VoidCallback onTap;

  const _DataCell({
    required this.slot,
    required this.isInteractive,
    required this.showLeftBorder,
    required this.secondaryLabel,
    required this.onTap,
  });

  Border? get _leftBorder => showLeftBorder
      ? const Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1))
      : null;

  @override
  Widget build(BuildContext context) {
    if (slot == null) {
      return Container(
        width: _kDayColWidth,
        height: _kRowHeight,
        decoration: _leftBorder != null
            ? BoxDecoration(border: _leftBorder)
            : null,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          child: const Center(
            child: Text(
              "—",
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: _kDayColWidth,
      height: _kRowHeight,
      decoration: BoxDecoration(
        color: isInteractive
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surface,
        border: _leftBorder,
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.secondary.withValues(alpha: 0.3),
        highlightColor: AppColors.secondary.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                slot!.subjectName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                secondaryLabel ?? slot!.teacherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Scroll track (matching Figma: track 331px, thumb 180px, responsive & interactive)
// ============================================================================

class _ScrollTrack extends StatelessWidget {
  final double progress;
  final ValueChanged<double>? onScrolled;

  const _ScrollTrack({required this.progress, this.onScrolled});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth < 331.0
            ? (constraints.maxWidth - 24).clamp(100.0, 331.0)
            : 331.0;
        final thumbWidth = trackWidth * (180.0 / 331.0);
        final maxOffset = trackWidth - thumbWidth;
        final currentOffset = (progress * maxOffset).clamp(0.0, maxOffset);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: onScrolled != null
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPos = box.globalToLocal(details.globalPosition);
                  final double newProgress = (localPos.dx / trackWidth).clamp(
                    0.0,
                    1.0,
                  );
                  onScrolled!(newProgress);
                }
              : null,
          onTapDown: onScrolled != null
              ? (details) {
                  final double newProgress =
                      (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
                  onScrolled!(newProgress);
                }
              : null,
          child: SizedBox(
            width: trackWidth,
            height: 12,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Container(
                    width: trackWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: currentOffset,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: thumbWidth,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// Pill segment toggle (Classes / Teachers)
// ============================================================================

class _PillSegment extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _PillSegment({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.outline, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                labels[i],
                style: GoogleFonts.inter(
                  color: isSelected
                      ? AppColors.surface
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================================
// Outlined dropdown trigger
// ============================================================================

class _OutlinedDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _OutlinedDropdown({
    required this.label,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      offset: const Offset(0, 48),
      itemBuilder: (_) => items
          .map(
            (item) => PopupMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.outline, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: AppColors.headingText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.headingText,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Edit / Save button (HOD)
// ============================================================================

class _EditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onTap;

  const _EditButton({required this.isEditing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isEditing ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isEditing ? AppColors.primary : AppColors.outline,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditing ? Icons.check_rounded : Icons.edit_outlined,
              color: isEditing ? AppColors.surface : AppColors.headingText,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isEditing ? "Save" : "Edit",
              style: GoogleFonts.inter(
                color: isEditing ? AppColors.surface : AppColors.headingText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Swap / Request button (Teacher)
// ============================================================================

class _SwapButton extends StatelessWidget {
  final bool isSwapMode;
  final VoidCallback onTap;

  const _SwapButton({required this.isSwapMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSwapMode ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSwapMode ? AppColors.primary : AppColors.outline,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSwapMode) ...[
              const Icon(
                Icons.swap_horiz_rounded,
                color: AppColors.headingText,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              isSwapMode ? "Request" : "Swap",
              style: GoogleFonts.inter(
                color: isSwapMode ? AppColors.surface : AppColors.headingText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Select Teacher Dialog
// ============================================================================

class _SelectTeacherDialog extends StatefulWidget {
  final String currentTeacher;
  final ValueChanged<String> onSelected;

  const _SelectTeacherDialog({
    required this.currentTeacher,
    required this.onSelected,
  });

  @override
  State<_SelectTeacherDialog> createState() => _SelectTeacherDialogState();
}

class _SelectTeacherDialogState extends State<_SelectTeacherDialog> {
  late String _selectedTeacher;
  final List<String> _availableTeachers = [
    "Anju miss",
    "Anju krishna",
    "Anu Varghese",
    "Rijina NM",
    "Sheetal",
    "Lakshmi",
  ];

  @override
  void initState() {
    super.initState();
    _selectedTeacher = widget.currentTeacher.isNotEmpty
        ? widget.currentTeacher
        : "Anju miss";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Select the teacher",
                style: GoogleFonts.poppins(
                  color: AppColors.headingText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Teacher Name",
              style: GoogleFonts.inter(
                color: AppColors.headingText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Dropdown
            PopupMenuButton<String>(
              onSelected: (teacher) {
                setState(() => _selectedTeacher = teacher);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              offset: const Offset(0, 52),
              itemBuilder: (_) => _availableTeachers
                  .map(
                    (t) => PopupMenuItem<String>(
                      value: t,
                      child: Text(
                        t,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.outline, width: 1.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedTeacher.isNotEmpty
                            ? _selectedTeacher
                            : "Select teacher",
                        style: GoogleFonts.inter(
                          color: _selectedTeacher.isNotEmpty
                              ? AppColors.headingText
                              : AppColors.hintText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.headingText,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: BlueBtn(
                    text: "Cancel",
                    backgroundColor: const Color(0xFF6E6E6E),
                    borderColor: const Color(0xFF6E6E6E),
                    textColor: AppColors.surface,
                    borderRadius: AppRadius.pill,
                    onPressed: () {
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BlueBtn(
                    text: "Save",
                    backgroundColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    textColor: AppColors.surface,
                    borderRadius: AppRadius.pill,
                    onPressed: () {
                      widget.onSelected(_selectedTeacher);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

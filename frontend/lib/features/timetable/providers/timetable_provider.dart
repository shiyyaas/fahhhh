import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../home/widgets/status_badge.dart';
import '../models/timetable_slot.dart';
import '../../../core/network/api_client.dart';
import '../repositories/timetable_repository.dart';

part 'timetable_provider.g.dart';

// Reactive local selected date state provider
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }
}

// Student mock model (kept for type compatibility; no mock data remains)
class Student {
  final String rollNumber;
  final String name;

  const Student({required this.rollNumber, required this.name});
}

// ─── All mock static lists have been removed ──────────────────────────────────
// s2BcaStudents, s4BcaStudents, s6BcaStudents, s8BcaStudents — removed
// getStudentsForClass() — removed
// semesterSubjects map — removed
// subjectTeachers map — removed
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
class TimetableNotifier extends _$TimetableNotifier {
  @override
  List<TimetableSlot> build() {
    // Initial state is empty; real timetable is loaded by role-specific
    // FutureProviders (allTimetableProvider / batchTimetableProvider /
    // teacherTimetableProvider) and pushed into this notifier via
    // TimetableNotifier.loadSlots() called from home.dart.
    return [];
  }

  /// Replaces the full slot list (called after fetching from backend).
  void loadSlots(List<TimetableSlot> slots) {
    state = slots;
  }

  void updateSlot(TimetableSlot updatedSlot) {
    state = [
      for (final slot in state)
        if (slot.id == updatedSlot.id) updatedSlot else slot
    ];
  }

  void saveAttendance(String slotId, Map<String, AttendanceStatus> attendance) {
    state = [
      for (final slot in state)
        if (slot.id == slotId)
          slot.copyWith(
            status: AttendanceStatus.recorded,
            studentAttendance: attendance,
          )
        else
          slot
    ];
  }

  void resetAll() {
    ref.invalidateSelf();
  }
}

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TimetableRepository(apiClient: apiClient);
});

/// All timetable entries — used by HOD.
final allTimetableProvider = FutureProvider<List<TimetableSlot>>((ref) async {
  final repo = ref.watch(timetableRepositoryProvider);
  return repo.getAllTimetable();
});

final batchTimetableProvider = FutureProvider.family<List<TimetableSlot>, String>((ref, batchId) async {
  final repo = ref.watch(timetableRepositoryProvider);
  return repo.getBatchTimetable(batchId);
});

final teacherTimetableProvider = FutureProvider.family<List<TimetableSlot>, String>((ref, teacherId) async {
  final repo = ref.watch(timetableRepositoryProvider);
  return repo.getTeacherTimetable(teacherId);
});

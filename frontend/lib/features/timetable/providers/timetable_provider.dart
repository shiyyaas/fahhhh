import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/widgets/status_badge.dart';
import '../models/timetable_slot.dart';
import '../../../core/network/api_client.dart';
import '../repositories/timetable_repository.dart';

part 'timetable_provider.g.dart';

// Reactive selected date state.
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }
}

// Kept for compatibility with existing attendance-related code.
class Student {
  final String rollNumber;
  final String name;

  const Student({required this.rollNumber, required this.name});
}

@riverpod
class TimetableNotifier extends _$TimetableNotifier {
  @override
  List<TimetableSlot> build() => [];

  /// Replaces the local list after a successful backend fetch.
  void loadSlots(List<TimetableSlot> slots) {
    state = slots;
  }

  /// Local-only update. Keep this for UI-only changes such as attendance.
  /// For HOD timetable edits, call saveSlot() instead.
  void updateSlot(TimetableSlot updatedSlot) {
    state = [
      for (final slot in state)
        if (slot.id == updatedSlot.id) updatedSlot else slot,
    ];
  }

  /// Creates a timetable entry in MongoDB and adds the server-returned record.
  Future<TimetableSlot> createSlot(TimetableSlot slot) async {
    final repository = ref.read(timetableRepositoryProvider);
    final createdSlot = await repository.createTimetable(slot);

    state = [
      ...state.where((item) => item.id != createdSlot.id),
      createdSlot,
    ];
    _invalidateTimetableQueries();
    return createdSlot;
  }

  /// Updates an existing MongoDB timetable entry and replaces local state.
  Future<TimetableSlot> saveSlot(TimetableSlot slot) async {
    if (slot.id.isEmpty) {
      throw ArgumentError('Cannot update a timetable entry without a MongoDB ID.');
    }

    final repository = ref.read(timetableRepositoryProvider);
    final savedSlot = await repository.updateTimetable(slot);

    state = [
      for (final item in state)
        if (item.id == savedSlot.id) savedSlot else item,
    ];
    _invalidateTimetableQueries();
    return savedSlot;
  }

  /// Deletes an entry from MongoDB, then removes it from local state.
  Future<void> deleteSlot(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Timetable ID is required.');
    }

    final repository = ref.read(timetableRepositoryProvider);
    await repository.deleteTimetable(id);

    state = state.where((slot) => slot.id != id).toList();
    _invalidateTimetableQueries();
  }

  void saveAttendance(
    String slotId,
    Map<String, AttendanceStatus> attendance,
  ) {
    state = [
      for (final slot in state)
        if (slot.id == slotId)
          slot.copyWith(
            status: AttendanceStatus.recorded,
            studentAttendance: attendance,
          )
        else
          slot,
    ];
  }

  void resetAll() {
    ref.invalidateSelf();
  }

  void _invalidateTimetableQueries() {
    ref.invalidate(allTimetableProvider);
    ref.invalidate(batchTimetableProvider);
    ref.invalidate(teacherTimetableProvider);
  }
}

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TimetableRepository(apiClient: apiClient);
});

/// All timetable entries — used by HOD.
final allTimetableProvider = FutureProvider<List<TimetableSlot>>((ref) async {
  final repository = ref.watch(timetableRepositoryProvider);
  return repository.getAllTimetable();
});

final batchTimetableProvider =
    FutureProvider.family<List<TimetableSlot>, String>((ref, batchId) async {
  final repository = ref.watch(timetableRepositoryProvider);
  return repository.getBatchTimetable(batchId);
});

final teacherTimetableProvider =
    FutureProvider.family<List<TimetableSlot>, String>((ref, teacherId) async {
  final repository = ref.watch(timetableRepositoryProvider);
  return repository.getTeacherTimetable(teacherId);
});

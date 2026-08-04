// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedDateHash() => r'6e667223566db223a1c3a04a771bfcc94381a3a8';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
      SelectedDate.new,
      name: r'selectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$timetableNotifierHash() => r'9f105d7ee2211b6befa528aa0ec72a9089cf8b63';

/// See also [TimetableNotifier].
@ProviderFor(TimetableNotifier)
final timetableNotifierProvider =
    AutoDisposeNotifierProvider<
      TimetableNotifier,
      List<TimetableSlot>
    >.internal(
      TimetableNotifier.new,
      name: r'timetableNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$timetableNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TimetableNotifier = AutoDisposeNotifier<List<TimetableSlot>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

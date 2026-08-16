enum HeaderPageType {
  department,
  myClass,
}

class HeaderMenuConfig {
  /// Returns the dynamic menu items based on page type and toggle segment index/label.
  static List<String> getMenuItems({
    required HeaderPageType pageType,
    int selectedSegmentIndex = 0,
    String? activeSegmentLabel,
  }) {
    if (pageType == HeaderPageType.department) {
      // 0 = "Classes", 1 = "Teachers"
      final isTeachers = activeSegmentLabel != null
          ? (activeSegmentLabel.toLowerCase() == 'teachers' ||
              activeSegmentLabel.toLowerCase() == 'teacher')
          : selectedSegmentIndex == 1;

      if (isTeachers) {
        return const [
          'TimeTableSettings',
          'Archived Batches',
          'Teachers Settings',
        ];
      } else {
        return const [
          'TimeTableSettings',
          'Archived Batches',
        ];
      }
    } else {
      // My Class Page
      // 0 = "Students", 1 = "Subjects"
      final isSubjects = activeSegmentLabel != null
          ? activeSegmentLabel.toLowerCase() == 'subjects'
          : selectedSegmentIndex == 1;

      if (isSubjects) {
        return const [
          'Generate Report',
          'Attendance history',
          'Time table',
          'Check Condonation',
          'Subject Settings',
        ];
      } else {
        return const [
          'Generate Report',
          'Attendance history',
          'Time table',
          'Check Condonation',
          'Student settings',
        ];
      }
    }
  }
}

/// A student entry shown in the Department - Students list.
class DepartmentStudent {
  final String? id;
  final String name;
  final String rollNumber;
  final String? email;
  final String? phoneNo;
  final String? apaarId;
  final String? batchId;
  final String? batchName;
  final String? imageUrl;

  const DepartmentStudent({
    this.id,
    required this.name,
    required this.rollNumber,
    this.email,
    this.phoneNo,
    this.apaarId,
    this.batchId,
    this.batchName,
    this.imageUrl,
  });

  factory DepartmentStudent.fromJson(Map<String, dynamic> json) {
    String? bId;
    String? bName;
    if (json['batchId'] is Map) {
      bId = json['batchId']['_id'] as String?;
      bName = json['batchId']['batchName'] as String?;
    } else if (json['batchId'] is String) {
      bId = json['batchId'] as String;
    }

    return DepartmentStudent(
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['studentName'] as String? ?? json['name'] as String? ?? '',
      rollNumber: json['registerNo'] as String? ?? json['rollNumber'] as String? ?? '',
      email: json['email'] as String?,
      phoneNo: json['phoneNo'] as String?,
      apaarId: json['apaarId'] as String?,
      batchId: bId,
      batchName: bName,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': name,
      'registerNo': rollNumber,
      'email': email,
      'phoneNo': phoneNo,
      'apaarId': apaarId,
      'batchId': batchId,
      'imageUrl': imageUrl,
    };
  }
}

/// Fallback mock students for the department overview when offline/unseeded.
const List<DepartmentStudent> mockDepartmentStudents = [
  DepartmentStudent(name: "Alice Johnson", rollNumber: "S2023001"),
  DepartmentStudent(name: "Bob Smith", rollNumber: "S2023002"),
  DepartmentStudent(name: "Carol Davis", rollNumber: "S2023003"),
  DepartmentStudent(name: "David Wilson", rollNumber: "S2023004"),
  DepartmentStudent(name: "Emma Brown", rollNumber: "S2023005"),
  DepartmentStudent(name: "Frank Miller", rollNumber: "S2023006"),
  DepartmentStudent(name: "Grace Lee", rollNumber: "S2023007"),
  DepartmentStudent(name: "Henry Taylor", rollNumber: "S2023008"),
  DepartmentStudent(name: "Isabella Clark", rollNumber: "S2023009"),
  DepartmentStudent(name: "Jack Anderson", rollNumber: "S2023010"),
];
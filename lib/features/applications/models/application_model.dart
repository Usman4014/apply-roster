
class ApplicationModel {
  final int? id;
  final String companyName;
  final String jobTitle;
  final String? location;
  final String? employmentType;
  final String? jobUrl;
  final String? salary;
  final DateTime appliedDate;
  final String? source;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ApplicationModel({
    this.id,
    required this.companyName,
    required this.jobTitle,
    this.location,
    this.employmentType,
    this.jobUrl,
    this.salary,
    required this.appliedDate,
    this.source,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Model to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'job_title': jobTitle,
      'location': location,
      'employment_type': employmentType,
      'job_url': jobUrl,
      'salary': salary,
      'applied_date': appliedDate.toIso8601String(),
      'source': source,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Create Model from Map
  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'] as int?,
      companyName: map['company_name'] as String,
      jobTitle: map['job_title'] as String,
      location: map['location'] as String?,
      employmentType: map['employment_type'] as String?,
      jobUrl: map['job_url'] as String?,
      salary: map['salary'] as String?,
      appliedDate: DateTime.parse(map['applied_date'] as String),
      source: map['source'] as String?,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  // Copy Model with Updated Values
  ApplicationModel copyWith({
    int? id,
    String? companyName,
    String? jobTitle,
    String? location,
    String? employmentType,
    String? jobUrl,
    String? salary,
    DateTime? appliedDate,
    String? source,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearLocation = false,
    bool clearEmploymentType = false,
    bool clearJobUrl = false,
    bool clearSalary = false,
    bool clearSource = false,
    bool clearNotes = false,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      location: clearLocation ? null : location ?? this.location,
      employmentType: clearEmploymentType
          ? null
          : employmentType ?? this.employmentType,
      jobUrl: clearJobUrl ? null : jobUrl ?? this.jobUrl,
      salary: clearSalary ? null : salary ?? this.salary,
      appliedDate: appliedDate ?? this.appliedDate,
      source: clearSource ? null : source ?? this.source,
      status: status ?? this.status,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

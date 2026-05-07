class PatientInfo {
  const PatientInfo({
    required this.isForSelf,
    required this.name,
    required this.gender,
    required this.age,
    required this.problemDescription,
  });

  final bool isForSelf;
  final String name;
  final String gender;
  final String age;
  final String problemDescription;

  PatientInfo copyWith({
    bool? isForSelf,
    String? name,
    String? gender,
    String? age,
    String? problemDescription,
  }) {
    return PatientInfo(
      isForSelf: isForSelf ?? this.isForSelf,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      problemDescription: problemDescription ?? this.problemDescription,
    );
  }
}

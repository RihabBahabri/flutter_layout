class Student {
  Student(
      {required this.id,
      required this.name,
      required this.school,
      required this.grade,
      this.track});

  final String id;
  final String name;
  final String school;
  final String grade;
  final String? track;

  factory Student.fromJson(Map<String, dynamic> data) {
    // ! there's a problem with this code (see below)
    // final id = data['id'] as String;
    // final name = data['name'] as String;
    // final school = data['school'] as String;
    // final grade = data['grade'] as String;
    // final track = data['track'] as String?;

    if (data
        case {
          'id': String id,
          'name': String name,
          'school': String school,
          'grade': String grade,
          'track': String? track,
        }) {
      return Student(
        id: id,
        name: name,
        school: school,
        grade: grade,
        track: track,
      );
    } else {
      return Student(
        id: "",
        name: "                                    ",
        school: "",
        grade: "",
        track: "",
      );
    }
  }
}

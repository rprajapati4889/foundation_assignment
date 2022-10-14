abstract class Student {
  void showStudentInformation();
}

class Teacher extends Student {
  @override
  void showStudentInformation() {
    print("I'm a teacher");
  }
}

class Principal extends Student {
  @override
  void showStudentInformation() {
    print("I'm the principal.");
  }
}

void main() {
  Teacher teacher = Teacher();
  Principal principal = Principal();
  teacher.showStudentInformation();
  principal.showStudentInformation();
}

///OutPut
/// I'm a teacher
///I'm the principal.

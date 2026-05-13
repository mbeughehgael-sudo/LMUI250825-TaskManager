class Task {
  static int _counter = 0;

  final int id;
  String title;
  String description;
  String category;
  String priority;
  DateTime dueDate;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  }) : id = ++_counter;
}

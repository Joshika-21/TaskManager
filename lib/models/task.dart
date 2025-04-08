class Task {
  String id;
  String name;
  bool isDone;
  Map<String, List<String>> nestedTasks; // e.g., {"9am-10am": ["HW1", "Essay2"]}

  Task({
    required this.id,
    required this.name,
    this.isDone = false,
    this.nestedTasks = const {},
  });

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      name: data['name'],
      isDone: data['isDone'],
      nestedTasks: Map<String, List<String>>.from(data['nestedTasks'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isDone': isDone,
      'nestedTasks': nestedTasks,
    };
  }
}

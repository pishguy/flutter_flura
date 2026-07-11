class TodoModel {
  final String id;
  String title;
  bool completed;

  TodoModel({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'completed': completed,
      };

  factory TodoModel.fromMap(Map<String, dynamic> map) => TodoModel(
        id: map['id'] as String,
        title: map['title'] as String,
        completed: map['completed'] as bool? ?? false,
      );
}

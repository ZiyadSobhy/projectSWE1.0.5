class Task {
  final String id; // Unique identifier for the task
  final String title; // Title of the task
  final String description; // Description of the task
  bool isCompleted; // Status of the task

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  // Convert Task instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  // Create a Task instance from Firestore document
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class UserModel {
  final String uid; // User ID
  final String name; // User's name
  final String email; // User's email
  final List<Task> tasks; // List of tasks assigned to the user

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.tasks = const [], // Default to an empty list
  });

  // Convert UserModel instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
  }

  // Create a UserModel instance from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      tasks: map['tasks'] != null
          ? List<Task>.from(map['tasks'].map((task) => Task.fromMap(task)))
          : [],
    );
  }

  // Add a task to the user's list of tasks
  void addTask(Task task) {
    tasks.add(task);
  }

  // Remove a task by its ID
  void removeTask(String taskId) {
    tasks.removeWhere((task) => task.id == taskId);
  }

  // Mark a task as completed
  void completeTask(String taskId) {
    final task = tasks.firstWhere((task) => task.id == taskId, orElse: () => throw Exception("Task not found"));
    task.isCompleted = true;
  }
}

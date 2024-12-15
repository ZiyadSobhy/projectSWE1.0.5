import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import '../user/user.dart';

class AdminWorkoutDietPlan extends StatefulWidget {
  final UserModel user; // UserModel passed via constructor

  AdminWorkoutDietPlan({required this.user});

  @override
  _AdminWorkoutDietPlanState createState() => _AdminWorkoutDietPlanState();
}

class _AdminWorkoutDietPlanState extends State<AdminWorkoutDietPlan> {
  final TextEditingController _taskController = TextEditingController();
  late List<Task> _tasks; // List of tasks specific to the user

  @override
  void initState() {
    super.initState();
    _tasks = widget.user.tasks; // Initialize tasks from the passed UserModel
  }

  // Add task to Firebase and update UserModel's task list
  void _addTask() async {
    String taskTitle = _taskController.text.trim();
    if (taskTitle.isNotEmpty) {
      // Create new task
      Task newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: taskTitle,
        description: 'Description of the task', // Optional description
      );

      // Update Firestore (for the user)
      try {
        // Add the task to Firebase under the user's document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .update({
          'tasks': FieldValue.arrayUnion([newTask.toMap()]),
        });

        // Add task locally to the user model
        setState(() {
          _tasks.add(newTask);
          _taskController.clear(); // Clear the input field after adding
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task')),
      );
    }
  }

  // Delete task from Firebase and update UserModel's task list
  void _deleteTask(int index) async {
    Task taskToDelete = _tasks[index];

    try {
      // Remove task from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'tasks': FieldValue.arrayRemove([taskToDelete.toMap()]),
      });

      // Remove task locally
      setState(() {
        _tasks.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task removed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.name}\'s Workout & Diet Plans'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create and Manage Plans',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Add tasks to organize your plans effectively.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Enter a task',
                      hintText: 'e.g., Morning Workout',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: Icon(Icons.add),
                  label: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'No tasks added yet!',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        Task task = _tasks[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

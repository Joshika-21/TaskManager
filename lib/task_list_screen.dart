import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final taskController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get tasksCollection => FirebaseFirestore.instance.collection('users').doc(uid).collection('tasks');

  Future<void> addTask(String name) async {
    await tasksCollection.add(Task(id: '', name: name).toMap());
  }

  Future<void> deleteTask(String id) async {
    await tasksCollection.doc(id).delete();
  }

  Future<void> toggleCompletion(Task task) async {
    await tasksCollection.doc(task.id).update({'isDone': !task.isDone});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: [
          TextField(controller: taskController, decoration: const InputDecoration(labelText: 'Enter Task')),
          ElevatedButton(
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                addTask(taskController.text);
                taskController.clear();
              }
            },
            child: const Text('Add Task'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: tasksCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final tasks = snapshot.data!.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
                return ListView(
                  children: tasks.map((task) {
                    return Card(
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Checkbox(
                              value: task.isDone,
                              onChanged: (_) => toggleCompletion(task),
                            ),
                            Expanded(child: Text(task.name)),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteTask(task.id),
                            )
                          ],
                        ),
                        children: task.nestedTasks.entries.map((entry) {
                          return ListTile(
                            title: Text("${entry.key}: ${entry.value.join(', ')}"),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pt_tracker/models/task.dart';
import 'package:pt_tracker/providers/task_provider.dart';
import 'package:pt_tracker/widgets/task_card.dart';

class TaskList extends StatelessWidget {
  final TaskStatus status;
  
  const TaskList({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.getTasksByStatus(status);
        
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'अहिले सम्म कुनै कार्य छैन',  // "No tasks yet" in Nepali
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: tasks[index],
              onStatusChanged: (newStatus) {
                taskProvider.updateTaskStatus(tasks[index], newStatus);
              },
              onDelete: () {
                taskProvider.deleteTask(tasks[index]);
              },
              onComplete: () {
                taskProvider.markTaskAsCompleted(tasks[index]);
              },
            );
          },
        );
      },
    );
  }
}

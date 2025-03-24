import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pt_tracker/models/task.dart';
import 'package:uuid/uuid.dart';
import 'package:pt_tracker/models/task_analytics.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  final _uuid = const Uuid();

  TaskProvider() {
    _taskBox = Hive.box<Task>('tasks');
    _setupReminderChecks();
    _checkForRecurringTasks();
  }

  List<Task> get allTasks => _taskBox.values.toList();

  List<Task> getTasksByStatus(TaskStatus status) {
    return _taskBox.values.where((task) => task.status == status).toList();
  }

  Future<void> addTask(
    String title, 
    String? description, 
    DateTime? dueDate, 
    TaskSeverity severity,
    TaskStatus status,
    RecurrenceType recurrenceType,
  ) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      severity: severity,
      status: status,
      recurrenceType: recurrenceType,
    );
    
    await _taskBox.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await task.save();
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
    notifyListeners();
  }

  Future<void> updateTaskStatus(Task task, TaskStatus status) async {
    task.status = status;
    // If task is moved from completed to any other status, mark it as incomplete
    if (task.isCompleted && status != TaskStatus.wontDo) {
      task.isCompleted = false;
    }
    // If task is moved to won't do, mark it as completed
    if (status == TaskStatus.wontDo) {
      task.isCompleted = true;
    }
    await task.save();
    notifyListeners();
  }

  Future<void> markTaskAsCompleted(Task task) async {
    task.isCompleted = true;
    await task.save();
    
    // Check if this is a recurring task
    if (task.isRecurring) {
      await _createNextRecurringTask(task);
    }
    
    notifyListeners();
  }

  void _setupReminderChecks() {
    // Check for overdue critical tasks every hour
    Future.delayed(const Duration(hours: 1), () async {
      await _checkForOverdueCriticalTasks();
      _setupReminderChecks(); // Schedule next check
    });
  }

  Future<void> _checkForOverdueCriticalTasks() async {
    final now = DateTime.now();
    final criticalTasks = _taskBox.values.where(
      (task) => 
        task.severity == TaskSeverity.critical && 
        !task.isCompleted && 
        task.dueDate != null && 
        task.dueDate!.isBefore(now)
    ).toList();
    
    for (var task in criticalTasks) {
      // Update the last reminder time
      task.lastRecurrenceDate = now;
      await task.save();
    }
  }
  
  Future<void> _checkForRecurringTasks() async {
    // Run this check daily
    await _processRecurringTasks();
    
    // Schedule the next check
    Future.delayed(const Duration(hours: 24), () {
      _checkForRecurringTasks();
    });
  }
  
  Future<void> _processRecurringTasks() async {
    final now = DateTime.now();
    final completedTasks = _taskBox.values.where(
      (task) => 
        task.isCompleted && 
        task.isRecurring && 
        task.dueDate != null &&
        (task.lastRecurrenceDate == null || 
         _isRecurrenceDue(task.lastRecurrenceDate!, now, task.recurrenceType))
    ).toList();
    
    for (var task in completedTasks) {
      await _createNextRecurringTask(task);
    }
  }
  
  bool _isRecurrenceDue(DateTime lastDate, DateTime now, RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return now.difference(lastDate).inDays >= 1;
      case RecurrenceType.weekly:
        return now.difference(lastDate).inDays >= 7;
      case RecurrenceType.monthly:
        return (now.year - lastDate.year) * 12 + now.month - lastDate.month >= 1;
      case RecurrenceType.yearly:
        return now.year - lastDate.year >= 1;
      default:
        return false;
    }
  }
  
  Future<void> _createNextRecurringTask(Task completedTask) async {
    final nextDueDate = completedTask.calculateNextRecurrence();
    if (nextDueDate == null) return;
    
    final newTask = Task(
      id: _uuid.v4(),
      title: completedTask.title,
      description: completedTask.description,
      createdAt: DateTime.now(),
      dueDate: nextDueDate,
      severity: completedTask.severity,
      status: TaskStatus.todo,
      recurrenceType: completedTask.recurrenceType,
      parentTaskId: completedTask.parentTaskId ?? completedTask.id,
      recurrenceCount: (completedTask.recurrenceCount ?? 0) + 1,
      lastRecurrenceDate: completedTask.dueDate,
    );
    
    await _taskBox.add(newTask);
  }

  TaskSeverity suggestPriority(String title, String? description) {
    // Simple keyword-based priority suggestion
    final String text = '${title.toLowerCase()} ${description?.toLowerCase() ?? ''}';
    
    if (text.contains('urgent') || 
        text.contains('asap') || 
        text.contains('emergency') ||
        text.contains('जरुरी') ||
        text.contains('तुरुन्त')) {
      return TaskSeverity.critical;
    }
    
    if (text.contains('important') || 
        text.contains('priority') ||
        text.contains('महत्वपूर्ण')) {
      return TaskSeverity.high;
    }
    
    return TaskSeverity.medium;
  }

  DateTime suggestDueDate(String title, String? description) {
    final now = DateTime.now();
    final analytics = TaskAnalytics.fromTasks(allTasks);
    
    // If user completes tasks quickly, suggest shorter deadlines
    if (analytics.productivityScore > 80) {
      return now.add(const Duration(days: 1));
    }
    
    // Default to 3 days for medium tasks
    return now.add(const Duration(days: 3));
  }
}

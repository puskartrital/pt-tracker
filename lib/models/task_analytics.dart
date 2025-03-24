import 'package:pt_tracker/models/task.dart';

class TaskAnalytics {
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final Map<DateTime, int> dailyCompletion;
  final Map<TaskSeverity, int> severityDistribution;
  final double productivityScore;
  
  const TaskAnalytics({
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.dailyCompletion,
    required this.severityDistribution,
    required this.productivityScore,
  });

  factory TaskAnalytics.fromTasks(List<Task> tasks) {
    final now = DateTime.now();
    final last30Days = DateTime(now.year, now.month, now.day - 30);
    
    // Calculate daily completion for last 30 days
    final Map<DateTime, int> daily = {};
    for (var task in tasks) {
      if (task.isCompleted && task.lastRecurrenceDate != null && 
          task.lastRecurrenceDate!.isAfter(last30Days)) {
        final date = DateTime(
          task.lastRecurrenceDate!.year,
          task.lastRecurrenceDate!.month,
          task.lastRecurrenceDate!.day,
        );
        daily[date] = (daily[date] ?? 0) + 1;
      }
    }
    
    // Calculate severity distribution
    final Map<TaskSeverity, int> severity = {};
    for (var task in tasks) {
      severity[task.severity] = (severity[task.severity] ?? 0) + 1;
    }
    
    // Calculate completion rate and productivity score
    final completed = tasks.where((t) => t.isCompleted).length;
    final rate = tasks.isEmpty ? 0.0 : completed / tasks.length;
    
    // Productivity score (0-100) based on:
    // - Completion rate (60%)
    // - High priority completion (30%)
    // - Consistency (10%)
    final highPriorityRate = tasks.where((t) => 
      t.isCompleted && 
      (t.severity == TaskSeverity.high || t.severity == TaskSeverity.critical)
    ).length / (tasks.where((t) => 
      t.severity == TaskSeverity.high || t.severity == TaskSeverity.critical
    ).length);
    
    final consistencyScore = daily.length / 30.0; // Activity days / 30
    
    final productivityScore = (rate * 0.6 + 
                             (highPriorityRate.isNaN ? 0 : highPriorityRate) * 0.3 + 
                             consistencyScore * 0.1) * 100;
    
    return TaskAnalytics(
      totalTasks: tasks.length,
      completedTasks: completed,
      completionRate: rate,
      dailyCompletion: daily,
      severityDistribution: severity,
      productivityScore: productivityScore,
    );
  }
}

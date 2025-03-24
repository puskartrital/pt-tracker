import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
enum TaskStatus {
  @HiveField(0)
  todo,
  
  @HiveField(1)
  inProgress,
  
  @HiveField(2)
  onHold,
  
  @HiveField(3)
  wontDo,
}

@HiveType(typeId: 1)
enum TaskSeverity {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
  
  @HiveField(3)
  critical,
}

@HiveType(typeId: 3)
enum RecurrenceType {
  @HiveField(0)
  none,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
  
  @HiveField(4)
  yearly,
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  DateTime? dueDate;
  
  @HiveField(5)
  TaskStatus status;
  
  @HiveField(6)
  TaskSeverity severity;
  
  @HiveField(7)
  bool isCompleted;
  
  @HiveField(8)
  RecurrenceType recurrenceType;
  
  @HiveField(9)
  String? parentTaskId;
  
  @HiveField(10)
  int? recurrenceCount;
  
  @HiveField(11)
  DateTime? lastRecurrenceDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.status = TaskStatus.todo,
    this.severity = TaskSeverity.medium,
    this.isCompleted = false,
    this.recurrenceType = RecurrenceType.none,
    this.parentTaskId,
    this.recurrenceCount,
    this.lastRecurrenceDate,
  });
  
  bool get isRecurring => recurrenceType != RecurrenceType.none;
  
  bool get isRecurringChild => parentTaskId != null;
  
  DateTime? calculateNextRecurrence() {
    if (!isRecurring || dueDate == null) return null;
    
    final DateTime baseDate = lastRecurrenceDate ?? dueDate!;
    
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return DateTime(
          baseDate.year, 
          baseDate.month, 
          baseDate.day + 1,
          baseDate.hour,
          baseDate.minute,
        );
      case RecurrenceType.weekly:
        return DateTime(
          baseDate.year, 
          baseDate.month, 
          baseDate.day + 7,
          baseDate.hour,
          baseDate.minute,
        );
      case RecurrenceType.monthly:
        // Handle month overflow
        int nextMonth = baseDate.month + 1;
        int nextYear = baseDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }
        return DateTime(
          nextYear, 
          nextMonth, 
          baseDate.day > 28 ? _adjustDayForMonth(baseDate.day, nextMonth, nextYear) : baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
      case RecurrenceType.yearly:
        return DateTime(
          baseDate.year + 1, 
          baseDate.month, 
          baseDate.day > 28 ? _adjustDayForMonth(baseDate.day, baseDate.month, baseDate.year + 1) : baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
      default:
        return null;
    }
  }
  
  int _adjustDayForMonth(int day, int month, int year) {
    // Handle months with different lengths
    if (month == 2) {
      // February
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? (day > 29 ? 29 : day) : (day > 28 ? 28 : day);
    } else if ([4, 6, 9, 11].contains(month)) {
      // April, June, September, November (30 days)
      return day > 30 ? 30 : day;
    }
    return day; // 31 days months
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pt_tracker/models/task.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(TaskStatus) onStatusChanged;
  final VoidCallback onDelete;
  final VoidCallback onComplete;
  final Function(Task) onEdit;
  
  const TaskCard({
    Key? key,
    required this.task,
    required this.onStatusChanged,
    required this.onDelete,
    required this.onComplete,
    required this.onEdit,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildQuickActionButtons(Task task) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.edit_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => _editTask(context, task),
        ),
        if (!task.isCompleted)
          IconButton(
            icon: const Icon(
              Icons.task_alt_rounded,
              size: 20,
              color: AppTheme.completedColor,
            ),
            onPressed: widget.onComplete,
          ),
        IconButton(
          icon: Icon(
            Icons.adaptive.more,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () => _showActionsMenu(context),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.3)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInlineEditableTitle() {
    if (_isEditing) {
      return TextField(
        controller: _titleController,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onSubmitted: (value) {
          setState(() {
            _isEditing = false;
            // Update task title
            widget.onEdit(widget.task.copyWith(title: value));
          });
        },
      );
    }

    return InkWell(
      onTap: () => setState(() => _isEditing = true),
      child: Text(
        widget.task.title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: widget.task.dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(
              widget.task.dueDate ?? DateTime.now(),
            ),
          );
          
          if (time != null) {
            final newDate = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
            widget.onEdit(widget.task.copyWith(dueDate: newDate));
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            widget.task.dueDate != null
                ? DateFormat('MMM d, y - h:mm a').format(widget.task.dueDate!)
                : 'Set due date',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with severity and badge
          _buildHeader(context),
          
          // Task content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with completion checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.task.isCompleted)
                      GestureDetector(
                        onTap: widget.onComplete,
                        child: Container(
                          margin: const EdgeInsets.only(right: 12, top: 2),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(right: 12, top: 2),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.green,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    
                    Expanded(
                      child: _buildInlineEditableTitle(),
                    ),
                    
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      position: PopupMenuPosition.under,
                      itemBuilder: (context) => [
                        if (!widget.task.isCompleted)
                          PopupMenuItem(
                            value: 'status',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_horiz,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text('Change Status'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              const Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'status') {
                          _showStatusChangeBottomSheet(context);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context);
                        }
                      },
                    ),
                  ],
                ),
                
                // Description
                if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Show a small dialog for description editing
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Edit Description'),
                          content: TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                widget.onEdit(widget.task.copyWith(
                                  description: _descriptionController.text,
                                ));
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 34),
                      child: Text(
                        widget.task.description!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Chips section (due date, recurrence)
                Padding(
                  padding: const EdgeInsets.only(left: 34),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Due date chip
                      if (widget.task.dueDate != null)
                        _buildDueDateChip(context),
                      
                      // Recurrence chip
                      if (widget.task.isRecurring)
                        _buildRecurrenceChip(context),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Date picker and status actions
                Row(
                  children: [
                    _buildDatePicker(),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Quick action buttons
                _buildQuickActionButtons(widget.task),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final severityColor = _getSeverityColor(widget.task.severity);
    final statusColor = _getStatusColor(widget.task.status);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            severityColor,
            statusColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSeverityIcon(widget.task.severity),
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _getSeverityText(widget.task.severity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(widget.task.status),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDueDateChip(BuildContext context) {
    final isOverdue = widget.task.dueDate!.isBefore(DateTime.now()) && !widget.task.isCompleted;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue 
            ? Colors.red.withOpacity(0.1) 
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: isOverdue 
            ? Border.all(color: Colors.red) 
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event,
            size: 14,
            color: isOverdue 
                ? Colors.red 
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(widget.task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              color: isOverdue 
                  ? Colors.red 
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecurrenceChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.repeat,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _getRecurrenceText(widget.task.recurrenceType),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showStatusChangeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...TaskStatus.values.map((status) {
              if (status != widget.task.status) {
                return ListTile(
                  leading: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                  ),
                  title: Text(_getStatusText(status)),
                  onTap: () {
                    widget.onStatusChanged(status);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: _getStatusColor(status).withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${widget.task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods for icons, colors, and text
  
  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.checklist;
      case TaskStatus.inProgress:
        return Icons.trending_up;
      case TaskStatus.onHold:
        return Icons.pause_circle_outline;
      case TaskStatus.wontDo:
        return Icons.not_interested;
    }
  }
  
  Color _getSeverityColor(TaskSeverity severity) {
    switch (severity) {
      case TaskSeverity.low:
        return const Color(0xFF10B981); // Emerald-500
      case TaskSeverity.medium:
        return const Color(0xFF3B82F6); // Blue-500
      case TaskSeverity.high:
        return const Color(0xFFF59E0B); // Amber-500
      case TaskSeverity.critical:
        return const Color(0xFFEF4444); // Red-500
    }
  }
  
  IconData _getSeverityIcon(TaskSeverity severity) {
    switch (severity) {
      case TaskSeverity.low:
        return Icons.arrow_downward;
      case TaskSeverity.medium:
        return Icons.remove;
      case TaskSeverity.high:
        return Icons.arrow_upward;
      case TaskSeverity.critical:
        return Icons.priority_high;
    }
  }
  
  String _getSeverityText(TaskSeverity severity) {
    switch (severity) {
      case TaskSeverity.low:
        return 'Low';
      case TaskSeverity.medium:
        return 'Medium';
      case TaskSeverity.high:
        return 'High';
      case TaskSeverity.critical:
        return 'Critical';
    }
  }
  
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const Color(0xFF3B82F6); // Blue-500
      case TaskStatus.inProgress:
        return const Color(0xFF8B5CF6); // Violet-500
      case TaskStatus.onHold:
        return const Color(0xFFF59E0B); // Amber-500
      case TaskStatus.wontDo:
        return const Color(0xFF6B7280); // Gray-500
    }
  }
  
  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.onHold:
        return 'On Hold';
      case TaskStatus.wontDo:
        return 'Won\'t Do';
    }
  }
  
  String _getRecurrenceText(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      default:
        return '';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today ${DateFormat('h:mm a').format(date)}';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return 'Tomorrow ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

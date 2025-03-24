import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pt_tracker/models/task.dart';
import 'package:pt_tracker/providers/task_provider.dart';
import 'package:pt_tracker/providers/language_provider.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final String? initialTitle;
  final TaskSeverity? initialSeverity;
  final RecurrenceType? initialRecurrenceType;
  final Task? editTask;
  final bool isEditing;
  
  const AddTaskScreen({
    Key? key, 
    this.initialTitle, 
    this.initialSeverity,
    this.initialRecurrenceType,
    this.editTask,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TaskSeverity _severity = TaskSeverity.medium;
  TaskStatus _status = TaskStatus.todo;
  RecurrenceType _recurrenceType = RecurrenceType.none;
  bool _showRecurrenceOptions = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.editTask != null) {
      _titleController = TextEditingController(text: widget.editTask!.title);
      _descriptionController = TextEditingController(text: widget.editTask!.description);
      _dueDate = widget.editTask!.dueDate;
      _severity = widget.editTask!.severity;
      _status = widget.editTask!.status;
      _recurrenceType = widget.editTask!.recurrenceType;
    } else {
      _titleController = TextEditingController(text: widget.initialTitle ?? '');
      _descriptionController = TextEditingController();
      _severity = widget.initialSeverity ?? TaskSeverity.medium;
      _recurrenceType = widget.initialRecurrenceType ?? RecurrenceType.none;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          
          // If due date is set, ask user if they want a recurring task
          _showRecurrenceOptions = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getLocalizedText('Add Task', 'कार्य थप्नुहोस्')),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageProvider.getLocalizedText('Task Details', 'कार्य विवरण'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: languageProvider.getLocalizedText('Task Title', 'कार्य शीर्षक'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.getLocalizedText(
                      'Please enter a title',
                      'कृपया शीर्षक प्रविष्ट गर्नुहोस्'
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: languageProvider.getLocalizedText(
                    'Description (Optional)',
                    'विवरण (वैकल्पिक)'
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Due Date Section
              Text(
                languageProvider.getLocalizedText('Due Date', 'म्याद मिति'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _selectDueDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _dueDate == null 
                            ? languageProvider.getLocalizedText(
                                'Select a date',
                                'मिति चयन गर्नुहोस्'
                              )
                            : DateFormat('MMM dd, yyyy - h:mm a').format(_dueDate!),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_showRecurrenceOptions || _recurrenceType != RecurrenceType.none) ...[
                const SizedBox(height: 24),
                Text(
                  languageProvider.getLocalizedText('Recurrence', 'पुनरावृत्ति'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Recurrence Options
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: RecurrenceType.values.map((type) {
                      return RadioListTile<RecurrenceType>(
                        title: Text(_getRecurrenceTypeText(type, languageProvider)),
                        value: type,
                        groupValue: _recurrenceType,
                        onChanged: (newValue) {
                          setState(() {
                            _recurrenceType = newValue!;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              Text(
                languageProvider.getLocalizedText('Priority & Status', 'प्राथमिकता र स्थिति'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Severity Selection
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        languageProvider.getLocalizedText('Priority', 'प्राथमिकता'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSeverityButton(
                          TaskSeverity.low,
                          Colors.green,
                          languageProvider.getLocalizedText('Low', 'न्यून'),
                          Icons.arrow_downward,
                          languageProvider,
                        ),
                        _buildSeverityButton(
                          TaskSeverity.medium,
                          Colors.blue,
                          languageProvider.getLocalizedText('Medium', 'मध्यम'),
                          Icons.remove,
                          languageProvider,
                        ),
                        _buildSeverityButton(
                          TaskSeverity.high,
                          Colors.orange,
                          languageProvider.getLocalizedText('High', 'उच्च'),
                          Icons.arrow_upward,
                          languageProvider,
                        ),
                        _buildSeverityButton(
                          TaskSeverity.critical,
                          Colors.red,
                          languageProvider.getLocalizedText('Critical', 'अत्यावश्यक'),
                          Icons.priority_high,
                          languageProvider,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Status Selection
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        languageProvider.getLocalizedText('Status', 'स्थिति'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildStatusButton(
                            TaskStatus.todo,
                            languageProvider.getLocalizedText('To Do', 'गर्नु पर्ने'),
                            languageProvider,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            TaskStatus.inProgress,
                            languageProvider.getLocalizedText('In Progress', 'प्रगति मा'),
                            languageProvider,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            TaskStatus.onHold,
                            languageProvider.getLocalizedText('On Hold', 'होल्ड मा'),
                            languageProvider,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            TaskStatus.wontDo,
                            languageProvider.getLocalizedText('Won\'t Do', 'गर्न मिल्दैन'),
                            languageProvider,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (widget.isEditing) {
                        final updatedTask = Task(
                          id: widget.editTask!.id,
                          title: _titleController.text,
                          description: _descriptionController.text.isEmpty 
                              ? null 
                              : _descriptionController.text,
                          createdAt: widget.editTask!.createdAt,
                          dueDate: _dueDate,
                          severity: _severity,
                          status: _status,
                          isCompleted: widget.editTask!.isCompleted,
                          recurrenceType: _recurrenceType,
                          parentTaskId: widget.editTask!.parentTaskId,
                          recurrenceCount: widget.editTask!.recurrenceCount,
                          lastRecurrenceDate: widget.editTask!.lastRecurrenceDate,
                        );
                        Provider.of<TaskProvider>(context, listen: false)
                            .updateTask(updatedTask);
                      } else {
                        Provider.of<TaskProvider>(context, listen: false).addTask(
                          _titleController.text,
                          _descriptionController.text.isEmpty 
                              ? null 
                              : _descriptionController.text,
                          _dueDate,
                          _severity,
                          _status,
                          _recurrenceType,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(
                    widget.isEditing
                        ? languageProvider.getLocalizedText('Update Task', 'कार्य अपडेट गर्नुहोस्')
                        : languageProvider.getLocalizedText('Save Task', 'कार्य सुरक्षित गर्नुहोस्'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSeverityButton(
    TaskSeverity severity,
    Color color,
    String label,
    IconData icon,
    LanguageProvider languageProvider,
  ) {
    final isSelected = _severity == severity;
    
    return InkWell(
      onTap: () {
        setState(() {
          _severity = severity;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected 
              ? Border.all(color: color)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusButton(
    TaskStatus status,
    String label,
    LanguageProvider languageProvider,
  ) {
    final isSelected = _status == status;
    final color = _getStatusColor(status);
    
    return InkWell(
      onTap: () {
        setState(() {
          _status = status;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected 
              ? Border.all(color: color)
              : Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
  
  String _getRecurrenceTypeText(RecurrenceType type, LanguageProvider languageProvider) {
    switch (type) {
      case RecurrenceType.none:
        return languageProvider.getLocalizedText('No recurrence', 'पुनरावृत्ति छैन');
      case RecurrenceType.daily:
        return languageProvider.getLocalizedText('Daily', 'दैनिक');
      case RecurrenceType.weekly:
        return languageProvider.getLocalizedText('Weekly', 'साप्ताहिक');
      case RecurrenceType.monthly:
        return languageProvider.getLocalizedText('Monthly', 'मासिक');
      case RecurrenceType.yearly:
        return languageProvider.getLocalizedText('Yearly', 'वार्षिक');
    }
  }
  
  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.amber;
      case TaskStatus.onHold:
        return Colors.purple;
      case TaskStatus.wontDo:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pt_tracker/models/task.dart';
import 'package:pt_tracker/providers/task_provider.dart';
import 'package:pt_tracker/providers/theme_provider.dart';
import 'package:pt_tracker/providers/language_provider.dart';
import 'package:pt_tracker/screens/add_task_screen.dart';
import 'package:pt_tracker/theme/app_theme.dart'; // Add this import
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Changed from 4 to 5
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    final allTasks = taskProvider.allTasks;
    final incompleteTasks = allTasks.where((task) => !task.isCompleted).toList();
    
    final String greeting = _getGreeting(languageProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App bar with greeting and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Reduced from 16 to 12
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Language toggle
                      IconButton(
                        icon: Icon(
                          languageProvider.isNepali 
                              ? Icons.translate
                              : Icons.language,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => languageProvider.toggleLanguage(),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Theme toggle
                      IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode 
                              ? Icons.light_mode_rounded 
                              : Icons.dark_mode_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () => themeProvider.toggleTheme(),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Title and subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                languageProvider.getLocalizedText('Your Tasks', 'तपाईंका कार्यहरू'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            
            const SizedBox(height: 4),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                languageProvider.getLocalizedText(
                  'Manage your tasks efficiently',
                  'तपाईंका कार्यहरू कुशलतापूर्वक व्यवस्थापन गर्नुहोस्'
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            
            const SizedBox(height: 20), // Reduced from 24 to 20
            
            // Summary cards
            Container(
              height: 96, // Reduced height to prevent overflow
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced vertical padding from 16 to 12
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    context,
                    Icons.list_rounded,
                    allTasks.length.toString(),
                    languageProvider.getLocalizedText('Total', 'जम्मा'),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStatColumn(
                    context,
                    Icons.check_circle_rounded,
                    '${((allTasks.where((t) => t.isCompleted).length / 
                      (allTasks.isEmpty ? 1 : allTasks.length) * 100)).toInt()}%',
                    languageProvider.getLocalizedText('Done', 'सम्पन्न'),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStatColumn(
                    context,
                    Icons.priority_high_rounded,
                    incompleteTasks.where((t) => 
                      t.severity == TaskSeverity.high || 
                      t.severity == TaskSeverity.critical
                    ).length.toString(),
                    languageProvider.getLocalizedText('Priority', 'जरुरी'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20), // Reduced from 24 to 20
            
            // Custom tab bar
            _buildTrendyTabBar(context, languageProvider),
            
            const SizedBox(height: 16),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(TaskStatus.todo, languageProvider),
                  _buildTaskList(TaskStatus.inProgress, languageProvider),
                  _buildTaskList(TaskStatus.onHold, languageProvider),
                  _buildTaskList(TaskStatus.wontDo, languageProvider),
                  _buildCompletedTasksList(languageProvider), // New method for completed tasks
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
    {required Color primaryColor}
  ) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Optional onTap action
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Reduced from 16.0 to 12.0
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8), // Reduced from 10 to 8
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 20, // Added explicit size
                  ),
                ),
                const Spacer(),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskStatus status, LanguageProvider languageProvider) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.getTasksByStatus(status);
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.getLocalizedText(
                'No tasks yet',
                'अहिले सम्म कुनै कार्य छैन'),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildModernTaskCard(
          tasks[index], 
          languageProvider,
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
  }
  
  Widget _buildModernTaskCard(
    Task task, 
    LanguageProvider languageProvider, {
    required Function(TaskStatus) onStatusChanged,
    required VoidCallback onDelete,
    required VoidCallback onComplete,
  }) {
    final Color severityColor = _getSeverityColor(task.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _getSeverityIcon(task.severity),
                  color: severityColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _getSeverityText(task.severity, languageProvider),
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (task.isRecurring)
                  Chip(
                    label: Text(
                      _getRecurrenceText(task.recurrenceType, languageProvider),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        if (!task.isCompleted)
                          PopupMenuItem(
                            value: 'complete',
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline),
                                const SizedBox(width: 8),
                                Text(languageProvider.getLocalizedText('Mark as completed', 'पूरा भयो मार्क गर्नुहोस्')),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit),
                              const SizedBox(width: 8),
                              Text(languageProvider.getLocalizedText('Edit', 'सम्पादन')),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline),
                              const SizedBox(width: 8),
                              Text(languageProvider.getLocalizedText('Delete', 'मेटाउनुहोस्')),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'complete') {
                          onComplete();
                        } else if (value == 'delete') {
                          onDelete();
                        } else if (value == 'edit') {
                          _editTask(context, task);
                        }
                      },
                    ),
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        languageProvider.getLocalizedText(
                          'Due: ${_formatDate(task.dueDate!)}',
                          'म्याद: ${_formatDate(task.dueDate!)}'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (!task.isCompleted)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.task_alt_rounded, size: 18),
                        label: Text(
                          languageProvider.getLocalizedText('Complete', 'पूरा भयो'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: onComplete,
                      ),
                  ],
                ),
                if (!task.isCompleted) ...[
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: TaskStatus.values.map((status) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildStatusChip(
                            context, 
                            status, 
                            task.status, 
                            languageProvider,
                            onStatusChanged,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(
    BuildContext context, 
    TaskStatus status, 
    TaskStatus currentStatus, 
    LanguageProvider languageProvider,
    Function(TaskStatus) onStatusChanged,
  ) {
    final isSelected = status == currentStatus;
    final Color statusColor = AppTheme.getStatusColor(status);
    
    return GestureDetector(
      onTap: isSelected ? null : () => onStatusChanged(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(
            colors: [
              statusColor,
              statusColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isSelected 
              ? null 
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? statusColor 
                : Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
        child: Text(
          _getStatusText(status, languageProvider),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? Colors.white 
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // Helper methods for icons, colors, and text
  String _getGreeting(LanguageProvider languageProvider) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return languageProvider.getLocalizedText('Good Morning', 'शुभ-प्रभात');
    } else if (hour < 17) {
      return languageProvider.getLocalizedText('Good Afternoon', 'शुभ-अपरान्ह');
    } else {
      return languageProvider.getLocalizedText('Good Evening', 'शुभ-सन्ध्या');
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return languageProvider.getLocalizedText(
        'Today',
        'आज'
      );
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return languageProvider.getLocalizedText(
        'Tomorrow',
        'भोलि'
      );
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  Color _getSeverityColor(TaskSeverity severity) {
    return AppTheme.getSeverityColor(severity);
  }
  
  IconData _getSeverityIcon(TaskSeverity severity) {
    return AppTheme.getSeverityIcon(severity);
  }
  
  String _getSeverityText(TaskSeverity severity, LanguageProvider languageProvider) {
    switch (severity) {
      case TaskSeverity.low:
        return languageProvider.getLocalizedText('Low', 'न्यून');
      case TaskSeverity.medium:
        return languageProvider.getLocalizedText('Medium', 'मध्यम');
      case TaskSeverity.high:
        return languageProvider.getLocalizedText('High', 'उच्च');
      case TaskSeverity.critical:
        return languageProvider.getLocalizedText('Critical', 'अत्यावश्यक');
    }
  }
  
  String _getStatusText(TaskStatus status, LanguageProvider languageProvider) {
    switch (status) {
      case TaskStatus.todo:
        return languageProvider.getLocalizedText('To Do', 'गर्नु पर्ने');
      case TaskStatus.inProgress:
        return languageProvider.getLocalizedText('In Progress', 'प्रगति मा');
      case TaskStatus.onHold:
        return languageProvider.getLocalizedText('On Hold', 'होल्ड मा');
      case TaskStatus.wontDo:
        return languageProvider.getLocalizedText('Won\'t Do', 'गर्न मिल्दैन');
    }
  }
  
  String _getRecurrenceText(RecurrenceType type, LanguageProvider languageProvider) {
    switch (type) {
      case RecurrenceType.daily:
        return languageProvider.getLocalizedText('Daily', 'दैनिक');
      case RecurrenceType.weekly:
        return languageProvider.getLocalizedText('Weekly', 'साप्ताहिक');
      case RecurrenceType.monthly:
        return languageProvider.getLocalizedText('Monthly', 'मासिक');
      case RecurrenceType.yearly:
        return languageProvider.getLocalizedText('Yearly', 'वार्षिक');
      default:
        return '';
    }
  }

  Widget _buildTrendyTabBar(BuildContext context, LanguageProvider languageProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48, // Fixed height
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12), // Reduced from 16 to 12
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        tabs: [
          Tab(text: languageProvider.getLocalizedText('To Do', 'बाँकी')),
          Tab(text: languageProvider.getLocalizedText('Progress', 'प्रगति')),
          Tab(text: languageProvider.getLocalizedText('Hold', 'होल्ड')),
          Tab(text: languageProvider.getLocalizedText('Won\'t', 'नगर्ने')),
          Tab(text: languageProvider.getLocalizedText('Completed', 'सम्पन्न')), // New tab
        ],
      ),
    );
  }

  Widget _buildCompletedTasksList(LanguageProvider languageProvider) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.allTasks.where((task) => task.isCompleted).toList();
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.getLocalizedText(
                'No completed tasks yet',
                'अहिले सम्म कुनै कार्य सम्पन्न छैन'),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildModernTaskCard(
          tasks[index],
          languageProvider,
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
  }

  Widget _buildStatColumn(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22, // Reduced from 24 to 22
        ),
        const SizedBox(height: 2), // Reduced from 4 to 2
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2), // Reduced from 4 to 2
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _editTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          editTask: task,
          isEditing: true,
        ),
      ),
    );
  }
}